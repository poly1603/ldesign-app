"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var r=require("../../composables/useAuth.cjs");function n(a){a.beforeEach((t,s,u)=>{const e=t.meta?.roles;if(!e||e.length===0){u();return}if(!r.auth.canAccess(e)){if(console.warn(`\u7528\u6237\u65E0\u6743\u8BBF\u95EE ${t.path}\uFF0C\u9700\u8981\u89D2\u8272: ${e.join(", ")}`),!r.auth.isLoggedIn.value){u({path:"/login",query:{redirect:t.fullPath}});return}u({path:"/403",replace:!0});return}u()})}exports.setupPermissionGuard=n;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=permission.guard.cjs.map
