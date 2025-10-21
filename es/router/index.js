/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{createRouterEnginePlugin as i}from"@ldesign/router";import{routes as s}from"./routes.js";import{setupGuards as u}from"./guards.js";import{routerConfig as a}from"../config/router.config.js";function t(){const o=i({routes:s,...a,scrollBehavior:(r,m,e)=>e||(r.hash?{el:r.hash,behavior:"smooth"}:{top:0,behavior:"smooth"})});return u(o),o}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{t as createRouter,t as default};
//# sourceMappingURL=index.js.map
