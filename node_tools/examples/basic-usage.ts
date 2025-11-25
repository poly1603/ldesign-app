/**
 * Basic usage examples for Node Tool Installer
 */

import { install, InstallationType, InstallationConfig } from '../src';

/**
 * Example 1: Simple package installation
 */
async function simpleInstallation() {
  console.log('Example 1: Simple Installation\n');

  const result = await install({
    config: {
      packages: [
        { name: 'lodash', installationType: InstallationType.LOCAL },
      ],
      packageManager: 'npm' as any,
    },
  });

  console.log('Installation status:', result.status);
  console.log('Duration:', result.duration, 'ms\n');
}

/**
 * Example 2: Multiple packages with different types
 */
async function multiplePackages() {
  console.log('Example 2: Multiple Packages\n');

  const result = await install({
    config: {
      packages: [
        { name: 'express', installationType: InstallationType.LOCAL },
        { name: 'typescript', installationType: InstallationType.DEV },
        { name: 'nodemon', installationType: InstallationType.GLOBAL },
      ],
      packageManager: 'npm' as any,
      verbose: true,
    },
    onProgress: (progress) => {
      console.log(`[${progress.percentage.toFixed(0)}%] ${progress.message}`);
    },
  });

  console.log('\nInstallation completed:', result.status);
}

/**
 * Example 3: Installation with specific versions
 */
async function specificVersions() {
  console.log('Example 3: Specific Versions\n');

  const result = await install({
    config: {
      packages: [
        { name: 'react', version: '^18.2.0', installationType: InstallationType.LOCAL },
        { name: 'react-dom', version: '^18.2.0', installationType: InstallationType.LOCAL },
        { name: '@types/react', version: '^18.2.0', installationType: InstallationType.DEV },
      ],
      packageManager: 'npm' as any,
    },
  });

  console.log('Installed packages:', result.packages.length);
}

/**
 * Example 4: Custom configuration with registry
 */
async function customConfiguration() {
  console.log('Example 4: Custom Configuration\n');

  const config: InstallationConfig = {
    packages: [
      { name: 'axios', installationType: InstallationType.LOCAL },
    ],
    packageManager: 'npm' as any,
    registry: 'https://registry.npmmirror.com',
    timeout: 60000,
    retryAttempts: 3,
    verbose: true,
  };

  const result = await install({ config });
  console.log('Result:', result.status);
}

/**
 * Example 5: Error handling
 */
async function errorHandling() {
  console.log('Example 5: Error Handling\n');

  try {
    const result = await install({
      config: {
        packages: [
          { name: 'non-existent-package-12345', installationType: InstallationType.LOCAL },
        ],
        packageManager: 'npm' as any,
      },
      onError: (error) => {
        console.error('Error:', error.message);
        console.log('Suggestions:', error.suggestions);
      },
    });

    if (result.status === 'failed') {
      console.log('Installation failed as expected');
      console.log('Errors:', result.errors.length);
    }
  } catch (error) {
    console.error('Caught error:', error);
  }
}

/**
 * Example 6: Progress tracking
 */
async function progressTracking() {
  console.log('Example 6: Progress Tracking\n');

  const startTime = Date.now();

  await install({
    config: {
      packages: [
        { name: 'chalk', installationType: InstallationType.LOCAL },
        { name: 'ora', installationType: InstallationType.LOCAL },
        { name: 'inquirer', installationType: InstallationType.LOCAL },
      ],
      packageManager: 'npm' as any,
    },
    onProgress: (progress) => {
      const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
      console.log(
        `[${elapsed}s] Stage: ${progress.stage}, ` +
        `Progress: ${progress.percentage.toFixed(0)}%, ` +
        `Message: ${progress.message}`
      );
    },
    onComplete: (result) => {
      console.log(`\nCompleted in ${(result.duration / 1000).toFixed(2)}s`);
    },
  });
}

/**
 * Run all examples
 */
async function runAllExamples() {
  const examples = [
    { name: 'Simple Installation', fn: simpleInstallation },
    { name: 'Multiple Packages', fn: multiplePackages },
    { name: 'Specific Versions', fn: specificVersions },
    { name: 'Custom Configuration', fn: customConfiguration },
    { name: 'Error Handling', fn: errorHandling },
    { name: 'Progress Tracking', fn: progressTracking },
  ];

  for (const example of examples) {
    console.log('='.repeat(60));
    console.log(`Running: ${example.name}`);
    console.log('='.repeat(60));

    try {
      await example.fn();
    } catch (error) {
      console.error(`Example failed:`, error);
    }

    console.log('\n');
  }
}

// Run examples if this file is executed directly
if (require.main === module) {
  runAllExamples().catch(console.error);
}

export {
  simpleInstallation,
  multiplePackages,
  specificVersions,
  customConfiguration,
  errorHandling,
  progressTracking,
};