"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue"),a=require("@ldesign/router"),c=require("../../i18n/index.cjs");const l={class:"error-page"},i={class:"error-content"},u={class:"error-title"},d={class:"error-message"},m={class:"error-actions"};var p=e.defineComponent({__name:"NotFound",setup(b){const t=a.useRouter(),{t:r}=c.useI18n(),s=()=>{t.push("/")},n=()=>{t.back()};return(v,o)=>(e.openBlock(),e.createElementBlock("div",l,[e.createElementVNode("div",i,[o[0]||(o[0]=e.createElementVNode("h1",{class:"error-code"},"404",-1)),e.createElementVNode("h2",u,e.toDisplayString(e.unref(r)("errors.404.title")),1),e.createElementVNode("p",d,e.toDisplayString(e.unref(r)("errors.404.message")),1),e.createElementVNode("div",m,[e.createElementVNode("button",{onClick:s,class:"btn btn-primary"},e.toDisplayString(e.unref(r)("errors.404.action")),1),e.createElementVNode("button",{onClick:n,class:"btn btn-secondary"},e.toDisplayString(e.unref(r)("errors.404.back")),1)])])]))}});exports.default=p;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=NotFound.vue2.cjs.map
