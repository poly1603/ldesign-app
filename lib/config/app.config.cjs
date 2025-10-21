"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */const n="LDesign Router Demo",o="1.0.0",e={name:n,version:o,description:"LDesign Router \u793A\u4F8B\u5E94\u7528",author:"LDesign Team",debug:(void 0).DEV,environment:(void 0).MODE,api:{baseUrl:(void 0).VITE_API_BASE_URL||"/api",timeout:3e4,retries:3},storage:{prefix:"ldesign_",expire:6048e5},theme:{primaryColor:"#667eea",mode:"light"}},a={name:`${n} Engine`,version:o,debug:e.debug,environment:e.environment,features:{enableHotReload:!0,enableDevTools:!0,enablePerformanceMonitoring:!1,enableErrorReporting:!0,enableSecurityProtection:!1,enableCaching:!0,enableNotifications:!1},logger:{enabled:!1,level:"error",maxLogs:0,showTimestamp:!1,showContext:!1},cache:{enabled:!0,maxSize:50,defaultTTL:300*1e3},performance:{enabled:!e.debug,sampleRate:.1,slowThreshold:1e3}};exports.APP_NAME=n,exports.APP_VERSION=o,exports.appConfig=e,exports.engineConfig=a;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=app.config.cjs.map
