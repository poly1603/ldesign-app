/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{CacheManager as a}from"@ldesign/cache/core/cache-manager";import{CACHE_MANAGER_KEY as i,CacheProvider as c}from"@ldesign/cache/vue";function m(n={}){const{globalPropertyName:o="$cache",...t}=n,e=new a(t);return{install(r){r.provide(i,e),r.config.globalProperties[o]={manager:e,get:e.get.bind(e),set:e.set.bind(e),remove:e.remove.bind(e),clear:e.clear.bind(e),has:e.has.bind(e),keys:e.keys.bind(e),getStats:e.getStats.bind(e),remember:e.remember.bind(e)},r.component("CacheProvider",c),console.info("[Cache Plugin] \u5DF2\u5B89\u88C5")}}}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{m as createCacheVuePlugin};
//# sourceMappingURL=cache.js.map
