"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var c=require("@ldesign/cache/core/cache-manager"),a=require("@ldesign/cache/vue");function o(n={}){const{globalPropertyName:i="$cache",...t}=n,e=new c.CacheManager(t);return{install(r){r.provide(a.CACHE_MANAGER_KEY,e),r.config.globalProperties[i]={manager:e,get:e.get.bind(e),set:e.set.bind(e),remove:e.remove.bind(e),clear:e.clear.bind(e),has:e.has.bind(e),keys:e.keys.bind(e),getStats:e.getStats.bind(e),remember:e.remember.bind(e)},r.component("CacheProvider",a.CacheProvider),console.info("[Cache Plugin] \u5DF2\u5B89\u88C5")}}}exports.createCacheVuePlugin=o;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=cache.cjs.map
