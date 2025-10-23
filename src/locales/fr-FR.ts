/**
 * Pack de langue française (French Language Pack)
 */

export default {
  // Thèmes personnalisés
  customThemes: {
    sunset: 'Orange Coucher de Soleil',
    forest: 'Vert Forêt',
    midnight: 'Bleu Minuit',
    lavender: 'Rêve de Lavande',
    coral: 'Récif de Corail'
  },

  // Informations de l'application
  app: {
    name: 'LDesign Application Simple',
    title: 'LDesign Application Simple',
    description: 'Application exemple construite avec LDesign Engine',
    copyright: '© 2024 LDesign. Tous droits réservés.'
  },

  // Menu de navigation
  nav: {
    home: 'Accueil',
    about: 'À propos',
    crypto: 'Démo Crypto',
    http: 'Démo HTTP',
    api: 'Démo API',
    dashboard: 'Tableau de bord',
    login: 'Connexion',
    logout: 'Déconnexion',
    language: 'Langue',
    performance: 'Performances',
    state: 'État',
    event: 'Événements',
    concurrency: 'Concurrence',
    plugin: 'Plugins',
    demos: 'Démos fonctionnalités',
    engineDemos: 'Démos Engine'
  },

  // Page d'accueil
  home: {
    title: 'Bienvenue sur LDesign',
    subtitle: 'Framework Frontend Moderne et Haute Performance',
    description: 'Ceci est un exemple d\'application simple construite avec @ldesign/engine',
    demos: {
      title: 'Démos des fonctionnalités',
      crypto: {
        title: 'Démo Crypto',
        description: 'Découvrez AES, RSA, algorithmes de hachage et autres fonctionnalités de chiffrement'
      },
      http: {
        title: 'Démo HTTP',
        description: 'Découvrez les requêtes réseau, les intercepteurs, le cache et d\'autres fonctionnalités'
      },
      api: {
        title: 'Démo API',
        description: 'Découvrez le moteur API, le système de plugins, les requêtes batch et autres fonctionnalités'
      }
    },
    features: {
      title: 'Fonctionnalités principales',
      list: {
        performance: 'Performance extrême',
        performanceDesc: 'Construit sur Vue 3, offrant d\'excellentes performances d\'exécution',
        modular: 'Architecture modulaire',
        modularDesc: 'Système de plugins flexible avec chargement à la demande',
        typescript: 'Support TypeScript',
        typescriptDesc: 'Définitions de types complètes pour la meilleure expérience de développement'
      }
    },
    getStarted: 'Commencer',
    learnMore: 'En savoir plus',
    viewDocs: 'Voir la documentation',
    currentTime: 'Heure actuelle',
    welcomeMessage: 'Bonjour, {name} ! Bienvenue sur LDesign.',
    stats: {
      routes: 'Routes',
      visits: 'Visites',
      cacheSize: 'Taille du cache'
    }
  },

  // Page À propos
  about: {
    title: 'À propos de LDesign',
    subtitle: 'En savoir plus sur ce projet',
    description: 'LDesign est un framework frontend moderne conçu pour offrir la meilleure expérience de développement et performance.',
    version: 'Version',
    author: 'Auteur',
    license: 'Licence',
    repository: 'Dépôt',
    techStack: 'Stack technique',
    goals: {
      title: 'Nos objectifs',
      api: 'Fournir une API simple mais puissante',
      performance: 'Optimiser les performances, réduire l\'utilisation de la mémoire',
      typescript: 'Support TypeScript complet',
      integration: 'Intégration profonde avec @ldesign/engine',
      extensible: 'Extensions de fonctionnalités riches'
    },
    features: {
      title: 'Caractéristiques principales',
      items: {
        vue3: 'Basé sur Vue 3',
        vite: 'Outil de build Vite',
        typescript: 'Support TypeScript',
        i18n: 'Internationalisation',
        router: 'Système de routeur intelligent',
        engine: 'Noyau Engine puissant'
      },
      vue3Desc: 'Construit sur Vue 3, offrant d\'excellentes performances',
      viteDesc: 'Serveur de développement rapide et outil de build',
      i18nDesc: 'Support d\'internationalisation complet'
    },
    team: {
      title: 'Équipe de développement',
      description: 'Maintenu par un groupe de développeurs passionnés'
    },
    contact: {
      title: 'Nous contacter',
      email: 'Email',
      github: 'GitHub',
      website: 'Site web',
      community: 'Communauté'
    }
  },

  // Page de connexion
  login: {
    title: 'Bienvenue',
    subtitle: 'Veuillez entrer vos informations de compte',
    username: 'Nom d\'utilisateur',
    password: 'Mot de passe',
    usernamePlaceholder: 'Entrez votre nom d\'utilisateur',
    passwordPlaceholder: 'Entrez votre mot de passe',
    rememberMe: 'Se souvenir de moi',
    forgotPassword: 'Mot de passe oublié ?',
    submit: 'Connexion',
    submitting: 'Connexion en cours...',
    noAccount: 'Pas de compte ?',
    register: 'S\'inscrire maintenant',
    or: 'ou',
    loginWith: 'Se connecter avec {provider}',
    modes: {
      password: 'Mot de passe',
      sms: 'SMS',
      qrcode: 'QR Code'
    },
    placeholders: {
      username: 'Nom d\'utilisateur / Email',
      password: 'Mot de passe',
      phone: 'Numéro de téléphone',
      smsCode: 'Code de vérification'
    },
    providers: {
      wechat: 'WeChat',
      github: 'GitHub',
      google: 'Google'
    },
    qrcode: {
      loading: 'Chargement du QR Code...',
      tip: 'Scannez avec l\'application mobile pour vous connecter',
      refresh: 'Actualiser le QR Code'
    },
    errors: {
      required: 'Veuillez remplir les champs requis',
      invalid: 'Nom d\'utilisateur ou mot de passe invalide',
      failed: 'Échec de la connexion, veuillez réessayer',
      phoneRequired: 'Veuillez entrer le numéro de téléphone',
      invalidPhone: 'Format de numéro de téléphone invalide',
      invalidCode: 'Code de vérification invalide',
      sendCodeFailed: 'Échec de l\'envoi du code',
      usernameRequired: 'Veuillez entrer le nom d\'utilisateur',
      passwordRequired: 'Veuillez entrer le mot de passe',
      minLength: 'Au moins {min} caractères requis',
      network: 'Erreur réseau, veuillez réessayer plus tard'
    },
    success: 'Connexion réussie !'
  },

  // Page de démonstration Crypto
  crypto: {
    title: 'Démo Crypto',
    subtitle: 'Découvrez les fonctionnalités de chiffrement @ldesign/crypto',
    aes: {
      title: 'Chiffrement AES',
      plaintext: 'Texte clair',
      plaintextPlaceholder: 'Entrez le texte à chiffrer',
      key: 'Clé',
      keyPlaceholder: 'Entrez la clé',
      encrypt: 'Chiffrer',
      decrypt: 'Déchiffrer',
      clear: 'Effacer',
      encryptedResult: 'Résultat chiffré',
      decryptedResult: 'Résultat déchiffré'
    },
    hash: {
      title: 'Algorithme de hachage',
      plaintext: 'Texte clair',
      plaintextPlaceholder: 'Entrez le texte à hacher',
      algorithm: 'Algorithme',
      compute: 'Calculer le hash',
      clear: 'Effacer',
      result: 'Résultat du hash'
    },
    hmac: {
      title: 'Authentification HMAC',
      message: 'Message',
      messagePlaceholder: 'Entrez le message',
      key: 'Clé',
      keyPlaceholder: 'Entrez la clé',
      generate: 'Générer HMAC',
      verify: 'Vérifier',
      clear: 'Effacer',
      result: 'Résultat HMAC',
      verification: 'Résultat de vérification',
      valid: 'Valide',
      invalid: 'Invalide'
    },
    rsa: {
      title: 'Chiffrement RSA',
      generateKeys: 'Générer une paire de clés',
      publicKey: 'Clé publique',
      privateKey: 'Clé privée',
      plaintext: 'Texte clair',
      plaintextPlaceholder: 'Entrez le texte à chiffrer',
      encrypt: 'Chiffrer',
      decrypt: 'Déchiffrer',
      clear: 'Effacer',
      encryptedResult: 'Résultat chiffré',
      decryptedResult: 'Résultat déchiffré'
    },
    base64: {
      title: 'Encodage Base64',
      plaintext: 'Texte clair',
      plaintextPlaceholder: 'Entrez le texte à encoder',
      encode: 'Encoder',
      decode: 'Décoder',
      clear: 'Effacer',
      encodedResult: 'Résultat encodé',
      decodedResult: 'Résultat décodé'
    }
  },

  // Page de démonstration HTTP
  http: {
    title: 'Démo HTTP',
    subtitle: 'Découvrez les fonctionnalités de requête réseau @ldesign/http',
    get: {
      title: 'Requête GET',
      url: 'URL de requête',
      urlPlaceholder: 'Entrez l\'adresse API',
      send: 'Envoyer la requête',
      sending: 'Envoi en cours...',
      clear: 'Effacer',
      response: 'Réponse',
      error: 'Erreur'
    },
    post: {
      title: 'Requête POST',
      url: 'URL de requête',
      urlPlaceholder: 'Entrez l\'adresse API',
      data: 'Données de requête (JSON)',
      dataPlaceholder: 'Entrez les données JSON',
      send: 'Envoyer la requête',
      sending: 'Envoi en cours...',
      clear: 'Effacer',
      response: 'Réponse',
      error: 'Erreur'
    },
    interceptor: {
      title: 'Intercepteur',
      description: 'Les intercepteurs peuvent intercepter les requêtes et réponses pour l\'authentification, la journalisation, etc.',
      addRequest: 'Ajouter un intercepteur de requête',
      addResponse: 'Ajouter un intercepteur de réponse',
      clear: 'Effacer les intercepteurs',
      logs: 'Journaux d\'intercepteur'
    },
    cache: {
      title: 'Cache de requête',
      url: 'URL de cache',
      urlPlaceholder: 'Entrez l\'API à mettre en cache',
      ttl: 'TTL du cache (secondes)',
      fetch: 'Récupérer (avec cache)',
      clearCache: 'Effacer le cache',
      stats: 'Statistiques du cache',
      hits: 'Hits',
      misses: 'Misses',
      hitRate: 'Taux de réussite'
    },
    retry: {
      title: 'Mécanisme de nouvelle tentative',
      url: 'URL de requête',
      urlPlaceholder: 'Entrez l\'API potentiellement défaillante',
      maxRetries: 'Nombre max de tentatives',
      retryDelay: 'Délai de nouvelle tentative (ms)',
      sendWithRetry: 'Envoyer (avec nouvelle tentative)',
      response: 'Réponse',
      error: 'Erreur'
    },
    timeout: {
      title: 'Contrôle du timeout',
      url: 'URL de requête',
      timeout: 'Timeout (ms)',
      sendWithTimeout: 'Envoyer (avec timeout)',
      response: 'Réponse',
      error: 'Erreur'
    }
  },

  // Page de démonstration API
  api: {
    title: 'Démo API',
    subtitle: 'Découvrez les fonctionnalités de gestion d\'interface @ldesign/api',
    basic: {
      title: 'Bases de l\'API Engine',
      description: 'API Engine fournit une gestion d\'interface unifiée avec support de plugins.',
      basicCall: 'Appel de base',
      viewStatus: 'Voir le statut',
      engineStatus: 'Statut de l\'Engine'
    },
    system: {
      title: 'API système',
      username: 'Nom d\'utilisateur',
      usernamePlaceholder: 'Entrez le nom d\'utilisateur',
      password: 'Mot de passe',
      passwordPlaceholder: 'Entrez le mot de passe',
      simulateLogin: 'Simuler la connexion',
      getUserInfo: 'Obtenir les infos utilisateur',
      logout: 'Déconnexion',
      userInfo: 'Informations utilisateur',
      error: 'Erreur'
    },
    caching: {
      title: 'Stratégie de cache',
      method: 'Nom de méthode API',
      methodPlaceholder: 'ex: getUser',
      ttl: 'TTL du cache (secondes)',
      callWithCache: 'Appeler avec cache',
      cacheStats: 'Statistiques du cache',
      clearCache: 'Effacer le cache',
      items: 'Éléments',
      hitRate: 'Taux de réussite'
    },
    batch: {
      title: 'Requêtes batch',
      description: 'Les requêtes batch peuvent envoyer plusieurs appels API simultanément pour une meilleure efficacité.',
      api1: 'API 1',
      api2: 'API 2',
      api3: 'API 3',
      sendBatch: 'Envoyer batch',
      results: 'Résultats batch',
      error: 'Erreur'
    },
    plugin: {
      title: 'Système de plugins',
      description: 'API Engine supporte les extensions de plugins pour la journalisation, les nouvelles tentatives, le cache, etc.',
      addLogger: 'Ajouter plugin de log',
      addRetry: 'Ajouter plugin de nouvelle tentative',
      addCache: 'Ajouter plugin de cache',
      removePlugins: 'Supprimer tous les plugins',
      pluginLogs: 'Journaux de plugins'
    }
  },

  // Page de surveillance des performances
  performance: {
    title: 'Tableau de bord des performances',
    subtitle: 'Surveillance des performances de l\'application en temps réel, présentant les capacités de l\'Engine',
    overview: {
      title: 'Aperçu des performances',
      startupTime: 'Temps de démarrage',
      memoryUsage: 'Utilisation de la mémoire',
      ms: 'ms',
      mb: 'MB'
    },
    marks: {
      title: 'Marqueurs de performance',
      addMark: 'Ajouter un marqueur',
      name: 'Nom du marqueur',
      namePlaceholder: 'ex: feature-loaded',
      time: 'Temps',
      clear: 'Tout effacer'
    },
    cache: {
      title: 'Statistiques du cache',
      entries: 'Entrées de cache',
      hitRate: 'Taux de réussite',
      size: 'Taille du cache',
      kb: 'KB'
    },
    realtime: {
      title: 'Surveillance en temps réel',
      start: 'Démarrer la surveillance',
      stop: 'Arrêter la surveillance',
      fps: 'FPS',
      cpu: 'Utilisation CPU',
      memory: 'Mémoire',
      network: 'Réseau'
    },
    testing: {
      title: 'Outils de test de performance',
      stressTest: 'Test de stress',
      memoryTest: 'Test de mémoire',
      renderTest: 'Test de rendu',
      startTest: 'Démarrer le test',
      stopTest: 'Arrêter le test',
      results: 'Résultats du test'
    }
  },

  // Page de gestion d'état
  state: {
    title: 'Démo de gestion d\'état',
    subtitle: 'Présentation des fonctionnalités de StateManager : CRUD, voyage dans le temps, persistance',
    crud: {
      title: 'Opérations CRUD d\'état',
      key: 'Nom de la clé',
      keyPlaceholder: 'ex: user.name',
      value: 'Valeur (JSON)',
      valuePlaceholder: '{"name": "Jean"}',
      setState: 'Définir l\'état',
      getState: 'Obtenir l\'état',
      deleteState: 'Supprimer l\'état',
      currentValue: 'Valeur actuelle'
    },
    watch: {
      title: 'Surveillance d\'état (Watch)',
      key: 'Clé de surveillance',
      keyPlaceholder: 'ex: user',
      startWatch: 'Démarrer la surveillance',
      stopWatch: 'Arrêter la surveillance',
      events: 'Événements de surveillance',
      recent: '{count} récents',
      noEvents: 'Aucun événement'
    },
    history: {
      title: 'Voyage dans le temps (Historique)',
      undo: 'Annuler',
      redo: 'Refaire',
      clear: 'Effacer l\'historique',
      currentIndex: 'Index actuel',
      totalSteps: 'Étapes totales',
      timeline: 'Chronologie'
    },
    persistence: {
      title: 'Persistance',
      save: 'Sauvegarder dans LocalStorage',
      load: 'Charger depuis LocalStorage',
      clear: 'Effacer la persistance',
      status: 'Statut de persistance',
      enabled: 'Activé',
      disabled: 'Désactivé'
    },
    computed: {
      title: 'État calculé',
      description: 'État dérivé calculé automatiquement à partir d\'autres états',
      fullName: 'Nom complet',
      age: 'Âge',
      isAdult: 'Est adulte'
    }
  },

  // Page système d'événements
  event: {
    title: 'Démo du système d\'événements',
    subtitle: 'Présentation du système d\'événements Engine : Pub/Sub, priorité, replay d\'événements',
    emit: {
      title: 'Émission d\'événement (Emit)',
      name: 'Nom de l\'événement',
      namePlaceholder: 'ex: user:login',
      data: 'Données d\'événement (JSON)',
      dataPlaceholder: '{"user": "Jean"}',
      send: 'Envoyer l\'événement',
      sendOnce: 'Envoyer une fois',
      broadcast: 'Diffuser'
    },
    subscribe: {
      title: 'Abonnement aux événements (On)',
      name: 'Nom de l\'événement d\'abonnement',
      namePlaceholder: 'ex: user:*',
      priority: 'Priorité',
      priorityHigh: 'Haute (100)',
      priorityMedium: 'Moyenne (50)',
      priorityLow: 'Basse (0)',
      subscribe: 'S\'abonner',
      subscribeOnce: 'S\'abonner une fois',
      unsubscribeAll: 'Tout désabonner',
      current: 'Abonnements actuels',
      count: '{count} abonnements'
    },
    logs: {
      title: 'Journaux d\'événements',
      recent: '{count} récents',
      clear: 'Effacer les journaux',
      noLogs: 'Aucun journal',
      event: 'Événement',
      data: 'Données',
      time: 'Heure'
    },
    replay: {
      title: 'Replay d\'événements',
      description: 'Rejouer les événements historiques pour le débogage et les tests',
      start: 'Démarrer l\'enregistrement',
      stop: 'Arrêter l\'enregistrement',
      replay: 'Rejouer',
      clear: 'Effacer les enregistrements',
      recorded: '{count} événements enregistrés'
    },
    wildcard: {
      title: 'Abonnement avec joker',
      description: 'S\'abonner à plusieurs événements en utilisant des motifs joker',
      pattern: 'Motif d\'événement',
      patternPlaceholder: 'ex: user:* ou *.created',
      subscribe: 'S\'abonner au motif',
      matched: '{count} événements correspondants'
    }
  },

  // Page de contrôle de concurrence
  concurrency: {
    title: 'Démo de contrôle de concurrence',
    subtitle: 'Présentation des fonctionnalités de concurrence Engine : limitation de débit, file d\'attente, planification prioritaire',
    queue: {
      title: 'File d\'attente des tâches',
      description: 'Contrôler l\'exécution des tâches concurrentes pour éviter la surcharge des ressources',
      concurrency: 'Concurrence',
      addTask: 'Ajouter une tâche',
      addMultiple: 'Ajouter plusieurs',
      pause: 'Mettre en pause la file',
      resume: 'Reprendre la file',
      clear: 'Effacer la file',
      status: 'Statut de la file',
      pending: 'En attente',
      running: 'En cours',
      completed: 'Terminé',
      failed: 'Échoué'
    },
    throttle: {
      title: 'Limitation (Throttle)',
      description: 'Limiter la fréquence d\'exécution des fonctions, exécuter une fois dans le temps spécifié',
      interval: 'Intervalle de limitation (ms)',
      trigger: 'Déclencher la fonction',
      count: 'Nombre d\'exécutions',
      reset: 'Réinitialiser le compteur'
    },
    debounce: {
      title: 'Anti-rebond (Debounce)',
      description: 'Retarder l\'exécution de la fonction, exécuter seulement après le dernier appel',
      delay: 'Délai d\'anti-rebond (ms)',
      trigger: 'Déclencher la fonction',
      count: 'Nombre d\'exécutions',
      reset: 'Réinitialiser le compteur'
    },
    priority: {
      title: 'Planification prioritaire',
      description: 'Planifier l\'exécution des tâches en fonction de la priorité',
      taskName: 'Nom de la tâche',
      taskNamePlaceholder: 'ex: chargement de données',
      priority: 'Priorité',
      high: 'Haute',
      medium: 'Moyenne',
      low: 'Basse',
      addTask: 'Ajouter une tâche',
      queue: 'File d\'attente des tâches',
      noTasks: 'Aucune tâche'
    },
    semaphore: {
      title: 'Sémaphore',
      description: 'Contrôler l\'accès concurrent aux ressources',
      maxConcurrent: 'Concurrence maximale',
      acquire: 'Acquérir',
      release: 'Libérer',
      available: 'Disponible',
      waiting: 'File d\'attente'
    }
  },

  // Page système de plugins
  plugin: {
    title: 'Démo du système de plugins',
    subtitle: 'Présentation du système de plugins Engine : chargement dynamique, cycle de vie, communication',
    basic: {
      title: 'Bases des plugins',
      description: 'Engine fournit un système de plugins complet avec chargement et déchargement dynamiques',
      installed: 'Plugins installés',
      available: 'Plugins disponibles',
      install: 'Installer',
      uninstall: 'Désinstaller',
      enable: 'Activer',
      disable: 'Désactiver',
      configure: 'Configurer'
    },
    lifecycle: {
      title: 'Cycle de vie',
      description: 'Les plugins ont des hooks de cycle de vie complets',
      onInstall: 'À l\'installation',
      onEnable: 'À l\'activation',
      onDisable: 'À la désactivation',
      onUninstall: 'À la désinstallation',
      logs: 'Journaux du cycle de vie'
    },
    communication: {
      title: 'Communication entre plugins',
      description: 'Les plugins peuvent communiquer via le bus d\'événements',
      sender: 'Plugin émetteur',
      receiver: 'Plugin récepteur',
      message: 'Message',
      send: 'Envoyer le message',
      logs: 'Journaux de communication'
    },
    custom: {
      title: 'Plugin personnalisé',
      description: 'Créer et enregistrer des plugins personnalisés',
      pluginName: 'Nom du plugin',
      pluginNamePlaceholder: 'ex: my-plugin',
      version: 'Version',
      versionPlaceholder: 'ex: 1.0.0',
      author: 'Auteur',
      authorPlaceholder: 'Votre nom',
      create: 'Créer le plugin',
      register: 'Enregistrer le plugin',
      created: 'Plugin créé'
    }
  },

  // Page tableau de bord
  dashboard: {
    title: 'Tableau de bord',
    subtitle: 'Bienvenue, {username}',
    currentRoute: 'Informations sur la route actuelle',
    engineStatus: 'Statut de l\'Engine',
    appName: 'Nom de l\'application',
    environment: 'Environnement',
    debugMode: 'Mode débogage',
    routeHistory: 'Historique des routes',
    noHistory: 'Aucun historique',
    performanceMonitor: 'Surveillance des performances',
    navigationTime: 'Temps de navigation',
    cacheHitRate: 'Taux de réussite du cache',
    totalNavigations: 'Navigations totales',
    memoryUsage: 'Utilisation de la mémoire',
    allRoutes: 'Toutes les routes',
    auth: 'Authentification',
    requiresAuth: 'Nécessite l\'authentification',
    public: 'Public',
    history: 'Historique',
    errors: {
      loadHistory: 'Échec du chargement de l\'historique des routes'
    },
    overview: {
      title: 'Vue d\'ensemble',
      totalUsers: 'Total des utilisateurs',
      activeUsers: 'Utilisateurs actifs',
      newUsers: 'Nouveaux utilisateurs',
      revenue: 'Revenus',
      totalVisits: 'Total des visites',
      orders: 'Commandes'
    },
    stats: {
      title: 'Statistiques',
      daily: 'Quotidien',
      weekly: 'Hebdomadaire',
      monthly: 'Mensuel',
      yearly: 'Annuel'
    },
    activity: {
      title: 'Activité récente',
      noActivity: 'Aucune activité enregistrée'
    },
    quickActions: {
      title: 'Actions rapides',
      newPost: 'Nouvelle publication',
      viewReports: 'Voir les rapports',
      settings: 'Paramètres',
      help: 'Centre d\'aide'
    },
    notifications: {
      title: 'Notifications',
      markAllRead: 'Tout marquer comme lu',
      noNotifications: 'Aucune nouvelle notification'
    }
  },

  // Commun
  common: {
    loading: 'Chargement...',
    path: 'Chemin',
    name: 'Nom',
    params: 'Paramètres',
    query: 'Requête',
    unnamed: 'sans nom',
    on: 'Activé',
    off: 'Désactivé',
    visit: 'Visiter',
    actions: 'Actions',
    clear: 'Effacer',
    guest: 'Invité',
    error: 'Erreur',
    success: 'Succès',
    warning: 'Avertissement',
    info: 'Info',
    confirm: 'Confirmer',
    cancel: 'Annuler',
    save: 'Sauvegarder',
    delete: 'Supprimer',
    edit: 'Modifier',
    add: 'Ajouter',
    search: 'Rechercher',
    filter: 'Filtrer',
    export: 'Exporter',
    import: 'Importer',
    refresh: 'Actualiser',
    back: 'Retour',
    next: 'Suivant',
    previous: 'Précédent',
    finish: 'Terminer',
    close: 'Fermer',
    yes: 'Oui',
    no: 'Non',
    ok: 'OK',
    apply: 'Appliquer',
    reset: 'Réinitialiser',
    selectAll: 'Tout sélectionner',
    deselectAll: 'Tout désélectionner',
    more: 'Plus',
    less: 'Moins',
    showMore: 'Afficher plus',
    showLess: 'Afficher moins',
    noData: 'Aucune donnée',
    noResults: 'Aucun résultat trouvé',
    tryAgain: 'Réessayer',
    viewDetails: 'Voir les détails'
  },

  // Messages d'erreur
  errors: {
    startup: {
      title: 'Échec du démarrage de l\'application',
      message: 'Erreur inconnue',
      action: 'Recharger'
    },
    404: {
      title: 'Page non trouvée',
      message: 'Désolé, la page que vous recherchez n\'existe pas.',
      action: 'Retour à l\'accueil',
      back: 'Retour'
    },
    500: {
      title: 'Erreur serveur',
      message: 'Désolé, le serveur a rencontré un problème.',
      action: 'Actualiser la page'
    },
    network: {
      title: 'Erreur réseau',
      message: 'Veuillez vérifier votre connexion réseau.',
      action: 'Réessayer'
    },
    unauthorized: {
      title: 'Non autorisé',
      message: 'Vous devez vous connecter pour accéder à cette page.',
      action: 'Aller à la connexion'
    },
    forbidden: {
      title: 'Accès interdit',
      message: 'Vous n\'avez pas la permission d\'accéder à cette page.',
      action: 'Retour'
    }
  },

  // Messages de validation
  validation: {
    required: '{field} est requis',
    email: 'Veuillez entrer une adresse email valide',
    min: '{field} doit contenir au moins {min} caractères',
    max: '{field} ne peut pas dépasser {max} caractères',
    between: '{field} doit être entre {min} et {max}',
    numeric: '{field} doit être un nombre',
    alphanumeric: '{field} ne peut contenir que des lettres et des chiffres',
    pattern: 'Le format de {field} est incorrect',
    confirmed: 'La confirmation de {field} ne correspond pas',
    unique: '{field} existe déjà',
    date: 'Veuillez entrer une date valide',
    dateAfter: 'La date doit être après {date}',
    dateBefore: 'La date doit être avant {date}',
    url: 'Veuillez entrer une URL valide',
    phone: 'Veuillez entrer un numéro de téléphone valide'
  },

  // Date et heure
  datetime: {
    today: 'Aujourd\'hui',
    yesterday: 'Hier',
    tomorrow: 'Demain',
    thisWeek: 'Cette semaine',
    lastWeek: 'Semaine dernière',
    nextWeek: 'Semaine prochaine',
    thisMonth: 'Ce mois-ci',
    lastMonth: 'Mois dernier',
    nextMonth: 'Mois prochain',
    thisYear: 'Cette année',
    lastYear: 'Année dernière',
    nextYear: 'Année prochaine',
    selectDate: 'Sélectionner la date',
    selectTime: 'Sélectionner l\'heure',
    selectDateTime: 'Sélectionner la date et l\'heure'
  },

  // Paramètres de thème
  theme: {
    title: 'Thème',
    selectThemeColor: 'Sélectionner la couleur du thème',
    customColor: 'Couleur personnalisée',
    custom: 'Actuel',
    mode: 'Mode du thème',
    light: 'Clair',
    dark: 'Sombre',
    apply: 'Appliquer',
    add: 'Ajouter',
    remove: 'Supprimer',
    searchPlaceholder: 'Rechercher des couleurs...',
    presetThemes: 'Thèmes prédéfinis',
    addCustomTheme: 'Ajouter un thème personnalisé',
    themeName: 'Nom du thème',
    confirmRemove: 'Supprimer ce thème ?',
    presets: {
      blue: 'Bleu Aurore',
      purple: 'Violet',
      cyan: 'Cyan',
      green: 'Vert Polaire',
      magenta: 'Magenta',
      red: 'Rouge Poussière',
      orange: 'Orange Coucher de Soleil',
      yellow: 'Jaune Lever de Soleil',
      volcano: 'Volcan',
      geekblue: 'Bleu Geek',
      lime: 'Citron Vert',
      gold: 'Or',
      gray: 'Gris Neutre',
      'dark-blue': 'Bleu Foncé',
      'dark-green': 'Vert Foncé',
      // Thèmes personnalisés
      sunset: 'Orange Coucher de Soleil',
      forest: 'Vert Forêt',
      midnight: 'Bleu Minuit',
      lavender: 'Rêve de Lavande',
      coral: 'Récif de Corail'
    }
  }
};

