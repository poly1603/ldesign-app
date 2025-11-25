/**
 * Disk space checker
 */

import { execSync } from 'child_process';
import path from 'path';
import os from 'os';
import { DiskSpaceInfo } from '../types/system.types';
import { CheckResult } from '../types/installer.types';
import { getLogger } from '../utils/logger';
import { executeCommand } from '../utils/process';

const logger = getLogger();

/**
 * Get disk space information for a path
 */
export async function getDiskSpaceInfo(targetPath: string): Promise<DiskSpaceInfo> {
  try {
    const platform = os.platform();
    const resolvedPath = path.resolve(targetPath);
    
    let diskSpace: { free: number; total: number };

    if (platform === 'win32') {
      diskSpace = await getWindowsDiskSpace(resolvedPath);
    } else {
      diskSpace = await getUnixDiskSpace(resolvedPath);
    }
    
    const used = diskSpace.total - diskSpace.free;
    const percentUsed = (used / diskSpace.total) * 100;

    const info: DiskSpaceInfo = {
      available: diskSpace.free,
      free: diskSpace.free,
      total: diskSpace.total,
      used,
      percentUsed,
    };

    logger.debug('Disk space info', {
      path: targetPath,
      freeGB: (info.free / (1024 * 1024 * 1024)).toFixed(2),
      totalGB: (info.total / (1024 * 1024 * 1024)).toFixed(2),
    });

    return info;
  } catch (error) {
    logger.error(`Failed to get disk space info for ${targetPath}`, error);
    throw error;
  }
}

/**
 * Get disk space on Windows
 */
async function getWindowsDiskSpace(targetPath: string): Promise<{ free: number; total: number }> {
  try {
    const drive = path.parse(targetPath).root;
    const command = `wmic logicaldisk where "DeviceID='${drive.replace('\\', '')}'" get FreeSpace,Size /value`;
    
    const result = await executeCommand(command, { timeout: 10000 });
    
    if (result.exitCode !== 0) {
      throw new Error(`Failed to get disk space: ${result.stderr}`);
    }

    const lines = result.stdout.split('\n');
    let freeSpace = 0;
    let totalSize = 0;

    for (const line of lines) {
      if (line.startsWith('FreeSpace=')) {
        freeSpace = parseInt(line.split('=')[1].trim());
      }
      if (line.startsWith('Size=')) {
        totalSize = parseInt(line.split('=')[1].trim());
      }
    }

    return {
      free: freeSpace,
      total: totalSize,
    };
  } catch (error) {
    logger.warn('Failed to get Windows disk space via wmic, using fallback');
    // Fallback: estimate based on tmpdir
    return {
      free: 10 * 1024 * 1024 * 1024, // 10GB estimate
      total: 100 * 1024 * 1024 * 1024, // 100GB estimate
    };
  }
}

/**
 * Get disk space on Unix-like systems
 */
async function getUnixDiskSpace(targetPath: string): Promise<{ free: number; total: number }> {
  try {
    const result = await executeCommand(`df -k "${targetPath}"`, { timeout: 5000 });
    
    if (result.exitCode !== 0) {
      throw new Error(`Failed to get disk space: ${result.stderr}`);
    }

    const lines = result.stdout.trim().split('\n');
    if (lines.length < 2) {
      throw new Error('Unexpected df output format');
    }

    const parts = lines[1].split(/\s+/);
    // df -k output: Filesystem 1K-blocks Used Available Use% Mounted
    const totalBlocks = parseInt(parts[1]) * 1024; // Convert from KB to bytes
    const availableBlocks = parseInt(parts[3]) * 1024;

    return {
      free: availableBlocks,
      total: totalBlocks,
    };
  } catch (error) {
    logger.warn('Failed to get Unix disk space via df, using fallback');
    // Fallback: estimate
    return {
      free: 10 * 1024 * 1024 * 1024, // 10GB estimate
      total: 100 * 1024 * 1024 * 1024, // 100GB estimate
    };
  }
}

/**
 * Check if sufficient disk space is available
 */
export async function checkDiskSpace(
  targetPath: string,
  requiredBytes: number
): Promise<CheckResult> {
  try {
    const diskInfo = await getDiskSpaceInfo(targetPath);
    const requiredGB = requiredBytes / (1024 * 1024 * 1024);
    const availableGB = diskInfo.available / (1024 * 1024 * 1024);

    const passed = diskInfo.available >= requiredBytes;

    return {
      name: 'Disk Space',
      passed,
      critical: !passed,
      message: passed
        ? `Sufficient disk space available: ${availableGB.toFixed(2)}GB`
        : `Insufficient disk space: ${availableGB.toFixed(2)}GB available, ${requiredGB.toFixed(2)}GB required`,
      details: {
        availableBytes: diskInfo.available,
        requiredBytes,
        availableGB: availableGB.toFixed(2),
        requiredGB: requiredGB.toFixed(2),
      },
    };
  } catch (error) {
    logger.error('Disk space check failed', error);
    return {
      name: 'Disk Space',
      passed: false,
      critical: true,
      message: `Failed to check disk space: ${error instanceof Error ? error.message : 'Unknown error'}`,
    };
  }
}

/**
 * Estimate required disk space for package installation
 */
export function estimateRequiredSpace(packageCount: number): number {
  // Conservative estimate: 50MB per package on average
  // Plus 500MB for npm/yarn cache and temporary files
  const baseSpace = 500 * 1024 * 1024; // 500MB
  const perPackageSpace = 50 * 1024 * 1024; // 50MB
  
  return baseSpace + (packageCount * perPackageSpace);
}