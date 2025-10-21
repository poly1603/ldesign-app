/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{useCacheManager as o}from"@ldesign/cache/vue";function s(){const a=o();return{async get(e){try{return await a.get(e)}catch(r){return console.error("[useAppCache] Failed to get cache:",e,r),null}},async set(e,r,t){try{await a.set(e,r,t?{ttl:t}:void 0)}catch(c){console.error("[useAppCache] Failed to set cache:",e,c)}},async remove(e){try{await a.remove(e)}catch(r){console.error("[useAppCache] Failed to remove cache:",e,r)}},async clear(){try{await a.clear()}catch(e){console.error("[useAppCache] Failed to clear cache:",e)}},async has(e){try{return await a.has(e)}catch(r){return console.error("[useAppCache] Failed to check cache:",e,r),!1}},async keys(){try{return await a.keys()}catch(e){return console.error("[useAppCache] Failed to get cache keys:",e),[]}},async getStats(){try{return await a.getStats()}catch(e){return console.error("[useAppCache] Failed to get cache stats:",e),null}},async remember(e,r,t){try{return await a.remember(e,r,t?{ttl:t}:void 0)}catch(c){throw console.error("[useAppCache] Failed to remember:",e,c),c}},manager:a}}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{s as useAppCache};
//# sourceMappingURL=useAppCache.js.map
