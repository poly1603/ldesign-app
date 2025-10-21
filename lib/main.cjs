"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var a=require("./composables/useAuth.cjs");if(typeof performance<"u"&&performance.mark("app-start"),typeof window<"u"&&(void 0).DEV){const r=console.warn.bind(console);console.warn=(...e)=>{const o=e[0];typeof o=="string"&&o.startsWith("[Vue warn]")||r(...e)};const t=console.debug.bind(console);console.debug=(...e)=>{const o=e[0];typeof o=="string"&&(o.includes("[vite]")||o.includes("connecting...")||o.includes("connected."))||t(...e)}}"serviceWorker"in navigator&&(void 0).PROD&&window.addEventListener("load",()=>{navigator.serviceWorker.register("/sw.js").then(r=>{console.log("SW registered:",r)}).catch(r=>{console.log("SW registration failed:",r)})});async function n(){try{a.auth.initAuth();const{bootstrap:r}=await Promise.resolve().then(function(){return require("./bootstrap/index.cjs")}),{showErrorPage:t}=await Promise.resolve().then(function(){return require("./bootstrap/error-handler.cjs")});try{await r()}catch(e){console.error("\u274C \u5E94\u7528\u542F\u52A8\u5931\u8D25:",e),t(e)}if(typeof performance<"u"){performance.mark("app-ready");try{performance.measure("app-boot-time","app-start","app-ready");const e=performance.getEntriesByName("app-boot-time")[0];(void 0).DEV&&console.log(`\u{1F680} App boot time: ${Math.round(e.duration)}ms`)}catch{}}(void 0).DEV&&Promise.resolve().then(function(){return require("./utils/performance.cjs")}).then(({performanceMonitor:e})=>{})}catch(r){console.error("\u274C \u542F\u52A8\u5931\u8D25:",r)}}typeof requestIdleCallback<"u"?requestIdleCallback(()=>n(),{timeout:100}):n();/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=main.cjs.map
