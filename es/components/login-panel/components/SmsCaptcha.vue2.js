/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as g,ref as s,computed as h,createElementBlock as C,onBeforeUnmount as V,openBlock as B,createVNode as D,createElementVNode as y,normalizeClass as E,toDisplayString as b}from"vue";import"./BaseInput.vue.js";import S from"./BaseInput.vue2.js";const q={class:"sms-captcha-wrapper"},k=["disabled"];var x=g({__name:"SmsCaptcha",props:{modelValue:{type:String,required:!0},phone:{type:String,required:!0},placeholder:{type:String,required:!1,default:"\u8BF7\u8F93\u5165\u77ED\u4FE1\u9A8C\u8BC1\u7801"},errorMessage:{type:String,required:!1}},emits:["update:modelValue","send","enter"],setup(p,{emit:i}){const r=p,n=i,o=s(r.modelValue),l=s(!1),e=s(0);let a=null;const m=h(()=>e.value>0?`${e.value}\u79D2\u540E\u91CD\u53D1`:l.value?"\u53D1\u9001\u4E2D...":"\u83B7\u53D6\u9A8C\u8BC1\u7801"),c=u=>{o.value=u,n("update:modelValue",u)},v=async()=>{if(r.phone&&!(l.value||e.value>0)){l.value=!0;try{n("send",r.phone),setTimeout(()=>{l.value=!1,f()},1e3)}catch{l.value=!1}}},f=()=>{e.value=60,a=setInterval(()=>{e.value--,e.value<=0&&a&&(clearInterval(a),a=null)},1e3)};return V(()=>{a&&clearInterval(a)}),(u,t)=>(B(),C("div",q,[D(S,{modelValue:o.value,"onUpdate:modelValue":[t[0]||(t[0]=d=>o.value=d),c],placeholder:u.placeholder,maxlength:6,"error-message":u.errorMessage,"prefix-icon":"icon-message",onEnter:t[1]||(t[1]=d=>u.$emit("enter"))},null,8,["modelValue","placeholder","error-message"]),y("button",{disabled:l.value||e.value>0,onClick:v,class:E(["sms-button",{disabled:l.value||e.value>0}])},b(m.value),11,k)]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{x as default};
//# sourceMappingURL=SmsCaptcha.vue2.js.map
