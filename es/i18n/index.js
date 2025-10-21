/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{createI18nEnginePlugin as o,useVueI18n as n}from"@ldesign/i18n";import t from"../locales/zh-CN.js";import a from"../locales/en-US.js";const i=n;function r(e={}){const s={"zh-CN":t,"en-US":a,...e.messages||{}};return o({...e,messages:s,storageKey:"app-locale"})}var u={useI18n:n,createI18nEnginePlugin:r};/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{r as createI18nEnginePlugin,u as default,i as useI18n};
//# sourceMappingURL=index.js.map
