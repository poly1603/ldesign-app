/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineStore as a}from"@ldesign/store";import{ref as n,computed as o}from"vue";const s=a("counter",()=>{const e=n(0),t=n(1),r=o(()=>e.value*2),c=o(()=>e.value%2===0);function i(){e.value+=t.value}function l(){e.value-=t.value}function f(){e.value=0}function v(u){u>0&&(t.value=u)}return{count:e,step:t,doubled:r,isEven:c,increment:i,decrement:l,reset:f,setStep:v}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{s as useCounterStore};
//# sourceMappingURL=counter.js.map
