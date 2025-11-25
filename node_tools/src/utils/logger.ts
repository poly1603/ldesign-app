/**
 * Logger utility with multiple transports and log levels
 */

import winston from 'winston';
import path from 'path';
import fs from 'fs-extra';

export enum LogLevel {
  ERROR = 'error',
  WARN = 'warn',
  INFO = 'info',
  DEBUG = 'debug',
  VERBOSE = 'verbose',
}

export interface LoggerConfig {
  level?: LogLevel;
  silent?: boolean;
  logToFile?: boolean;
  logDir?: string;
  maxFiles?: number;
  maxSize?: string;
  colorize?: boolean;
}

class Logger {
  private logger: winston.Logger;
  private config: Required<LoggerConfig>;

  constructor(config: LoggerConfig = {}) {
    this.config = {
      level: config.level || LogLevel.INFO,
      silent: config.silent || false,
      logToFile: config.logToFile !== false,
      logDir: config.logDir || path.join(process.cwd(), 'logs'),
      maxFiles: config.maxFiles || 5,
      maxSize: config.maxSize || '10m',
      colorize: config.colorize !== false,
    };

    this.logger = this.createLogger();
  }

  private createLogger(): winston.Logger {
    const transports: winston.transport[] = [];

    // Console transport
    if (!this.config.silent) {
      transports.push(
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
            winston.format.errors({ stack: true }),
            this.config.colorize ? winston.format.colorize() : winston.format.uncolorize(),
            winston.format.printf(({ level, message, timestamp, stack }) => {
              if (stack) {
                return `${timestamp} [${level}]: ${message}\n${stack}`;
              }
              return `${timestamp} [${level}]: ${message}`;
            })
          ),
        })
      );
    }

    // File transport
    if (this.config.logToFile) {
      fs.ensureDirSync(this.config.logDir);

      transports.push(
        new winston.transports.File({
          filename: path.join(this.config.logDir, 'error.log'),
          level: 'error',
          maxsize: this.parseSize(this.config.maxSize),
          maxFiles: this.config.maxFiles,
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.errors({ stack: true }),
            winston.format.json()
          ),
        })
      );

      transports.push(
        new winston.transports.File({
          filename: path.join(this.config.logDir, 'combined.log'),
          maxsize: this.parseSize(this.config.maxSize),
          maxFiles: this.config.maxFiles,
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.errors({ stack: true }),
            winston.format.json()
          ),
        })
      );
    }

    return winston.createLogger({
      level: this.config.level,
      transports,
      exitOnError: false,
    });
  }

  private parseSize(size: string): number {
    const units: Record<string, number> = {
      b: 1,
      k: 1024,
      m: 1024 * 1024,
      g: 1024 * 1024 * 1024,
    };

    const match = size.toLowerCase().match(/^(\d+)([bkmg])$/);
    if (!match) {
      return 10 * 1024 * 1024; // Default 10MB
    }

    const [, num, unit] = match;
    return parseInt(num, 10) * units[unit];
  }

  error(message: string, error?: Error | unknown): void {
    if (error instanceof Error) {
      this.logger.error(message, { error: error.message, stack: error.stack });
    } else {
      this.logger.error(message, { error });
    }
  }

  warn(message: string, meta?: Record<string, unknown>): void {
    this.logger.warn(message, meta);
  }

  info(message: string, meta?: Record<string, unknown>): void {
    this.logger.info(message, meta);
  }

  debug(message: string, meta?: Record<string, unknown>): void {
    this.logger.debug(message, meta);
  }

  verbose(message: string, meta?: Record<string, unknown>): void {
    this.logger.verbose(message, meta);
  }

  setLevel(level: LogLevel): void {
    this.config.level = level;
    this.logger.level = level;
  }

  setSilent(silent: boolean): void {
    this.config.silent = silent;
    this.logger.silent = silent;
  }

  clearLogs(): void {
    if (this.config.logToFile && fs.existsSync(this.config.logDir)) {
      fs.emptyDirSync(this.config.logDir);
      this.info('Logs cleared');
    }
  }
}

// Singleton instance
let loggerInstance: Logger | null = null;

export function createLogger(config?: LoggerConfig): Logger {
  loggerInstance = new Logger(config);
  return loggerInstance;
}

export function getLogger(): Logger {
  if (!loggerInstance) {
    loggerInstance = new Logger();
  }
  return loggerInstance;
}

export default Logger;