/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as v,ref as y,computed as r,createElementBlock as s,watch as k,openBlock as n,createElementVNode as o,Fragment as f,renderList as g,normalizeClass as c,createCommentVNode as V,toDisplayString as h,normalizeStyle as C,createVNode as w,Transition as x,withCtx as N,renderSlot as S}from"vue";const _={class:"login-tabs"},z={class:"tabs-header"},B=["onClick"],E={key:0,class:"tab-icon"},L={class:"tab-label"},$={class:"tabs-content"};var q=v({__name:"LoginTabs",props:{modelValue:{type:String,required:!1},tabs:{type:Array,required:!0}},emits:["update:modelValue","change"],setup(d,{emit:u}){const l=d,i=u,t=y(l.modelValue||l.tabs[0]?.key||""),m=r(()=>l.tabs.findIndex(e=>e.key===t.value)),p=r(()=>{const e=m.value;return{width:`${100/l.tabs.length}%`,transform:`translateX(${e*100}%)`}}),b=e=>{t.value=e,i("update:modelValue",e),i("change",e)};return k(()=>l.modelValue,e=>{e&&(t.value=e)}),(e,T)=>(n(),s("div",_,[o("div",z,[(n(!0),s(f,null,g(e.tabs,a=>(n(),s("div",{key:a.key,class:c(["tab-item",{active:t.value===a.key}]),onClick:A=>b(a.key)},[a.icon?(n(),s("span",E,[o("i",{class:c(a.icon)},null,2)])):V("v-if",!0),o("span",L,h(a.label),1)],10,B))),128)),o("div",{class:"tab-indicator",style:C(p.value)},null,4)]),o("div",$,[w(x,{name:"tab-fade",mode:"out-in"},{default:N(()=>[(n(),s("div",{key:t.value,class:"tab-panel"},[S(e.$slots,t.value)]))]),_:3})])]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{q as default};
//# sourceMappingURL=LoginTabs.vue2.js.map
