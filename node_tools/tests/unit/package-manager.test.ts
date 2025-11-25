/**
 * Unit tests for package manager
 */

import {
  detectAvailablePackageManagers,
  detectPackageManager,
  getInstallCommand,
  getUninstallCommand,
} from '../../src/core/package-manager';
import { commandExists } from '../../src/utils/process';
import { PackageManager } from '../../src/types/installer.types';

describe('Package Manager', () => {
  describe('detectAvailablePackageManagers', () => {
    it('should detect available package managers', async () => {
      const managers = await detectAvailablePackageManagers();
      
      expect(Array.isArray(managers)).toBe(true);
      // npm should always be available with Node.js
      expect(managers.length).toBeGreaterThan(0);
    });

    it('should return valid package manager types', async () => {
      const managers = await detectAvailablePackageManagers();
      
      managers.forEach((manager) => {
        expect(Object.values(PackageManager)).toContain(manager);
      });
    });
  });

  describe('detectPackageManager', () => {
    it('should detect package manager', async () => {
      const manager = await detectPackageManager();
      
      expect(manager).toBeDefined();
      expect(Object.values(PackageManager)).toContain(manager);
    });

    it('should use preferred manager if specified', async () => {
      const availableManagers = await detectAvailablePackageManagers();
      
      if (availableManagers.includes(PackageManager.NPM)) {
        const manager = await detectPackageManager(process.cwd(), PackageManager.NPM);
        expect(manager).toBe(PackageManager.NPM);
      }
    });
  });

  describe('getInstallCommand', () => {
    it('should generate correct npm install command', () => {
      const cmd = getInstallCommand(PackageManager.NPM, ['express', 'lodash']);
      expect(cmd).toContain('npm install');
      expect(cmd).toContain('express');
      expect(cmd).toContain('lodash');
    });

    it('should include global flag when specified', () => {
      const cmd = getInstallCommand(PackageManager.NPM, ['typescript'], { global: true });
      expect(cmd).toContain('-g');
    });

    it('should include dev flag when specified', () => {
      const cmd = getInstallCommand(PackageManager.NPM, ['jest'], { dev: true });
      expect(cmd).toContain('--save-dev');
    });

    it('should include registry when specified', () => {
      const cmd = getInstallCommand(PackageManager.NPM, ['axios'], {
        registry: 'https://registry.npmmirror.com',
      });
      expect(cmd).toContain('--registry=https://registry.npmmirror.com');
    });

    it('should generate correct yarn command', () => {
      const cmd = getInstallCommand(PackageManager.YARN, ['react']);
      expect(cmd).toContain('yarn add');
      expect(cmd).toContain('react');
    });

    it('should generate correct pnpm command', () => {
      const cmd = getInstallCommand(PackageManager.PNPM, ['vue']);
      expect(cmd).toContain('pnpm add');
      expect(cmd).toContain('vue');
    });

    it('should generate correct bun command', () => {
      const cmd = getInstallCommand(PackageManager.BUN, ['svelte']);
      expect(cmd).toContain('bun add');
      expect(cmd).toContain('svelte');
    });
  });

  describe('getUninstallCommand', () => {
    it('should generate correct npm uninstall command', () => {
      const cmd = getUninstallCommand(PackageManager.NPM, ['express']);
      expect(cmd).toContain('npm uninstall');
      expect(cmd).toContain('express');
    });

    it('should include global flag for uninstall', () => {
      const cmd = getUninstallCommand(PackageManager.NPM, ['typescript'], true);
      expect(cmd).toContain('-g');
    });

    it('should generate correct yarn remove command', () => {
      const cmd = getUninstallCommand(PackageManager.YARN, ['lodash']);
      expect(cmd).toContain('yarn remove');
    });

    it('should generate correct pnpm remove command', () => {
      const cmd = getUninstallCommand(PackageManager.PNPM, ['axios']);
      expect(cmd).toContain('pnpm remove');
    });
  });

  describe('commandExists', () => {
    it('should return true for npm command', async () => {
      const exists = await commandExists('npm');
      expect(exists).toBe(true);
    });

    it('should return false for non-existent command', async () => {
      const exists = await commandExists('non-existent-command-12345');
      expect(exists).toBe(false);
    });
  });
});