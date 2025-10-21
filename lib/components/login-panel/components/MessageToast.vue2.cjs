"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue");const m={class:"message-icon"},g={class:"message-content"};var v=e.defineComponent({__name:"MessageToast",setup(f,{expose:l}){const o=e.ref([]);let u=0;const p=s=>({success:"\u2713",error:"\u2715",warning:"\u26A0",info:"\u2139"})[s],a=(s,t="info",n=3e3)=>{const c=++u;o.value.push({id:c,type:t,content:s}),setTimeout(()=>{const i=o.value.findIndex(d=>d.id===c);i>-1&&o.value.splice(i,1)},n)},r={success:(s,t)=>a(s,"success",t),error:(s,t)=>a(s,"error",t),warning:(s,t)=>a(s,"warning",t),info:(s,t)=>a(s,"info",t)};return l({message:r}),e.provide("message",r),(s,t)=>(e.openBlock(),e.createBlock(e.Teleport,{to:"body"},[e.createVNode(e.TransitionGroup,{name:"message",tag:"div",class:"message-container"},{default:e.withCtx(()=>[(e.openBlock(!0),e.createElementBlock(e.Fragment,null,e.renderList(o.value,n=>(e.openBlock(),e.createElementBlock("div",{key:n.id,class:e.normalizeClass(["message-toast",`message-${n.type}`])},[e.createElementVNode("span",m,e.toDisplayString(p(n.type)),1),e.createElementVNode("span",g,e.toDisplayString(n.content),1)],2))),128))]),_:1})]))}});exports.default=v;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=MessageToast.vue2.cjs.map
