/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{useI18n as o}from"../../i18n/index.js";function m(n){n.afterEach(a=>{const{t}=o(),e=a.meta?.titleKey;if(e){const i=t(e);document.title=`${i} - ${t("app.name")}`}else document.title=t("app.name")})}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{m as setupTitleGuard};
//# sourceMappingURL=title.guard.js.map
