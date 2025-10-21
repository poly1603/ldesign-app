/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as s,createElementBlock as t,openBlock as a,createElementVNode as l,withDirectives as u,vShow as i,toDisplayString as p}from"vue";const d={class:"remember-checkbox-wrapper"},k={class:"checkbox-label"},h=["checked"],m={class:"checkbox-box"},b={class:"checkbox-icon",viewBox:"0 0 24 24",fill:"none",stroke:"currentColor","stroke-width":"3","stroke-linecap":"round","stroke-linejoin":"round"},x={class:"checkbox-text"};var g=s({__name:"RememberCheckbox",props:{modelValue:{type:Boolean,required:!0},label:{type:String,required:!1,default:"\u8BB0\u4F4F\u5BC6\u7801"}},emits:["update:modelValue","change"],setup(B,{emit:n}){const c=n,r=e=>{const o=e.target;c("update:modelValue",o.checked),c("change",o.checked)};return(e,o)=>(a(),t("div",d,[l("label",k,[l("input",{type:"checkbox",checked:e.modelValue,onChange:r,class:"checkbox-input"},null,40,h),l("span",m,[u((a(),t("svg",b,[...o[0]||(o[0]=[l("polyline",{points:"20 6 9 17 4 12"},null,-1)])],512)),[[i,e.modelValue]])]),l("span",x,p(e.label),1)])]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{g as default};
//# sourceMappingURL=RememberCheckbox.vue2.js.map
