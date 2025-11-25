/**
 * Unit tests for system detector
 */

import {
  detectOS,
  detectArchitecture,
  detectContainer,
  detectCI,
  getSystemInfo,
  checkSystemCompatibility,
} from '../../src/core/system-detector';
import { OSType, Architecture } from '../../src/types/system.types';

describe('System Detector', () => {
  describe('detectOS', () => {
    it('should detect operating system', () => {
      const os = detectOS();
      expect(os).toBeDefined();
      expect(Object.values(OSType)).toContain(os);
    });

    it('should return valid OS type', () => {
      const os = detectOS();
      expect([OSType.WINDOWS, OSType.MACOS, OSType.LINUX, OSType.UNKNOWN]).toContain(os);
    });
  });

  describe('detectArchitecture', () => {
    it('should detect system architecture', () => {
      const arch = detectArchitecture();
      expect(arch).toBeDefined();
      expect(Object.values(Architecture)).toContain(arch);
    });

    it('should return valid architecture', () => {
      const arch = detectArchitecture();
      expect([
        Architecture.X64,
        Architecture.X86,
        Architecture.ARM64,
        Architecture.ARM,
        Architecture.UNKNOWN,
      ]).toContain(arch);
    });
  });

  describe('detectContainer', () => {
    it('should detect container environment', async () => {
      const isContainer = await detectContainer();
      expect(typeof isContainer).toBe('boolean');
    });
  });

  describe('detectCI', () => {
    it('should detect CI environment', () => {
      const isCI = detectCI();
      expect(typeof isCI).toBe('boolean');
    });

    it('should return true if CI env var is set', () => {
      const originalCI = process.env.CI;
      process.env.CI = 'true';
      
      const isCI = detectCI();
      expect(isCI).toBe(true);
      
      if (originalCI === undefined) {
        delete process.env.CI;
      } else {
        process.env.CI = originalCI;
      }
    });
  });

  describe('getSystemInfo', () => {
    it('should return complete system information', async () => {
      const info = await getSystemInfo();
      
      expect(info).toBeDefined();
      expect(info.os).toBeDefined();
      expect(info.arch).toBeDefined();
      expect(info.platform).toBeDefined();
      expect(info.cpuCores).toBeGreaterThan(0);
      expect(info.totalMemory).toBeGreaterThan(0);
      expect(info.freeMemory).toBeGreaterThan(0);
      expect(typeof info.isContainer).toBe('boolean');
      expect(typeof info.isCI).toBe('boolean');
    });

    it('should have valid memory values', async () => {
      const info = await getSystemInfo();
      
      expect(info.freeMemory).toBeLessThanOrEqual(info.totalMemory);
      expect(info.freeMemory).toBeGreaterThanOrEqual(0);
    });
  });

  describe('checkSystemCompatibility', () => {
    it('should check system compatibility', async () => {
      const result = await checkSystemCompatibility();
      
      expect(result).toBeDefined();
      expect(typeof result.compatible).toBe('boolean');
      expect(Array.isArray(result.issues)).toBe(true);
      expect(Array.isArray(result.warnings)).toBe(true);
    });

    it('should validate Node.js version', async () => {
      const result = await checkSystemCompatibility();
      const nodeVersion = process.version;
      const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
      
      if (majorVersion < 14) {
        expect(result.compatible).toBe(false);
        expect(result.issues.length).toBeGreaterThan(0);
      } else {
        expect(result.compatible).toBe(true);
      }
    });
  });
});