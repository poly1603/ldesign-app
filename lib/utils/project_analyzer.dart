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
        author: analysis['author'],
        license: analysis['license'],
        nodeVersion: analysis['nodeVersion'],
        buildTool: analysis['buildTool'],
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
      return await _analyzePythonProject(directoryPath);
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
      final author = _parseAuthor(json['author']);
      final license = json['license'] as String?;
      final engines = json['engines'] as Map<String, dynamic>?;
      final nodeVersion = engines?['node'] as String?;
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
      String? buildTool;
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
          if (allDeps.containsKey('typescript')) tags.add('TypeScript');
        } else if (allDeps.containsKey('gatsby')) {
          framework = ProjectFramework.gatsby;
          tags.add('Gatsby');
          tags.add('Static Site');
        } else if (allDeps.containsKey('remix') || allDeps.containsKey('@remix-run/react')) {
          framework = ProjectFramework.remix;
          tags.add('Remix');
          tags.add('Full-stack');
        } else if (allDeps.containsKey('nuxt') || hasNuxtConfig) {
          framework = ProjectFramework.nuxt;
          tags.add('Nuxt');
          tags.add('Vue Framework');
        } else if (allDeps.containsKey('astro') || hasAstroConfig) {
          framework = ProjectFramework.astro;
          tags.add('Astro');
          tags.add('Static Site');
        } else if (allDeps.containsKey('@builder.io/qwik')) {
          framework = ProjectFramework.qwik;
          tags.add('Qwik');
          tags.add('Resumable');
        } else if (allDeps.containsKey('svelte') || allDeps.containsKey('@sveltejs/kit')) {
          framework = ProjectFramework.svelte;
          tags.add('Svelte');
          if (allDeps.containsKey('@sveltejs/kit')) tags.add('SvelteKit');
        } else if (allDeps.containsKey('solid-js')) {
          framework = ProjectFramework.solidjs;
          tags.add('Solid.js');
          tags.add('Fine-grained');
        } else if (allDeps.containsKey('preact')) {
          framework = ProjectFramework.preact;
          tags.add('Preact');
          tags.add('Lightweight');
        } else if (allDeps.containsKey('react')) {
          framework = ProjectFramework.react;
          tags.add('React');
          if (hasViteConfig) tags.add('Vite');
          if (allDeps.containsKey('react-router-dom')) tags.add('Router');
        } else if (allDeps.containsKey('vue')) {
          framework = ProjectFramework.vue;
          tags.add('Vue');
          if (hasViteConfig) tags.add('Vite');
          if (allDeps.containsKey('vue-router')) tags.add('Router');
        } else if (allDeps.containsKey('@angular/core')) {
          framework = ProjectFramework.angular;
          tags.add('Angular');
          if (allDeps.containsKey('@angular/router')) tags.add('Router');
        } else if (allDeps.containsKey('lit') || allDeps.containsKey('lit-element')) {
          framework = ProjectFramework.lit;
          tags.add('Lit');
          tags.add('Web Components');
        } else if (allDeps.containsKey('stencil') || allDeps.containsKey('@stencil/core')) {
          framework = ProjectFramework.stencil;
          tags.add('Stencil');
          tags.add('Web Components');
        } else if (allDeps.containsKey('alpinejs') || allDeps.containsKey('@alpinejs/core')) {
          framework = ProjectFramework.alpine;
          tags.add('Alpine.js');
          tags.add('Lightweight');
        } else if (allDeps.containsKey('htmx')) {
          framework = ProjectFramework.htmx;
          tags.add('HTMX');
          tags.add('Hypermedia');
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
        
        // Determine build tool (separate from framework)
        if (hasViteConfig || allDeps.containsKey('vite')) {
          buildTool = 'Vite';
          tags.add('Vite');
        } else if (hasWebpackConfig || allDeps.containsKey('webpack')) {
          buildTool = 'Webpack';
          tags.add('Webpack');
        } else if (allDeps.containsKey('rollup')) {
          buildTool = 'Rollup';
          tags.add('Rollup');
        } else if (allDeps.containsKey('parcel')) {
          buildTool = 'Parcel';
          tags.add('Parcel');
        } else if (allDeps.containsKey('turbopack')) {
          buildTool = 'Turbopack';
          tags.add('Turbopack');
        }
        
        // TypeScript detection
        if (allDeps.containsKey('typescript')) {
          tags.remove('JavaScript');
          tags.add('TypeScript');
        }
        
        // Determine if it's a library or application based on type not set yet
        if (type == ProjectType.unknown) {
          // Enhanced project type detection
          final hasUIFramework = allDeps.containsKey('react') || 
                                 allDeps.containsKey('vue') || 
                                 allDeps.containsKey('@angular/core') ||
                                 allDeps.containsKey('svelte') ||
                                 allDeps.containsKey('solid-js') ||
                                 allDeps.containsKey('preact');
          
          // Enhanced application indicators
          final hasAppIndicators = hasPublicDir || hasPagesDir || hasApiDir || 
                                   scripts?.containsKey('dev') == true ||
                                   scripts?.containsKey('start') == true ||
                                   scripts?.containsKey('serve') == true ||
                                   scripts?.containsKey('preview') == true;
          
          // Library indicators - more comprehensive
          final hasStrongLibraryIndicators = hasMain || hasModule || hasExports || 
                                             (isPublished && !isPrivate) ||
                                             scripts?.containsKey('build:lib') == true ||
                                             scripts?.containsKey('prepublishOnly') == true;
          
          // Component library specific indicators
          final hasComponentLibraryIndicators = hasComponentsDir || 
                                               name?.toLowerCase().contains('component') == true ||
                                               name?.toLowerCase().contains('ui') == true ||
                                               name?.toLowerCase().contains('design-system') == true ||
                                               description?.toLowerCase().contains('component') == true ||
                                               description?.toLowerCase().contains('ui library') == true ||
                                               description?.toLowerCase().contains('design system') == true ||
                                               allDeps.containsKey('storybook') ||
                                               allDeps.containsKey('@storybook/react') ||
                                               allDeps.containsKey('@storybook/vue') ||
                                               allDeps.containsKey('@storybook/angular');
          
          // Framework/Engine library indicators
          final hasFrameworkLibraryIndicators = name?.toLowerCase().contains('engine') == true ||
                                                name?.toLowerCase().contains('core') == true ||
                                                name?.toLowerCase().contains('framework') == true ||
                                                description?.toLowerCase().contains('framework') == true ||
                                                description?.toLowerCase().contains('engine') == true ||
                                                description?.toLowerCase().contains('plugin system') == true ||
                                                description?.toLowerCase().contains('middleware') == true ||
                                                description?.toLowerCase().contains('lifecycle') == true;
          
          // Utility library indicators
          final hasUtilityLibraryIndicators = name?.toLowerCase().contains('util') == true ||
                                              name?.toLowerCase().contains('helper') == true ||
                                              name?.toLowerCase().contains('tool') == true ||
                                              name?.toLowerCase().contains('lib') == true ||
                                              description?.toLowerCase().contains('utility') == true ||
                                              description?.toLowerCase().contains('helper') == true ||
                                              description?.toLowerCase().contains('tool') == true;
          
          // Node library indicators
          final hasNodeLibraryIndicators = allDeps.containsKey('@types/node') && 
                                           !hasUIFramework &&
                                           !hasAppIndicators;
          
          if (hasStrongLibraryIndicators || (!hasAppIndicators && (hasMain || hasModule || hasExports))) {
            // It's definitely a library
            if (hasFrameworkLibraryIndicators) {
              type = ProjectType.frameworkLibrary;
              tags.add('Framework');
              if (name?.toLowerCase().contains('engine') == true) {
                tags.add('Engine');
              }
              if (description?.toLowerCase().contains('plugin') == true) {
                tags.add('Plugin System');
              }
            } else if (hasComponentLibraryIndicators && hasUIFramework) {
              type = ProjectType.componentLibrary;
              tags.add('Components');
              if (allDeps.containsKey('storybook') || allDeps.containsKey('@storybook/react')) {
                tags.add('Storybook');
              }
            } else if (hasUtilityLibraryIndicators || (allDeps.length < 5 && !hasUIFramework)) {
              type = ProjectType.utilityLibrary;
              tags.add('Utilities');
            } else if (hasNodeLibraryIndicators) {
              type = ProjectType.nodeLibrary;
              tags.add('Node');
            } else if (hasUIFramework && !hasAppIndicators) {
              // UI library but not specifically component library
              type = ProjectType.componentLibrary;
              tags.add('UI Library');
            } else {
              // Default to utility library for published packages
              type = ProjectType.utilityLibrary;
              tags.add('Library');
            }
          } else if (hasUIFramework && hasAppIndicators) {
            // It's a web application with UI framework
            type = ProjectType.webApp;
            tags.add('Application');
            if (hasSrcDir) tags.add('Structured');
          } else if (hasApiDir || (allDeps.containsKey('express') || allDeps.containsKey('koa') || allDeps.containsKey('fastify'))) {
            // Backend application
            type = ProjectType.backendApp;
            tags.add('API');
          } else if (hasNodeLibraryIndicators) {
            // Node library
            type = ProjectType.nodeLibrary;
            tags.add('Node');
          } else if (hasUIFramework) {
            // Has UI framework but unclear if app or lib - check more indicators
            if (hasPublicDir || hasPagesDir || scripts?.containsKey('dev') == true) {
              type = ProjectType.webApp;
              tags.add('Application');
            } else {
              // Likely a component library or UI library
              type = ProjectType.componentLibrary;
              tags.add('UI Library');
            }
          } else {
            // Default case - try to infer from structure
            if (hasAppIndicators) {
              type = ProjectType.webApp;
              tags.add('Application');
            } else if (hasMain || hasModule) {
              type = ProjectType.utilityLibrary;
              tags.add('Library');
            } else {
              // Last resort - assume web app if has any modern build setup
              type = ProjectType.webApp;
            }
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
        'author': author,
        'license': license,
        'nodeVersion': nodeVersion,
        'buildTool': buildTool,
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
      ProjectFramework framework = ProjectFramework.flutter;
      final tags = <String>['Flutter', 'Dart'];
      
      if (content.contains('window_manager') || content.contains('desktop')) {
        type = ProjectType.desktopApp;
        tags.add('Desktop');
      } else if (content.contains('flutter_web')) {
        framework = ProjectFramework.flutter_web;
        type = ProjectType.webApp;
        tags.add('Web');
      }
      
      return {
        'name': name,
        'description': description,
        'version': version,
        'type': type,
        'framework': framework,
        'language': 'Dart',
        'tags': tags,
      };
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> _analyzePythonProject(String directoryPath) async {
    final tags = <String>['Python'];
    var type = ProjectType.backendApp;
    var framework = ProjectFramework.unknown;
    
    // Check for common Python web frameworks
    final requirementsTxt = File(path.join(directoryPath, 'requirements.txt'));
    if (await requirementsTxt.exists()) {
      final content = await requirementsTxt.readAsString();
      final lines = content.split('\n');
      
      for (final line in lines) {
        final dep = line.trim().toLowerCase();
        if (dep.startsWith('django')) {
          framework = ProjectFramework.django;
          tags.add('Django');
          break;
        } else if (dep.startsWith('fastapi')) {
          framework = ProjectFramework.fastapi;
          tags.add('FastAPI');
          break;
        } else if (dep.startsWith('flask')) {
          framework = ProjectFramework.flask;
          tags.add('Flask');
          break;
        }
      }
    }
    
    // Check for setup.py or pyproject.toml (indicates it's a library)
    final setupPy = File(path.join(directoryPath, 'setup.py'));
    final pyprojectToml = File(path.join(directoryPath, 'pyproject.toml'));
    
    if (await setupPy.exists() || await pyprojectToml.exists()) {
      type = ProjectType.utilityLibrary;
      tags.add('Library');
    }
    
    return {
      'type': type,
      'framework': framework,
      'language': 'Python',
      'tags': tags,
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

  static String? _parseAuthor(dynamic author) {
    if (author == null) return null;
    
    if (author is String) {
      return author;
    } else if (author is Map<String, dynamic>) {
      final name = author['name'] as String?;
      final email = author['email'] as String?;
      if (name != null && email != null) {
        return '$name <$email>';
      } else if (name != null) {
        return name;
      }
    }
    
    return null;
  }
}
