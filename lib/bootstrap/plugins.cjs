"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var o=require("vue"),t=require("../i18n/index.cjs"),u=require("../plugins/cache.cjs"),g=require("@ldesign/color/plugin"),f=require("@ldesign/template"),v=require("../config/i18n.config.cjs"),p=require("../config/cache.config.cjs"),s=require("../config/color.config.cjs"),P=require("../config/template.config.cjs");function h(){const i=t.createI18nEnginePlugin(v.i18nConfig),e=i.localeRef;o.watch(e,(a,c)=>{typeof window<"u"&&window.dispatchEvent(new CustomEvent("app:locale-changed",{detail:{locale:a,oldLocale:c}}))},{flush:"post"});const n=u.createCacheVuePlugin(p.createCacheConfig()),r=f.createTemplatePlugin(P.templateConfig),l=g.createColorPlugin({...s.createColorConfig(e),locale:e});return{i18nPlugin:i,cachePlugin:n,colorPlugin:l,sizePlugin:null,templatePlugin:r,localeRef:e}}exports.initializePlugins=h;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=plugins.cjs.map
