/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as v,ref as y,createBlock as k,provide as w,openBlock as o,Teleport as x,createVNode as B,TransitionGroup as T,withCtx as C,createElementBlock as l,Fragment as N,renderList as _,normalizeClass as b,createElementVNode as u,toDisplayString as m}from"vue";const h={class:"message-icon"},E={class:"message-content"};var V=v({__name:"MessageToast",setup(z,{expose:p}){const a=y([]);let d=0;const g=e=>({success:"\u2713",error:"\u2715",warning:"\u26A0",info:"\u2139"})[e],n=(e,s="info",t=3e3)=>{const c=++d;a.value.push({id:c,type:s,content:e}),setTimeout(()=>{const i=a.value.findIndex(f=>f.id===c);i>-1&&a.value.splice(i,1)},t)},r={success:(e,s)=>n(e,"success",s),error:(e,s)=>n(e,"error",s),warning:(e,s)=>n(e,"warning",s),info:(e,s)=>n(e,"info",s)};return p({message:r}),w("message",r),(e,s)=>(o(),k(x,{to:"body"},[B(T,{name:"message",tag:"div",class:"message-container"},{default:C(()=>[(o(!0),l(N,null,_(a.value,t=>(o(),l("div",{key:t.id,class:b(["message-toast",`message-${t.type}`])},[u("span",h,m(g(t.type)),1),u("span",E,m(t.content),1)],2))),128))]),_:1})]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{V as default};
//# sourceMappingURL=MessageToast.vue2.js.map
