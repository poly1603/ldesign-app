/**
 * Process execution utilities with timeout, retry, and error handling
 */

import { exec, spawn, ExecOptions, SpawnOptions } from 'child_process';
import { promisify } from 'util';
import { getLogger } from './logger';

const execAsync = promisify(exec);
const logger = getLogger();

export interface ProcessResult {
  stdout: string;
  stderr: string;
  exitCode: number;
  duration: number;
  timedOut: boolean;
}

export interface ProcessOptions {
  cwd?: string;
  env?: NodeJS.ProcessEnv;
  timeout?: number;
  maxBuffer?: number;
  shell?: string | boolean;
  encoding?: BufferEncoding;
}

export interface SpawnResult {
  stdout: string;
  stderr: string;
  exitCode: number | null;
  signal: NodeJS.Signals | null;
  duration: number;
}

/**
 * Execute a command with promise support and enhanced error handling
 */
export async function executeCommand(
  command: string,
  options: ProcessOptions = {}
): Promise<ProcessResult> {
  const startTime = Date.now();
  const timeout = options.timeout || 300000; // 5 minutes default
  const maxBuffer = options.maxBuffer || 1024 * 1024 * 10; // 10MB default

  logger.debug(`Executing command: ${command}`, { cwd: options.cwd });

  try {
    const execOptions: ExecOptions = {
      cwd: options.cwd || process.cwd(),
      env: { ...process.env, ...options.env },
      timeout,
      maxBuffer,
    };

    if (typeof options.shell === 'string') {
      execOptions.shell = options.shell;
    }

    const { stdout, stderr } = await execAsync(command, execOptions);
    const duration = Date.now() - startTime;

    logger.debug(`Command completed successfully in ${duration}ms`);

    return {
      stdout: stdout.toString(),
      stderr: stderr.toString(),
      exitCode: 0,
      duration,
      timedOut: false,
    };
  } catch (error: any) {
    const duration = Date.now() - startTime;
    const timedOut = error.killed && error.signal === 'SIGTERM';

    logger.error(`Command failed: ${command}`, error);

    return {
      stdout: error.stdout?.toString() || '',
      stderr: error.stderr?.toString() || error.message,
      exitCode: error.code || 1,
      duration,
      timedOut,
    };
  }
}

/**
 * Execute a command with real-time output streaming
 */
export async function executeCommandStreaming(
  command: string,
  args: string[],
  options: ProcessOptions = {},
  onStdout?: (data: string) => void,
  onStderr?: (data: string) => void
): Promise<SpawnResult> {
  const startTime = Date.now();

  return new Promise((resolve) => {
    const spawnOptions: SpawnOptions = {
      cwd: options.cwd || process.cwd(),
      env: { ...process.env, ...options.env },
      shell: options.shell !== undefined ? options.shell : true,
    };

    logger.debug(`Spawning command: ${command} ${args.join(' ')}`, { cwd: options.cwd });

    const child = spawn(command, args, spawnOptions);
    let stdout = '';
    let stderr = '';

    child.stdout?.on('data', (data) => {
      const text = data.toString();
      stdout += text;
      if (onStdout) {
        onStdout(text);
      }
    });

    child.stderr?.on('data', (data) => {
      const text = data.toString();
      stderr += text;
      if (onStderr) {
        onStderr(text);
      }
    });

    child.on('close', (exitCode, signal) => {
      const duration = Date.now() - startTime;
      logger.debug(`Command completed with exit code ${exitCode} in ${duration}ms`);

      resolve({
        stdout,
        stderr,
        exitCode,
        signal,
        duration,
      });
    });

    child.on('error', (error) => {
      const duration = Date.now() - startTime;
      logger.error(`Command spawn error: ${command}`, error);

      resolve({
        stdout,
        stderr: stderr + error.message,
        exitCode: null,
        signal: null,
        duration,
      });
    });

    // Handle timeout
    if (options.timeout) {
      setTimeout(() => {
        if (!child.killed) {
          logger.warn(`Command timed out after ${options.timeout}ms: ${command}`);
          child.kill('SIGTERM');
        }
      }, options.timeout);
    }
  });
}

/**
 * Execute command with automatic retry on failure
 */
export async function executeWithRetry(
  command: string,
  options: ProcessOptions = {},
  maxRetries: number = 3,
  retryDelay: number = 1000
): Promise<ProcessResult> {
  let lastError: ProcessResult | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    logger.debug(`Executing command (attempt ${attempt}/${maxRetries}): ${command}`);

    const result = await executeCommand(command, options);

    if (result.exitCode === 0) {
      return result;
    }

    lastError = result;
    logger.warn(`Command failed (attempt ${attempt}/${maxRetries})`, {
      exitCode: result.exitCode,
      stderr: result.stderr,
    });

    if (attempt < maxRetries) {
      logger.debug(`Waiting ${retryDelay}ms before retry...`);
      await sleep(retryDelay);
    }
  }

  throw new Error(
    `Command failed after ${maxRetries} attempts: ${lastError?.stderr || 'Unknown error'}`
  );
}

/**
 * Check if a command exists in the system PATH
 */
export async function commandExists(command: string): Promise<boolean> {
  const isWindows = process.platform === 'win32';
  const checkCommand = isWindows ? `where ${command}` : `which ${command}`;

  try {
    const result = await executeCommand(checkCommand, { timeout: 5000 });
    return result.exitCode === 0 && result.stdout.trim().length > 0;
  } catch {
    return false;
  }
}

/**
 * Get command version
 */
export async function getCommandVersion(command: string): Promise<string | null> {
  try {
    // Try --version first
    let result = await executeCommand(`${command} --version`, { timeout: 5000 });
    
    if (result.exitCode === 0) {
      return result.stdout.trim().split('\n')[0];
    }

    // Try -v
    result = await executeCommand(`${command} -v`, { timeout: 5000 });
    
    if (result.exitCode === 0) {
      return result.stdout.trim().split('\n')[0];
    }

    return null;
  } catch {
    return null;
  }
}

/**
 * Kill process by PID with cross-platform support
 */
export async function killProcess(pid: number, signal: NodeJS.Signals = 'SIGTERM'): Promise<boolean> {
  try {
    process.kill(pid, signal);
    logger.debug(`Sent ${signal} to process ${pid}`);
    return true;
  } catch (error) {
    logger.error(`Failed to kill process ${pid}`, error);
    return false;
  }
}

/**
 * Sleep utility
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Check if running with elevated privileges
 */
export async function hasElevatedPrivileges(): Promise<boolean> {
  const isWindows = process.platform === 'win32';

  if (isWindows) {
    try {
      const result = await executeCommand('net session', { timeout: 5000 });
      return result.exitCode === 0;
    } catch {
      return false;
    }
  } else {
    // Unix-like systems
    return process.getuid?.() === 0;
  }
}