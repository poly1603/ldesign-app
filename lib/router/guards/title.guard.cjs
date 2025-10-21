"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var u=require("../../i18n/index.cjs");function s(i){i.afterEach(a=>{const{t:e}=u.useI18n(),t=a.meta?.titleKey;if(t){const n=e(t);document.title=`${n} - ${e("app.name")}`}else document.title=e("app.name")})}exports.setupTitleGuard=s;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=title.guard.cjs.map
