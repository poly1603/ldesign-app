"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue");require("./BaseInput.vue.cjs");var g=require("./BaseInput.vue2.cjs");const h={class:"sms-captcha-wrapper"},_=["disabled"];var y=e.defineComponent({__name:"SmsCaptcha",props:{modelValue:{type:String,required:!0},phone:{type:String,required:!0},placeholder:{type:String,required:!1,default:"\u8BF7\u8F93\u5165\u77ED\u4FE1\u9A8C\u8BC1\u7801"},errorMessage:{type:String,required:!1}},emits:["update:modelValue","send","enter"],setup(i,{emit:p}){const s=i,n=p,o=e.ref(s.modelValue),l=e.ref(!1),u=e.ref(0);let a=null;const c=e.computed(()=>u.value>0?`${u.value}\u79D2\u540E\u91CD\u53D1`:l.value?"\u53D1\u9001\u4E2D...":"\u83B7\u53D6\u9A8C\u8BC1\u7801"),v=r=>{o.value=r,n("update:modelValue",r)},m=async()=>{if(s.phone&&!(l.value||u.value>0)){l.value=!0;try{n("send",s.phone),setTimeout(()=>{l.value=!1,f()},1e3)}catch{l.value=!1}}},f=()=>{u.value=60,a=setInterval(()=>{u.value--,u.value<=0&&a&&(clearInterval(a),a=null)},1e3)};return e.onBeforeUnmount(()=>{a&&clearInterval(a)}),(r,t)=>(e.openBlock(),e.createElementBlock("div",h,[e.createVNode(g.default,{modelValue:o.value,"onUpdate:modelValue":[t[0]||(t[0]=d=>o.value=d),v],placeholder:r.placeholder,maxlength:6,"error-message":r.errorMessage,"prefix-icon":"icon-message",onEnter:t[1]||(t[1]=d=>r.$emit("enter"))},null,8,["modelValue","placeholder","error-message"]),e.createElementVNode("button",{disabled:l.value||u.value>0,onClick:m,class:e.normalizeClass(["sms-button",{disabled:l.value||u.value>0}])},e.toDisplayString(c.value),11,_)]))}});exports.default=y;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=SmsCaptcha.vue2.cjs.map
