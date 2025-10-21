/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{auth as r}from"../../composables/useAuth.js";function a(n){n.beforeEach((t,i,e)=>{const u=t.meta?.roles;if(!u||u.length===0){e();return}if(!r.canAccess(u)){if(console.warn(`\u7528\u6237\u65E0\u6743\u8BBF\u95EE ${t.path}\uFF0C\u9700\u8981\u89D2\u8272: ${u.join(", ")}`),!r.isLoggedIn.value){e({path:"/login",query:{redirect:t.fullPath}});return}e({path:"/403",replace:!0});return}e()})}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{a as setupPermissionGuard};
//# sourceMappingURL=permission.guard.js.map
