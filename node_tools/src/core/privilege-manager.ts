/**
 * Privilege management for automatic elevation on different platforms
 */

import { executeCommand, hasElevatedPrivileges } from '../utils/process';
import { OSType } from '../types/system.types';
import { detectOS } from './system-detector';
import { getLogger } from '../utils/logger';

const logger = getLogger();

/**
 * Check if current process has admin/root privileges
 */
export async function checkPrivileges(): Promise<boolean> {
  return await hasElevatedPrivileges();
}

/**
 * Execute command with elevated privileges
 */
export async function executeWithPrivileges(
  command: string,
  options: {
    cwd?: string;
    timeout?: number;
    promptMessage?: string;
  } = {}
): Promise<{ success: boolean; output: string; error?: string }> {
  const hasPrivileges = await checkPrivileges();
  
  if (hasPrivileges) {
    logger.debug('Already have elevated privileges, executing directly');
    const result = await executeCommand(command, {
      cwd: options.cwd,
      timeout: options.timeout,
    });
    
    return {
      success: result.exitCode === 0,
      output: result.stdout,
      error: result.exitCode !== 0 ? result.stderr : undefined,
    };
  }

  const os = detectOS();
  
  switch (os) {
    case OSType.WINDOWS:
      return await executeWithPrivilegesWindows(command, options);
    case OSType.MACOS:
    case OSType.LINUX:
      return await executeWithPrivilegesUnix(command, options);
    default:
      throw new Error(`Privilege elevation not supported on ${os}`);
  }
}

/**
 * Execute command with elevated privileges on Windows
 */
async function executeWithPrivilegesWindows(
  command: string,
  options: {
    cwd?: string;
    timeout?: number;
    promptMessage?: string;
  }
): Promise<{ success: boolean; output: string; error?: string }> {
  try {
    // Try using sudo-prompt package for Windows
    const sudoPrompt = require('sudo-prompt');
    const promptOptions = {
      name: options.promptMessage || 'Node Tool Installer',
    };

    return new Promise((resolve) => {
      sudoPrompt.exec(
        command,
        promptOptions,
        (error: Error | null, stdout: string | Buffer, stderr: string | Buffer) => {
          if (error) {
            logger.error('Failed to execute with privileges on Windows', error);
            resolve({
              success: false,
              output: '',
              error: error.message,
            });
          } else {
            resolve({
              success: true,
              output: stdout?.toString() || '',
              error: stderr?.toString() || undefined,
            });
          }
        }
      );
    });
  } catch (error) {
    logger.error('sudo-prompt not available, trying PowerShell elevation', error);
    
    // Fallback: Use PowerShell Start-Process with -Verb RunAs
    const psCommand = `Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "${command.replace(/"/g, '\\"')}"' -Verb RunAs -Wait`;
    
    const result = await executeCommand(psCommand, {
      cwd: options.cwd,
      timeout: options.timeout,
      shell: 'powershell.exe',
    });
    
    return {
      success: result.exitCode === 0,
      output: result.stdout,
      error: result.exitCode !== 0 ? result.stderr : undefined,
    };
  }
}

/**
 * Execute command with elevated privileges on Unix-like systems
 */
async function executeWithPrivilegesUnix(
  command: string,
  options: {
    cwd?: string;
    timeout?: number;
    promptMessage?: string;
  }
): Promise<{ success: boolean; output: string; error?: string }> {
  try {
    // Try using sudo-prompt package
    const sudoPrompt = require('sudo-prompt');
    const promptOptions = {
      name: options.promptMessage || 'Node Tool Installer',
    };

    return new Promise((resolve) => {
      sudoPrompt.exec(
        command,
        promptOptions,
        (error: Error | null, stdout: string | Buffer, stderr: string | Buffer) => {
          if (error) {
            logger.error('Failed to execute with sudo', error);
            resolve({
              success: false,
              output: '',
              error: error.message,
            });
          } else {
            resolve({
              success: true,
              output: stdout?.toString() || '',
              error: stderr?.toString() || undefined,
            });
          }
        }
      );
    });
  } catch (error) {
    logger.error('sudo-prompt not available, trying direct sudo', error);
    
    // Fallback: Direct sudo command
    const sudoCommand = `sudo -S ${command}`;
    const result = await executeCommand(sudoCommand, {
      cwd: options.cwd,
      timeout: options.timeout,
    });
    
    return {
      success: result.exitCode === 0,
      output: result.stdout,
      error: result.exitCode !== 0 ? result.stderr : undefined,
    };
  }
}

/**
 * Check if sudo is available (Unix-like systems)
 */
export async function isSudoAvailable(): Promise<boolean> {
  const os = detectOS();
  
  if (os === OSType.WINDOWS) {
    return false;
  }

  try {
    const result = await executeCommand('which sudo', { timeout: 5000 });
    return result.exitCode === 0;
  } catch {
    return false;
  }
}

/**
 * Test sudo access without password prompt
 */
export async function testSudoAccess(): Promise<boolean> {
  const os = detectOS();
  
  if (os === OSType.WINDOWS) {
    return await checkPrivileges();
  }

  try {
    const result = await executeCommand('sudo -n true', { timeout: 5000 });
    return result.exitCode === 0;
  } catch {
    return false;
  }
}

/**
 * Get privilege escalation method for current platform
 */
export function getPrivilegeEscalationMethod(): string {
  const os = detectOS();
  
  switch (os) {
    case OSType.WINDOWS:
      return 'UAC (User Account Control)';
    case OSType.MACOS:
    case OSType.LINUX:
      return 'sudo';
    default:
      return 'unknown';
  }
}

/**
 * Install packages with automatic privilege escalation if needed
 */
export async function installWithPrivileges(
  command: string,
  options: {
    cwd?: string;
    timeout?: number;
    requirePrivileges?: boolean;
  } = {}
): Promise<{ success: boolean; output: string; error?: string; elevationUsed: boolean }> {
  // First try without privileges
  logger.debug('Attempting installation without elevation...');
  let result = await executeCommand(command, {
    cwd: options.cwd,
    timeout: options.timeout,
  });

  if (result.exitCode === 0) {
    return {
      success: true,
      output: result.stdout,
      elevationUsed: false,
    };
  }

  // Check if error is permission-related
  const permissionErrors = [
    'EACCES',
    'EPERM',
    'permission denied',
    'access denied',
    'requires administrator',
    'requires root',
  ];

  const needsElevation =
    options.requirePrivileges ||
    permissionErrors.some(
      (err) =>
        result.stderr.toLowerCase().includes(err.toLowerCase()) ||
        result.stdout.toLowerCase().includes(err.toLowerCase())
    );

  if (!needsElevation) {
    return {
      success: false,
      output: result.stdout,
      error: result.stderr,
      elevationUsed: false,
    };
  }

  // Try with elevated privileges
  logger.info('Installation requires elevated privileges, requesting elevation...');
  const elevatedResult = await executeWithPrivileges(command, {
    cwd: options.cwd,
    timeout: options.timeout,
    promptMessage: 'Node Tool Installer needs administrator access to install packages',
  });

  return {
    ...elevatedResult,
    elevationUsed: true,
  };
}

/**
 * Check write permissions for a directory
 */
export async function checkWritePermissions(directory: string): Promise<boolean> {
  try {
    const fs = require('fs-extra');
    await fs.access(directory, fs.constants.W_OK);
    return true;
  } catch {
    return false;
  }
}