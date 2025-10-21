"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue");const r={class:"remember-checkbox-wrapper"},a={class:"checkbox-label"},s=["checked"],u={class:"checkbox-box"},d={class:"checkbox-icon",viewBox:"0 0 24 24",fill:"none",stroke:"currentColor","stroke-width":"3","stroke-linecap":"round","stroke-linejoin":"round"},i={class:"checkbox-text"};var p=e.defineComponent({__name:"RememberCheckbox",props:{modelValue:{type:Boolean,required:!0},label:{type:String,required:!1,default:"\u8BB0\u4F4F\u5BC6\u7801"}},emits:["update:modelValue","change"],setup(k,{emit:o}){const c=o,n=t=>{const l=t.target;c("update:modelValue",l.checked),c("change",l.checked)};return(t,l)=>(e.openBlock(),e.createElementBlock("div",r,[e.createElementVNode("label",a,[e.createElementVNode("input",{type:"checkbox",checked:t.modelValue,onChange:n,class:"checkbox-input"},null,40,s),e.createElementVNode("span",u,[e.withDirectives((e.openBlock(),e.createElementBlock("svg",d,[...l[0]||(l[0]=[e.createElementVNode("polyline",{points:"20 6 9 17 4 12"},null,-1)])],512)),[[e.vShow,t.modelValue]])]),e.createElementVNode("span",i,e.toDisplayString(t.label),1)])]))}});exports.default=p;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=RememberCheckbox.vue2.cjs.map
