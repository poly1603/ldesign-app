"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var o=require("@ldesign/router"),a=require("./routes.cjs"),s=require("./guards.cjs"),i=require("../config/router.config.cjs");function t(){const e=o.createRouterEnginePlugin({routes:a.routes,...i.routerConfig,scrollBehavior:(r,n,u)=>u||(r.hash?{el:r.hash,behavior:"smooth"}:{top:0,behavior:"smooth"})});return s.setupGuards(e),e}exports.createRouter=t,exports.default=t;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=index.cjs.map
