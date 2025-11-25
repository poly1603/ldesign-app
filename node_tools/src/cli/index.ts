#!/usr/bin/env node

/**
 * CLI interface for Node Tool Installer
 */

import { Command } from 'commander';
import chalk from 'chalk';
import inquirer from 'inquirer';
import { install } from '../core/installer';
import {
  InstallationConfig,
  PackageManager,
  InstallationType,
  InstallationProgress,
  InstallationError,
} from '../types/installer.types';
import { createLogger } from '../utils/logger';
import { getSystemInfo, checkSystemCompatibility } from '../core/system-detector';
import { detectAvailablePackageManagers } from '../core/package-manager';

const program = new Command();

program
  .name('node-installer')
  .description('Cross-platform automated tool installation system for Node.js')
  .version('1.0.0');

program
  .command('install <packages...>')
  .description('Install one or more packages')
  .option('-g, --global', 'Install packages globally')
  .option('-D, --dev', 'Install as dev dependencies')
  .option('-p, --package-manager <manager>', 'Preferred package manager (npm, yarn, pnpm, bun)')
  .option('-f, --force', 'Force installation')
  .option('--offline', 'Run in offline mode')
  .option('-r, --registry <url>', 'Custom registry URL')
  .option('--no-preflight', 'Skip preflight checks')
  .option('-v, --verbose', 'Verbose output')
  .option('-s, --silent', 'Silent mode')
  .option('--timeout <ms>', 'Installation timeout in milliseconds', '300000')
  .action(async (packages: string[], options) => {
    try {
      const logger = createLogger({
        level: options.verbose ? 'debug' as any : 'info' as any,
        silent: options.silent,
      });

      console.log(chalk.blue.bold('\n🚀 Node Tool Installer\n'));

      // Parse packages with versions
      const parsedPackages = packages.map((pkg) => {
        const match = pkg.match(/^(@?[^@]+)(?:@(.+))?$/);
        return {
          name: match?.[1] || pkg,
          version: match?.[2],
          installationType: options.global
            ? InstallationType.GLOBAL
            : options.dev
            ? InstallationType.DEV
            : InstallationType.LOCAL,
        };
      });

      const config: InstallationConfig = {
        packages: parsedPackages,
        packageManager: options.packageManager as PackageManager,
        preferredPackageManager: options.packageManager as PackageManager,
        autoDetectPackageManager: !options.packageManager,
        force: options.force,
        offline: options.offline,
        registry: options.registry,
        skipPreflightChecks: !options.preflight,
        verbose: options.verbose,
        silent: options.silent,
        timeout: parseInt(options.timeout),
      };

      const result = await install({
        config,
        onProgress: (progress: InstallationProgress) => {
          if (!options.silent) {
            console.log(
              chalk.cyan(`[${progress.percentage.toFixed(0)}%]`),
              progress.message
            );
          }
        },
        onError: (error: InstallationError) => {
          console.error(chalk.red(`❌ Error: ${error.message}`));
          if (error.suggestions.length > 0) {
            console.log(chalk.yellow('\nSuggestions:'));
            error.suggestions.forEach((suggestion) => {
              console.log(chalk.yellow(`  • ${suggestion}`));
            });
          }
        },
        onWarning: (warning: string) => {
          console.warn(chalk.yellow(`⚠️  Warning: ${warning}`));
        },
        onComplete: (result) => {
          console.log(
            chalk.green.bold(
              `\n✅ Installation completed in ${(result.duration / 1000).toFixed(2)}s`
            )
          );
          console.log(
            chalk.gray(`   Installed ${result.packages.length} package(s)`)
          );
        },
      });

      if (result.status === 'failed') {
        process.exit(1);
      }
    } catch (error) {
      console.error(chalk.red('\n❌ Installation failed:'), error);
      process.exit(1);
    }
  });

program
  .command('check')
  .description('Check system compatibility and requirements')
  .action(async () => {
    try {
      console.log(chalk.blue.bold('\n🔍 System Compatibility Check\n'));

      const systemInfo = await getSystemInfo();
      const compatibility = await checkSystemCompatibility();

      console.log(chalk.cyan('System Information:'));
      console.log(`  OS: ${systemInfo.os} (${systemInfo.platform})`);
      console.log(`  Architecture: ${systemInfo.arch}`);
      console.log(`  Node.js: ${process.version}`);
      console.log(`  CPU Cores: ${systemInfo.cpuCores}`);
      console.log(
        `  Memory: ${(systemInfo.totalMemory / (1024 * 1024 * 1024)).toFixed(2)}GB total, ${(systemInfo.freeMemory / (1024 * 1024 * 1024)).toFixed(2)}GB free`
      );
      console.log(`  Container: ${systemInfo.isContainer ? 'Yes' : 'No'}`);
      console.log(`  CI Environment: ${systemInfo.isCI ? 'Yes' : 'No'}`);

      const managers = await detectAvailablePackageManagers();
      console.log(chalk.cyan('\nAvailable Package Managers:'));
      managers.forEach((manager) => {
        console.log(`  ✓ ${manager}`);
      });

      if (compatibility.compatible) {
        console.log(chalk.green.bold('\n✅ System is compatible\n'));
      } else {
        console.log(chalk.red.bold('\n❌ System compatibility issues:\n'));
        compatibility.issues.forEach((issue) => {
          console.log(chalk.red(`  • ${issue}`));
        });
      }

      if (compatibility.warnings.length > 0) {
        console.log(chalk.yellow('\n⚠️  Warnings:\n'));
        compatibility.warnings.forEach((warning) => {
          console.log(chalk.yellow(`  • ${warning}`));
        });
      }

      if (!compatibility.compatible) {
        process.exit(1);
      }
    } catch (error) {
      console.error(chalk.red('Failed to check system:'), error);
      process.exit(1);
    }
  });

program
  .command('interactive')
  .alias('i')
  .description('Interactive installation wizard')
  .action(async () => {
    try {
      console.log(chalk.blue.bold('\n✨ Interactive Installation Wizard\n'));

      const answers = await inquirer.prompt([
        {
          type: 'input',
          name: 'packages',
          message: 'Enter package names (space-separated):',
          validate: (input) => {
            if (input.trim().length === 0) {
              return 'Please enter at least one package name';
            }
            return true;
          },
        },
        {
          type: 'list',
          name: 'installationType',
          message: 'Installation type:',
          choices: ['Local', 'Global', 'Dev Dependency'],
          default: 'Local',
        },
        {
          type: 'list',
          name: 'packageManager',
          message: 'Package manager:',
          choices: async () => {
            const managers = await detectAvailablePackageManagers();
            return ['Auto-detect', ...managers];
          },
          default: 'Auto-detect',
        },
        {
          type: 'confirm',
          name: 'force',
          message: 'Force installation?',
          default: false,
        },
        {
          type: 'confirm',
          name: 'verbose',
          message: 'Verbose output?',
          default: false,
        },
      ]);

      const packages = answers.packages.split(/\s+/).map((pkg: string) => ({
        name: pkg,
        installationType:
          answers.installationType === 'Global'
            ? InstallationType.GLOBAL
            : answers.installationType === 'Dev Dependency'
            ? InstallationType.DEV
            : InstallationType.LOCAL,
      }));

      const config: InstallationConfig = {
        packages,
        packageManager:
          answers.packageManager === 'Auto-detect'
            ? PackageManager.NPM
            : (answers.packageManager as PackageManager),
        autoDetectPackageManager: answers.packageManager === 'Auto-detect',
        force: answers.force,
        verbose: answers.verbose,
      };

      console.log(chalk.cyan('\nStarting installation...\n'));

      await install({
        config,
        onProgress: (progress: InstallationProgress) => {
          console.log(
            chalk.cyan(`[${progress.percentage.toFixed(0)}%]`),
            progress.message
          );
        },
        onComplete: (result) => {
          console.log(
            chalk.green.bold(
              `\n✅ Installation completed in ${(result.duration / 1000).toFixed(2)}s`
            )
          );
        },
      });
    } catch (error) {
      console.error(chalk.red('Interactive installation failed:'), error);
      process.exit(1);
    }
  });

program.parse(process.argv);