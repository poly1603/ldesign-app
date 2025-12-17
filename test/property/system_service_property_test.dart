import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/git_environment.dart';
import 'package:flutter_toolbox/data/models/node_environment.dart';
import 'package:flutter_toolbox/data/services/system_service.dart';

void main() {
  group('SystemService Property Tests', () {
    /// **Feature: flutter-toolbox-app, Property 10: npm 包列表解析正确性**
    /// **Validates: Requirements 4.4**
    group('npm list parsing', () {
      test('Parses valid npm list output correctly', () {
        const output = '''
{
  "dependencies": {
    "npm": {
      "version": "9.6.7"
    },
    "typescript": {
      "version": "5.0.4"
    },
    "pnpm": {
      "version": "8.6.0"
    }
  }
}
''';
        final packages = SystemServiceImpl.parseNpmListOutput(output);

        expect(packages.length, equals(3));
        expect(packages.any((p) => p.name == 'npm' && p.version == '9.6.7'), isTrue);
        expect(packages.any((p) => p.name == 'typescript' && p.version == '5.0.4'), isTrue);
        expect(packages.any((p) => p.name == 'pnpm' && p.version == '8.6.0'), isTrue);
      });

      test('Parses empty dependencies correctly', () {
        const output = '{"dependencies": {}}';
        final packages = SystemServiceImpl.parseNpmListOutput(output);
        expect(packages, isEmpty);
      });

      test('Handles missing dependencies key', () {
        const output = '{}';
        final packages = SystemServiceImpl.parseNpmListOutput(output);
        expect(packages, isEmpty);
      });

      test('Handles invalid JSON gracefully', () {
        const output = 'not valid json';
        final packages = SystemServiceImpl.parseNpmListOutput(output);
        expect(packages, isEmpty);
      });

      test('Handles malformed JSON gracefully', () {
        const output = '{"dependencies": "not an object"}';
        final packages = SystemServiceImpl.parseNpmListOutput(output);
        expect(packages, isEmpty);
      });

      test('Parses packages with missing version', () {
        const output = '''
{
  "dependencies": {
    "package-without-version": {}
  }
}
''';
        final packages = SystemServiceImpl.parseNpmListOutput(output);
        expect(packages.length, equals(1));
        expect(packages.first.name, equals('package-without-version'));
        expect(packages.first.version, equals(''));
      });

      test('All parsed packages have name and version - property test', () {
        // 生成多种有效的 npm list 输出格式
        final testCases = [
          '{"dependencies": {"pkg1": {"version": "1.0.0"}}}',
          '{"dependencies": {"pkg1": {"version": "1.0.0"}, "pkg2": {"version": "2.0.0"}}}',
          '{"dependencies": {"@scope/pkg": {"version": "3.0.0"}}}',
          '{"dependencies": {"pkg-with-dash": {"version": "0.0.1"}}}',
        ];

        for (final output in testCases) {
          final packages = SystemServiceImpl.parseNpmListOutput(output);
          for (final pkg in packages) {
            expect(pkg.name, isNotEmpty, reason: 'Package name should not be empty');
            expect(pkg.version, isA<String>(), reason: 'Package version should be a string');
          }
        }
      });
    });

    /// **Feature: flutter-toolbox-app, Property 11: Git 配置解析正确性**
    /// **Validates: Requirements 5.2**
    group('Git config parsing', () {
      test('Parses valid git config output correctly', () {
        const output = '''
user.name=John Doe
user.email=john@example.com
''';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, equals('John Doe'));
        expect(config.userEmail, equals('john@example.com'));
      });

      test('Handles missing user.name', () {
        const output = 'user.email=john@example.com';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, isNull);
        expect(config.userEmail, equals('john@example.com'));
      });

      test('Handles missing user.email', () {
        const output = 'user.name=John Doe';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, equals('John Doe'));
        expect(config.userEmail, isNull);
      });

      test('Handles empty output', () {
        const output = '';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, isNull);
        expect(config.userEmail, isNull);
      });

      test('Handles output with extra whitespace', () {
        const output = '''
  user.name=John Doe  
  user.email=john@example.com  
''';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, equals('John Doe'));
        expect(config.userEmail, equals('john@example.com'));
      });

      test('Handles email with special characters', () {
        const output = 'user.email=john+test@example.com';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userEmail, equals('john+test@example.com'));
      });

      test('Handles name with spaces', () {
        const output = 'user.name=John Michael Doe';
        final config = SystemServiceImpl.parseGitConfigOutput(output);

        expect(config.userName, equals('John Michael Doe'));
      });
    });

    group('Model serialization', () {
      test('NpmPackage round trip', () {
        const original = NpmPackage(name: 'test-package', version: '1.0.0');
        final json = original.toJson();
        final restored = NpmPackage.fromJson(json);

        expect(restored.name, equals(original.name));
        expect(restored.version, equals(original.version));
      });

      test('GitConfig round trip', () {
        const original = GitConfig(userName: 'John', userEmail: 'john@test.com');
        final json = original.toJson();
        final restored = GitConfig.fromJson(json);

        expect(restored.userName, equals(original.userName));
        expect(restored.userEmail, equals(original.userEmail));
      });

      test('NodeEnvironment round trip', () {
        const original = NodeEnvironment(
          nodeVersion: '18.0.0',
          nodePath: '/usr/bin/node',
          npmVersion: '9.0.0',
          pnpmVersion: '8.0.0',
          yarnVersion: '1.22.0',
          globalPackages: [NpmPackage(name: 'npm', version: '9.0.0')],
          isInstalled: true,
        );
        final json = original.toJson();
        final restored = NodeEnvironment.fromJson(json);

        expect(restored.nodeVersion, equals(original.nodeVersion));
        expect(restored.nodePath, equals(original.nodePath));
        expect(restored.npmVersion, equals(original.npmVersion));
        expect(restored.isInstalled, equals(original.isInstalled));
        expect(restored.globalPackages.length, equals(1));
      });

      test('GitEnvironment round trip', () {
        const original = GitEnvironment(
          gitVersion: '2.40.0',
          gitPath: '/usr/bin/git',
          config: GitConfig(userName: 'John', userEmail: 'john@test.com'),
          isInstalled: true,
        );
        final json = original.toJson();
        final restored = GitEnvironment.fromJson(json);

        expect(restored.gitVersion, equals(original.gitVersion));
        expect(restored.gitPath, equals(original.gitPath));
        expect(restored.isInstalled, equals(original.isInstalled));
        expect(restored.config.userName, equals(original.config.userName));
      });
    });
  });
}
