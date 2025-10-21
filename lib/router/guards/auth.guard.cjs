"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var r=require("../../composables/useAuth.cjs");const e="/login",h="/";function i(n){n.beforeEach((t,s,a)=>{if(r.auth.userInfo||r.auth.initAuth(),t.meta?.requiresAuth===!0&&!r.auth.isLoggedIn.value){const u=t.fullPath!==e?t.fullPath:h;a({path:e,query:{redirect:u}});return}if(t.path===e&&r.auth.isLoggedIn.value){let u=t.query.redirect||h;u===e&&(u=h),a(u);return}a()})}exports.setupAuthGuard=i;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=auth.guard.cjs.map
