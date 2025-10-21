/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{createEngineApp as a}from"@ldesign/engine";import c from"@/App.vue";import{createRouter as m}from"../router/index.js";import{engineConfig as g}from"../config/app.config.js";import{auth as f}from"../composables/useAuth.js";import{initializePlugins as s}from"./plugins.js";import{setupEngineReady as P,setupVueApp as h}from"./app-setup.js";import{handleAppError as d}from"./error-handler.js";async function y(){try{f.initAuth();const o=m(),{i18nPlugin:r,cachePlugin:e,colorPlugin:i,sizePlugin:t,templatePlugin:p,localeRef:u}=s();return await a({rootComponent:c,mountElement:"#app",config:g,plugins:[o,r],setupApp:async n=>{n.config.warnHandler=()=>{},h(n,{localeRef:u,i18nPlugin:r,cachePlugin:e,colorPlugin:i,sizePlugin:t,templatePlugin:p})},onError:d,onReady:n=>{try{P(n,u,r,e,i,t)}catch(l){console.error("[index.ts] Error in onReady:",l)}},onMounted:()=>{}})}catch(o){throw console.error("\u274C \u5E94\u7528\u542F\u52A8\u5931\u8D25:",o),o}}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{y as bootstrap};
//# sourceMappingURL=index.js.map
