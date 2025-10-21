"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var n=require("vue");let o=null;function u(s){o=s}function l(){return n.inject("message",null)||o||{success:e=>console.log("\u2713",e),error:e=>console.error("\u2715",e),warning:e=>console.warn("\u26A0",e),info:e=>console.info("\u2139",e)}}exports.setGlobalMessage=u,exports.useMessage=l;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=useMessage.cjs.map
