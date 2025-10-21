/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{auth as e}from"../../composables/useAuth.js";const u="/login",o="/";function i(a){a.beforeEach((t,f,n)=>{if(e.userInfo||e.initAuth(),t.meta?.requiresAuth===!0&&!e.isLoggedIn.value){const r=t.fullPath!==u?t.fullPath:o;n({path:u,query:{redirect:r}});return}if(t.path===u&&e.isLoggedIn.value){let r=t.query.redirect||o;r===u&&(r=o),n(r);return}n()})}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{i as setupAuthGuard};
//# sourceMappingURL=auth.guard.js.map
