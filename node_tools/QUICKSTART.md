# Quick Start Guide

## Installation

```bash
cd node_tools
npm install
```

## Build the Project

```bash
npm run build
```

## Run Tests

```bash
npm test
```

## Usage Examples

### 1. CLI Usage

```bash
# Check system compatibility
node dist/cli/index.js check

# Install packages
node dist/cli/index.js install express typescript lodash

# Install globally
node dist/cli/index.js install -g typescript

# Install as dev dependencies
node dist/cli/index.js install -D jest @types/node

# Interactive mode
node dist/cli/index.js interactive

# With custom options
node dist/cli/index.js install express --package-manager yarn --verbose
```

### 2. Programmatic Usage

```typescript
import { install, InstallationType } from './src';

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

console.log('Status:', result.status);
console.log('Duration:', result.duration, 'ms');
```

### 3. With Progress Tracking

```typescript
import { install, InstallationType } from './src';

const result = await install({
  config: {
    packages: [
      { name: 'react', version: '^18.0.0', installationType: InstallationType.LOCAL },
    ],
    packageManager: 'npm',
  },
  onProgress: (progress) => {
    console.log(`[${progress.percentage.toFixed(0)}%] ${progress.message}`);
  },
  onError: (error) => {
    console.error('Error:', error.message);
  },
  onComplete: (result) => {
    console.log('Installation completed!');
  },
});
```

## Project Structure

```
node_tools/
├── src/
│   ├── types/              # TypeScript type definitions
│   ├── core/               # Core functionality
│   │   ├── installer.ts           # Main installer
│   │   ├── system-detector.ts     # System detection
│   │   ├── package-manager.ts     # Package manager operations
│   │   └── privilege-manager.ts   # Privilege escalation
│   ├── utils/              # Utility functions
│   │   ├── logger.ts              # Logging system
│   │   ├── network.ts             # Network operations
│   │   └── process.ts             # Process execution
│   ├── checkers/           # Pre-flight checks
│   │   └── disk-space.ts          # Disk space checker
│   ├── cli/                # CLI interface
│   │   └── index.ts               # CLI entry point
│   └── index.ts            # Main entry point
├── tests/                  # Test files
├── examples/               # Usage examples
├── dist/                   # Compiled output
└── docs/                   # Documentation
```

## Key Features Implementation

### 1. Cross-Platform Support
- Automatic OS detection (Windows, macOS, Linux)
- Platform-specific command generation
- Container and CI environment detection

### 2. Package Manager Support
- Auto-detection of npm, yarn, pnpm, bun
- Lock file-based detection
- Flexible manager selection

### 3. Privilege Management
- Automatic sudo/UAC elevation when needed
- Platform-specific elevation methods
- Permission checks before installation

### 4. Network Handling
- Proxy configuration support
- Offline mode with cached packages
- Retry mechanisms with exponential backoff
- Registry connectivity checks

### 5. Error Handling
- Comprehensive error reporting
- Recoverable vs. critical errors
- Automatic fallback mechanisms
- Detailed error suggestions

### 6. Pre-flight Checks
- Disk space validation
- Network connectivity checks
- System compatibility validation
- Node.js version verification

### 7. Progress Tracking
- Real-time installation progress
- Stage-based tracking
- Time estimation
- Detailed logging

## Development Commands

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Watch mode
npm run dev

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage

# Lint code
npm run lint

# Format code
npm run format
```

## Testing

The project includes comprehensive unit tests:

```bash
# Run all tests
npm test

# Run specific test file
npm test -- system-detector.test.ts

# Run with coverage
npm run test:coverage
```

## Configuration

Create a configuration object:

```typescript
const config: InstallationConfig = {
  packages: [
    { name: 'express', installationType: InstallationType.LOCAL },
  ],
  packageManager: PackageManager.NPM,
  timeout: 300000,
  retryAttempts: 3,
  verbose: true,
  registry: 'https://registry.npmmirror.com',
};
```

## Troubleshooting

### Permission Errors
The installer handles privilege elevation automatically. If issues persist:
- On Windows: Run as Administrator
- On Unix: Ensure sudo is available

### Network Issues
```bash
# Use custom registry
node dist/cli/index.js install express --registry https://registry.npmmirror.com

# Use offline mode
node dist/cli/index.js install express --offline
```

### Disk Space
```bash
# Check available space
node dist/cli/index.js check
```

## Next Steps

1. Read the full [README.md](./README.md)
2. Check out [examples](./examples/)
3. Review [API documentation](./docs/API.md)
4. See [Architecture](./docs/ARCHITECTURE.md)

## Support

- GitHub Issues: Report bugs and request features
- Documentation: Read the full docs
- Examples: Check the examples folder