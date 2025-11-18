import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/project.dart';

class ProjectAnalyzer {
  static Future<Project?> analyzeDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return null;
      }

      final projectName = path.basename(directoryPath);
      final lastModified = await _getLastModified(directory);
      
      final analysis = await _analyzeProjectType(directoryPath);
      
      return Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: analysis['name'] ?? projectName,
        path: directoryPath,
        description: analysis['description'],
        type: analysis['type'] ?? ProjectType.unknown,
        framework: analysis['framework'] ?? ProjectFramework.unknown,
        language: analysis['language'],
        version: analysis['version'],
        lastModified: lastModified,
        addedAt: DateTime.now(),
        tags: analysis['tags'] ?? [],
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> _analyzeProjectType(String directoryPath) async {
    final packageJson = File(path.join(directoryPath, 'package.json'));
    if (await packageJson.exists()) {
      return await _analyzeNodeProject(packageJson);
    }

    final pubspecYaml = File(path.join(directoryPath, 'pubspec.yaml'));
    if (await pubspecYaml.exists()) {
      return await _analyzeFlutterProject(pubspecYaml);
    }

    final requirementsTxt = File(path.join(directoryPath, 'requirements.txt'));
    if (await requirementsTxt.exists()) {
      return _analyzePythonProject();
    }

    final pomXml = File(path.join(directoryPath, 'pom.xml'));
    if (await pomXml.exists()) {
      return await _analyzeJavaProject(pomXml);
    }

    return {};
  }

  static Future<Map<String, dynamic>> _analyzeNodeProject(File packageJson) async {
    try {
      final content = await packageJson.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final projectDir = packageJson.parent.path;
      
      final name = json['name'] as String?;
      final description = json['description'] as String?;
      final version = json['version'] as String?;
      final dependencies = json['dependencies'] as Map<String, dynamic>?;
      final devDependencies = json['devDependencies'] as Map<String, dynamic>?;
      
      // Check for config files
      final hasViteConfig = await _fileExists(projectDir, ['vite.config.js', 'vite.config.ts', 'vite.config.mjs']);
      final hasWebpackConfig = await _fileExists(projectDir, ['webpack.config.js', 'webpack.config.ts']);
      final hasNextConfig = await _fileExists(projectDir, ['next.config.js', 'next.config.mjs']);
      final hasNuxtConfig = await _fileExists(projectDir, ['nuxt.config.js', 'nuxt.config.ts']);
      final hasAstroConfig = await _fileExists(projectDir, ['astro.config.mjs', 'astro.config.js']);
      final hasTsConfig = await _fileExists(projectDir, ['tsconfig.json']);
      final hasJestConfig = await _fileExists(projectDir, ['jest.config.js', 'jest.config.ts']);
      final hasVitestConfig = await _fileExists(projectDir, ['vitest.config.js', 'vitest.config.ts']);
      
      // Check directory structure
      final hasPublicDir = await Directory(path.join(projectDir, 'public')).exists();
      final hasSrcDir = await Directory(path.join(projectDir, 'src')).exists();
      final hasComponentsDir = await _directoryExists(projectDir, ['components', 'src/components']);
      final hasPagesDir = await _directoryExists(projectDir, ['pages', 'src/pages']);
      final hasApiDir = await _directoryExists(projectDir, ['api', 'src/api', 'pages/api']);
      final hasAppDir = await _directoryExists(projectDir, ['app', 'src/app']);
      
      ProjectFramework framework = ProjectFramework.unknown;
      ProjectType type = ProjectType.unknown;
      final tags = <String>['JavaScript'];
      
      // Analyze project type based on package.json structure
      final isPrivate = json['private'] == true;
      final hasMain = json['main'] != null;
      final hasModule = json['module'] != null;
      final hasExports = json['exports'] != null;
      final hasBin = json['bin'] != null;
      final hasTypes = json['types'] != null || json['typings'] != null;
      final hasWorkspaces = json['workspaces'] != null;
      final scripts = json['scripts'] as Map<String, dynamic>?;
      
      // Determine project type first
      if (hasWorkspaces) {
        type = ProjectType.monorepo;
        tags.add('Monorepo');
      } else if (hasBin) {
        type = ProjectType.cliTool;
        tags.add('CLI');
      }
      
      if (dependencies != null || devDependencies != null) {
        final allDeps = {...?dependencies, ...?devDependencies};
        
        // Check if it's a library or application
        final hasLibraryIndicators = hasMain || hasModule || hasExports;
        final isPublished = !isPrivate;
        
        // Frontend frameworks - priority order matters, use config files for better detection
        if (allDeps.containsKey('next') || hasNextConfig || hasAppDir) {
          framework = ProjectFramework.nextjs;
          tags.add('Next.js');
          if (hasAppDir) tags.add('App Router');
        } else if (allDeps.containsKey('gatsby')) {
          framework = ProjectFramework.gatsby;
          tags.add('Gatsby');
        } else if (allDeps.containsKey('remix') || allDeps.containsKey('@remix-run/react')) {
          framework = ProjectFramework.remix;
          tags.add('Remix');
        } else if (allDeps.containsKey('nuxt') || hasNuxtConfig) {
          framework = ProjectFramework.nuxt;
          tags.add('Nuxt');
        } else if (allDeps.containsKey('astro') || hasAstroConfig) {
          framework = ProjectFramework.astro;
          tags.add('Astro');
        } else if (allDeps.containsKey('@builder.io/qwik')) {
          framework = ProjectFramework.qwik;
          tags.add('Qwik');
        } else if (allDeps.containsKey('svelte')) {
          framework = ProjectFramework.svelte;
          tags.add('Svelte');
        } else if (allDeps.containsKey('solid-js')) {
          framework = ProjectFramework.solidjs;
          tags.add('Solid.js');
        } else if (allDeps.containsKey('preact')) {
          framework = ProjectFramework.preact;
          tags.add('Preact');
        } else if (allDeps.containsKey('react')) {
          framework = ProjectFramework.react;
          tags.add('React');
          if (hasViteConfig) tags.add('Vite');
        } else if (allDeps.containsKey('vue')) {
          framework = ProjectFramework.vue;
          tags.add('Vue');
          if (hasViteConfig) tags.add('Vite');
        } else if (allDeps.containsKey('@angular/core')) {
          framework = ProjectFramework.angular;
          tags.add('Angular');
        }
        
        // Mobile frameworks
        if (allDeps.containsKey('react-native')) {
          framework = ProjectFramework.reactNative;
          type = ProjectType.mobileApp;
          tags.add('React Native');
        } else if (allDeps.containsKey('@ionic/angular') || allDeps.containsKey('@ionic/react') || allDeps.containsKey('@ionic/vue')) {
          framework = ProjectFramework.ionic;
          type = ProjectType.mobileApp;
          tags.add('Ionic');
        } else if (allDeps.containsKey('@capacitor/core')) {
          framework = ProjectFramework.capacitor;
          type = ProjectType.mobileApp;
          tags.add('Capacitor');
        } else if (allDeps.containsKey('cordova')) {
          framework = ProjectFramework.cordova;
          type = ProjectType.mobileApp;
          tags.add('Cordova');
        }
        
        // Backend frameworks
        if (allDeps.containsKey('@nestjs/core')) {
          framework = ProjectFramework.nestjs;
          type = ProjectType.backendApp;
          tags.add('NestJS');
        } else if (allDeps.containsKey('express')) {
          framework = ProjectFramework.express;
          type = ProjectType.backendApp;
          tags.add('Express');
        } else if (allDeps.containsKey('koa')) {
          framework = ProjectFramework.koa;
          type = ProjectType.backendApp;
          tags.add('Koa');
        } else if (allDeps.containsKey('fastify')) {
          framework = ProjectFramework.fastify;
          type = ProjectType.backendApp;
          tags.add('Fastify');
        }
        
        // Desktop frameworks
        if (allDeps.containsKey('electron')) {
          framework = ProjectFramework.electron;
          type = ProjectType.desktopApp;
          tags.add('Electron');
        }
        
        // Build tools (if no framework detected)
        if (framework == ProjectFramework.unknown) {
          if (allDeps.containsKey('vite')) {
            framework = ProjectFramework.vite;
            tags.add('Vite');
          } else if (allDeps.containsKey('webpack')) {
            framework = ProjectFramework.webpack;
            tags.add('Webpack');
          }
        }
        
        // TypeScript detection
        if (allDeps.containsKey('typescript')) {
          tags.remove('JavaScript');
          tags.add('TypeScript');
        }
        
        // Determine if it's a library or application based on type not set yet
        if (type == ProjectType.unknown) {
          // Check for UI component library indicators
          final hasUIFramework = allDeps.containsKey('react') || 
                                 allDeps.containsKey('vue') || 
                                 allDeps.containsKey('@angular/core') ||
                                 allDeps.containsKey('svelte') ||
                                 allDeps.containsKey('solid-js');
          
          // Application indicators
          final hasAppIndicators = hasPublicDir || hasPagesDir || hasApiDir || 
                                   scripts?.containsKey('dev') == true ||
                                   scripts?.containsKey('start') == true;
          
          if (hasLibraryIndicators && !hasAppIndicators) {
            // It's a library
            if (hasComponentsDir && hasUIFramework && (name?.contains('component') == true || 
                                   name?.contains('ui') == true ||
                                   description?.toLowerCase().contains('component') == true ||
                                   description?.toLowerCase().contains('ui library') == true)) {
              type = ProjectType.componentLibrary;
              tags.add('Components');
            } else if (allDeps.isEmpty || allDeps.length < 3) {
              // Utility library with few dependencies
              type = ProjectType.utilityLibrary;
              tags.add('Utilities');
            } else if (allDeps.containsKey('@types/node') && !hasUIFramework) {
              type = ProjectType.nodeLibrary;
              tags.add('Node');
            } else if (hasUIFramework) {
              // UI library but not specifically component library
              type = ProjectType.componentLibrary;
            } else {
              type = ProjectType.utilityLibrary;
            }
          } else if (hasUIFramework || hasAppIndicators) {
            // It's a web application
            type = ProjectType.webApp;
            tags.add('Application');
            if (hasSrcDir) tags.add('Structured');
          } else if (allDeps.containsKey('@types/node') || hasApiDir) {
            // Node application or API
            if (hasApiDir) {
              type = ProjectType.backendApp;
              tags.add('API');
            } else {
              type = ProjectType.nodeLibrary;
              tags.add('Node');
            }
          } else {
            type = ProjectType.webApp;
          }
        }
        
        // Add testing info to tags
        if (hasJestConfig || allDeps.containsKey('jest')) {
          tags.add('Jest');
        } else if (hasVitestConfig || allDeps.containsKey('vitest')) {
          tags.add('Vitest');
        }
        
        // Add TypeScript tag if tsconfig exists
        if (hasTsConfig && !tags.contains('TypeScript')) {
          tags.remove('JavaScript');
          tags.add('TypeScript');
        }
      }
      
      return {
        'name': name,
        'description': description,
        'version': version,
        'type': type,
        'framework': framework,
        'language': tags.contains('TypeScript') ? 'TypeScript' : 'JavaScript',
        'tags': tags,
      };
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> _analyzeFlutterProject(File pubspecYaml) async {
    try {
      final content = await pubspecYaml.readAsString();
      final lines = content.split('\n');
      String? name;
      String? description;
      String? version;
      
      for (var line in lines) {
        if (line.startsWith('name:')) {
          name = line.split(':').last.trim();
        } else if (line.startsWith('description:')) {
          description = line.split(':').last.trim().replaceAll('"', '');
        } else if (line.startsWith('version:')) {
          version = line.split(':').last.trim();
        }
      }
      
      ProjectType type = ProjectType.mobileApp;
      if (content.contains('window_manager') || content.contains('desktop')) {
        type = ProjectType.desktopApp;
      }
      
      return {
        'name': name,
        'description': description,
        'version': version,
        'type': type,
        'framework': ProjectFramework.flutter,
        'language': 'Dart',
        'tags': ['Flutter', 'Dart'],
      };
    } catch (e) {
      return {};
    }
  }

  static Map<String, dynamic> _analyzePythonProject() {
    return {
      'type': ProjectType.backendApp,
      'framework': ProjectFramework.unknown,
      'language': 'Python',
      'tags': ['Python'],
    };
  }

  static Future<Map<String, dynamic>> _analyzeJavaProject(File pomXml) async {
    try {
      final content = await pomXml.readAsString();
      ProjectFramework framework = ProjectFramework.unknown;
      final tags = <String>['Java'];
      
      if (content.contains('spring-boot')) {
        framework = ProjectFramework.spring;
        tags.add('Spring Boot');
      }
      
      return {
        'type': ProjectType.backendApp,
        'framework': framework,
        'language': 'Java',
        'tags': tags,
      };
    } catch (e) {
      return {};
    }
  }

  static Future<DateTime> _getLastModified(Directory directory) async {
    try {
      var latestTime = directory.statSync().modified;
      await for (final entity in directory.list(recursive: false)) {
        final stat = entity.statSync();
        if (stat.modified.isAfter(latestTime)) {
          latestTime = stat.modified;
        }
      }
      return latestTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper methods
  static Future<bool> _fileExists(String basePath, List<String> filenames) async {
    for (final filename in filenames) {
      if (await File(path.join(basePath, filename)).exists()) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _directoryExists(String basePath, List<String> dirNames) async {
    for (final dirName in dirNames) {
      if (await Directory(path.join(basePath, dirName)).exists()) {
        return true;
      }
    }
    return false;
  }
}
