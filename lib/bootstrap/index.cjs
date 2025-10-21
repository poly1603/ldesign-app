"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var c=require("@ldesign/engine"),g=require("@/App.vue"),s=require("../router/index.cjs"),P=require("../config/app.config.cjs"),d=require("../composables/useAuth.cjs"),h=require("./plugins.cjs"),a=require("./app-setup.cjs"),q=require("./error-handler.cjs");async function v(){try{d.auth.initAuth();const e=s.createRouter(),{i18nPlugin:n,cachePlugin:i,colorPlugin:u,sizePlugin:o,templatePlugin:l,localeRef:t}=h.initializePlugins();return await c.createEngineApp({rootComponent:g,mountElement:"#app",config:P.engineConfig,plugins:[e,n],setupApp:async r=>{r.config.warnHandler=()=>{},a.setupVueApp(r,{localeRef:t,i18nPlugin:n,cachePlugin:i,colorPlugin:u,sizePlugin:o,templatePlugin:l})},onError:q.handleAppError,onReady:r=>{try{a.setupEngineReady(r,t,n,i,u,o)}catch(p){console.error("[index.ts] Error in onReady:",p)}},onMounted:()=>{}})}catch(e){throw console.error("\u274C \u5E94\u7528\u542F\u52A8\u5931\u8D25:",e),e}}exports.bootstrap=v;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=index.cjs.map
