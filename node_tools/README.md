# Node Tool Installer

A comprehensive, cross-platform automated tool installation system for Node.js that works seamlessly across all operating systems (Windows, macOS, Linux) without requiring user intervention.

## Features

✨ **Fully Automated** - Zero user intervention required
🌍 **Cross-Platform** - Works on Windows, macOS, Linux, and various distributions
📦 **Multi-Package Manager Support** - npm, yarn, pnpm, and bun
🔒 **Automatic Privilege Escalation** - Handles sudo/UAC automatically
🌐 **Network Resilience** - Proxy support, offline mode, retry mechanisms
🔍 **Pre-flight Checks** - Validates system requirements before installation
📊 **Progress Tracking** - Real-time installation progress and logging
🐳 **Container Support** - Works in Docker, Kubernetes, and CI environments
♻️ **Rollback Capability** - Safe rollback on installation failures
🛡️ **Error Handling** - Comprehensive error handling with automatic fallbacks

## Installation

```bash
npm install @ldesign/node-tool-installer
# or
yarn add @ldesign/node-tool-installer
# or
pnpm add @ldesign/node-tool-installer
```

## Quick Start

### Programmatic API

```typescript
import { install, InstallationType } from '@ldesign/node-tool-installer';

// Simple installation
const result = await install({
  config: {
    packages: [
      { name: 'express', installationType: InstallationType.LOCAL },
      { name: 'typescript', installationType: InstallationType.DEV },
    ],
    packageManager: 'npm',
  },
});

console.log(result.status); // 'completed' or 'failed'
```

### CLI Usage

```bash
# Install packages
node-installer install express typescript lodash

# Install globally
node-installer install -g typescript

# Install as dev dependencies
node-installer install -D jest @types/node

# Interactive mode
node-installer interactive

# Check system compatibility
node-installer check

# Use specific package manager
node-installer install express --package-manager yarn

# Verbose output
node-installer install express -v

# Force installation
node-installer install express --force
```

## Advanced Usage

### With Progress Tracking

```typescript
import { install, InstallationType, InstallationProgress } from '@ldesign/node-tool-installer';

const result = await install({
  config: {
    packages: [
      { name: 'react', version: '^18.0.0', installationType: InstallationType.LOCAL },
      { name: 'react-dom', version: '^18.0.0', installationType: InstallationType.LOCAL },
    ],
    packageManager: 'npm',
    verbose: true,
  },
  onProgress: (progress: InstallationProgress) => {
    console.log(`[${progress.percentage.toFixed(0)}%] ${progress.message}`);
  },
  onError: (error) => {
    console.error('Installation error:', error.message);
    console.log('Suggestions:', error.suggestions);
  },
  onWarning: (warning) => {
    console.warn('Warning:', warning);
  },
  onComplete: (result) => {
    console.log(`Installation completed in ${result.duration}ms`);
  },
});
```

### Custom Configuration

```typescript
import { install, InstallationConfig, PackageManager } from '@ldesign/node-tool-installer';

const config: InstallationConfig = {
  packages: [
    { name: 'axios', installationType: InstallationType.LOCAL },
  ],
  packageManager: PackageManager.PNPM,
  preferredPackageManager: PackageManager.PNPM,
  autoDetectPackageManager: false,
  workingDirectory: '/path/to/project',
  timeout: 300000, // 5 minutes
  retryAttempts: 3,
  retryDelay: 1000,
  skipPreflightChecks: false,
  skipPostInstallScripts: false,
  force: false,
  offline: false,
  verbose: true,
  silent: false,
  registry: 'https://registry.npmmirror.com',
  proxyConfig: {
    httpProxy: 'http://proxy.example.com:8080',
    httpsProxy: 'https://proxy.example.com:8080',
    noProxy: ['localhost', '127.0.0.1'],
    strictSSL: true,
  },
  useCache: true,
  cleanCache: false,
};

const result = await install({ config });
```

### System Detection

```typescript
import { getSystemInfo, checkSystemCompatibility } from '@ldesign/node-tool-installer';

// Get detailed system information
const systemInfo = await getSystemInfo();
console.log('OS:', systemInfo.os);
console.log('Architecture:', systemInfo.arch);
console.log('Container:', systemInfo.isContainer);
console.log('CI:', systemInfo.isCI);
console.log('Admin Rights:', systemInfo.hasAdminRights);

// Check compatibility
const compatibility = await checkSystemCompatibility();
if (!compatibility.compatible) {
  console.error('System compatibility issues:', compatibility.issues);
}
```

### Package Manager Detection

```typescript
import {
  detectPackageManager,
  detectAvailablePackageManagers,
  getPackageManagerVersion,
} from '@ldesign/node-tool-installer';

// Auto-detect package manager
const packageManager = await detectPackageManager();
console.log('Detected:', packageManager);

// Get all available package managers
const available = await detectAvailablePackageManagers();
console.log('Available:', available);

// Get version
const version = await getPackageManagerVersion('npm');
console.log('npm version:', version);
```

### Error Handling

```typescript
import { install, InstallationStatus } from '@ldesign/node-tool-installer';

try {
  const result = await install({
    config: {
      packages: [{ name: 'some-package', installationType: InstallationType.LOCAL }],
      packageManager: 'npm',
    },
  });

  if (result.status === InstallationStatus.FAILED) {
    console.error('Installation failed');
    
    // Check errors
    for (const error of result.errors) {
      console.error(`Error ${error.code}: ${error.message}`);
      
      if (error.recoverable) {
        console.log('This error is recoverable. Suggestions:');
        error.suggestions.forEach(s => console.log(`  - ${s}`));
      }
    }
    
    // Check warnings
    for (const warning of result.warnings) {
      console.warn('Warning:', warning);
    }
  }
} catch (error) {
  console.error('Unexpected error:', error);
}
```

### Privilege Management

```typescript
import {
  executeWithPrivileges,
  checkPrivileges,
  installWithPrivileges,
} from '@ldesign/node-tool-installer';

// Check current privileges
const hasPrivileges = await checkPrivileges();
console.log('Has admin/root:', hasPrivileges);

// Execute command with automatic elevation
const result = await executeWithPrivileges('npm install -g typescript', {
  promptMessage: 'TypeScript needs admin access for global installation',
});

// Install with automatic elevation if needed
const installResult = await installWithPrivileges('npm install -g some-package');
console.log('Elevation used:', installResult.elevationUsed);
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `packages` | `PackageInfo[]` | - | Packages to install |
| `packageManager` | `PackageManager` | Auto-detect | Package manager to use |
| `workingDirectory` | `string` | `process.cwd()` | Working directory |
| `timeout` | `number` | `300000` | Installation timeout (ms) |
| `retryAttempts` | `number` | `3` | Number of retry attempts |
| `retryDelay` | `number` | `1000` | Delay between retries (ms) |
| `skipPreflightChecks` | `boolean` | `false` | Skip preflight checks |
| `force` | `boolean` | `false` | Force installation |
| `offline` | `boolean` | `false` | Offline mode |
| `verbose` | `boolean` | `false` | Verbose output |
| `silent` | `boolean` | `false` | Silent mode |
| `registry` | `string` | - | Custom registry URL |
| `useCache` | `boolean` | `true` | Use package cache |

## System Requirements

- **Node.js**: 14.x or higher (16.x+ recommended)
- **Operating Systems**: 
  - Windows 10/11
  - macOS 10.14+
  - Linux (Ubuntu, Debian, CentOS, RHEL, Fedora, Alpine, Arch)
- **Package Managers**: At least one of npm, yarn, pnpm, or bun
- **Disk Space**: Minimum 500MB free space
- **Network**: Internet connection (unless using offline mode)

## Container Support

Works seamlessly in containerized environments:

```dockerfile
# Example Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install the tool installer
RUN npm install -g @ldesign/node-tool-installer

# Use it to install dependencies
RUN node-installer install express --silent

COPY . .

CMD ["node", "server.js"]
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Install Dependencies
on: [push]
jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npx @ldesign/node-tool-installer install express typescript
```

### GitLab CI

```yaml
install_dependencies:
  script:
    - npm install -g @ldesign/node-tool-installer
    - node-installer install express typescript --silent
```

## Troubleshooting

### Permission Errors

The installer automatically handles privilege escalation. If you encounter permission errors:

```bash
# The installer will automatically prompt for admin/sudo access
node-installer install -g typescript
```

### Network Issues

```bash
# Use a custom registry
node-installer install express --registry https://registry.npmmirror.com

# Use offline mode with cached packages
node-installer install express --offline
```

### Disk Space Issues

```bash
# Check system before installation
node-installer check

# Clean package manager cache
npm cache clean --force
# or
yarn cache clean
```

## API Reference

See [API.md](./docs/API.md) for complete API documentation.

## Architecture

See [ARCHITECTURE.md](./docs/ARCHITECTURE.md) for system architecture details.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](./docs/CONTRIBUTING.md).

## License

MIT License - see [LICENSE](./LICENSE) for details.

## Support

- 📧 Email: support@ldesign.tools
- 🐛 Issues: [GitHub Issues](https://github.com/ldesign/node-tool-installer/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/ldesign/node-tool-installer/discussions)

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.