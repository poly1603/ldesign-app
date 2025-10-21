/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{auth as a}from"./composables/useAuth.js";if(typeof performance<"u"&&performance.mark("app-start"),typeof window<"u"&&import.meta.env.DEV){const o=console.warn.bind(console);console.warn=(...e)=>{const t=e[0];typeof t=="string"&&t.startsWith("[Vue warn]")||o(...e)};const r=console.debug.bind(console);console.debug=(...e)=>{const t=e[0];typeof t=="string"&&(t.includes("[vite]")||t.includes("connecting...")||t.includes("connected."))||r(...e)}}"serviceWorker"in navigator&&import.meta.env.PROD&&window.addEventListener("load",()=>{navigator.serviceWorker.register("/sw.js").then(o=>{console.log("SW registered:",o)}).catch(o=>{console.log("SW registration failed:",o)})});async function n(){try{a.initAuth();const{bootstrap:o}=await import("./bootstrap/index.js"),{showErrorPage:r}=await import("./bootstrap/error-handler.js");try{await o()}catch(e){console.error("\u274C \u5E94\u7528\u542F\u52A8\u5931\u8D25:",e),r(e)}if(typeof performance<"u"){performance.mark("app-ready");try{performance.measure("app-boot-time","app-start","app-ready");const e=performance.getEntriesByName("app-boot-time")[0];import.meta.env.DEV&&console.log(`\u{1F680} App boot time: ${Math.round(e.duration)}ms`)}catch{}}import.meta.env.DEV&&import("./utils/performance.js").then(({performanceMonitor:e})=>{})}catch(o){console.error("\u274C \u542F\u52A8\u5931\u8D25:",o)}}typeof requestIdleCallback<"u"?requestIdleCallback(()=>n(),{timeout:100}):n();/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=main.js.map
