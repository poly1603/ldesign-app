"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue");const u={class:"login-tabs"},m={class:"tabs-header"},p=["onClick"],k={key:0,class:"tab-icon"},v={class:"tab-label"},b={class:"tabs-content"};var y=e.defineComponent({__name:"LoginTabs",props:{modelValue:{type:String,required:!1},tabs:{type:Array,required:!0}},emits:["update:modelValue","change"],setup(s,{emit:r}){const n=s,o=r,a=e.ref(n.modelValue||n.tabs[0]?.key||""),c=e.computed(()=>n.tabs.findIndex(t=>t.key===a.value)),i=e.computed(()=>{const t=c.value;return{width:`${100/n.tabs.length}%`,transform:`translateX(${t*100}%)`}}),d=t=>{a.value=t,o("update:modelValue",t),o("change",t)};return e.watch(()=>n.modelValue,t=>{t&&(a.value=t)}),(t,V)=>(e.openBlock(),e.createElementBlock("div",u,[e.createElementVNode("div",m,[(e.openBlock(!0),e.createElementBlock(e.Fragment,null,e.renderList(t.tabs,l=>(e.openBlock(),e.createElementBlock("div",{key:l.key,class:e.normalizeClass(["tab-item",{active:a.value===l.key}]),onClick:B=>d(l.key)},[l.icon?(e.openBlock(),e.createElementBlock("span",k,[e.createElementVNode("i",{class:e.normalizeClass(l.icon)},null,2)])):e.createCommentVNode("v-if",!0),e.createElementVNode("span",v,e.toDisplayString(l.label),1)],10,p))),128)),e.createElementVNode("div",{class:"tab-indicator",style:e.normalizeStyle(i.value)},null,4)]),e.createElementVNode("div",b,[e.createVNode(e.Transition,{name:"tab-fade",mode:"out-in"},{default:e.withCtx(()=>[(e.openBlock(),e.createElementBlock("div",{key:a.value,class:"tab-panel"},[e.renderSlot(t.$slots,a.value)]))]),_:3})])]))}});exports.default=y;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=LoginTabs.vue2.cjs.map
