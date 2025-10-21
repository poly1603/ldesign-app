"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("@ldesign/i18n"),s=require("../locales/zh-CN.cjs"),a=require("../locales/en-US.cjs");const t=e.useVueI18n;function u(n={}){const r={"zh-CN":s.default,"en-US":a.default,...n.messages||{}};return e.createI18nEnginePlugin({...n,messages:r,storageKey:"app-locale"})}var i={useI18n:e.useVueI18n,createI18nEnginePlugin:u};exports.createI18nEnginePlugin=u,exports.default=i,exports.useI18n=t;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=index.cjs.map
