"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var a=require("@ldesign/store"),u=require("vue");const l=a.defineStore("counter",()=>{const e=u.ref(0),t=u.ref(1),n=u.computed(()=>e.value*2),o=u.computed(()=>e.value%2===0);function c(){e.value+=t.value}function s(){e.value-=t.value}function v(){e.value=0}function i(r){r>0&&(t.value=r)}return{count:e,step:t,doubled:n,isEven:o,increment:c,decrement:s,reset:v,setStep:i}});exports.useCounterStore=l;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=counter.cjs.map
