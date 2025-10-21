/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{watch as a}from"vue";import{createI18nEnginePlugin as c}from"../i18n/index.js";import{createCacheVuePlugin as m}from"../plugins/cache.js";import{createColorPlugin as f}from"@ldesign/color/plugin";import{createTemplatePlugin as p}from"@ldesign/template";import{i18nConfig as u}from"../config/i18n.config.js";import{createCacheConfig as g}from"../config/cache.config.js";import{createColorConfig as P}from"../config/color.config.js";import{templateConfig as C}from"../config/template.config.js";function s(){const e=c(u),o=e.localeRef;a(o,(n,r)=>{typeof window<"u"&&window.dispatchEvent(new CustomEvent("app:locale-changed",{detail:{locale:n,oldLocale:r}}))},{flush:"post"});const i=m(g()),t=p(C),l=f({...P(o),locale:o});return{i18nPlugin:e,cachePlugin:i,colorPlugin:l,sizePlugin:null,templatePlugin:t,localeRef:o}}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{s as initializePlugins};
//# sourceMappingURL=plugins.js.map
