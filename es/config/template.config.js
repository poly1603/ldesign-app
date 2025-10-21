/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */const t={autoInit:!0,autoDetect:!0,defaultDevice:"desktop",cache:{enabled:!0,ttl:6e5,maxSize:100},rememberPreferences:!0,preferencesKey:"app-template-prefs",preload:!1,preloadStrategy:"lazy",ui:{defaultStyle:"cards",display:{preview:!0,description:!0,metadata:!0,aspectRatio:"3/2"},styleByCategory:{login:"cards",dashboard:"grid",profile:"list",settings:"compact"},features:{search:!1,filter:!1,groupBy:"none"}},animation:{defaultAnimation:"fade-slide",transitionMode:"out-in",duration:300,customAnimations:{"login/default->login/split":"flip","login/split->login/default":"flip","dashboard/default->dashboard/sidebar":"slide","dashboard/sidebar->dashboard/tabs":"fade"},animationByCategory:{login:"scale",dashboard:"slide",profile:"fade",settings:"none"},animationByDevice:{mobile:"slide",tablet:"fade-slide",desktop:"fade"}},hooks:{beforeLoad:async e=>{import.meta.env.DEV&&console.log(`[Template] Loading: ${e}`)},afterLoad:async(e,a)=>{import.meta.env.DEV&&console.log(`[Template] Loaded: ${e}`,a)},beforeTransition:(e,a)=>{import.meta.env.DEV&&console.log(`[Template] Transition: ${e} -> ${a}`)},afterTransition:(e,a)=>{import.meta.env.DEV&&console.log(`[Template] Transitioned: ${e} -> ${a}`)},onError:e=>{console.error("[Template] Error:",e)}},performance:import.meta.env.DEV};/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{t as templateConfig};
//# sourceMappingURL=template.config.js.map
