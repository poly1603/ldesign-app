/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as d,reactive as F,createElementBlock as f,onMounted as w,openBlock as B,createCommentVNode as C,createVNode as a,unref as u,withCtx as b}from"vue";import{useRouter as v,useRoute as h}from"@ldesign/router";import{useI18n as D}from"../i18n/index.js";import{auth as l}from"../composables/useAuth.js";import{TemplateRenderer as E}from"@ldesign/template";import R from"@/components/CustomLoginPanel.vue";const y={class:"login-page-wrapper"};var A=d({__name:"Login",setup(L){const n=v(),s=h(),{t:r}=D();F({username:"",password:""});const m=async e=>{const t=await l.login({username:e.username,password:e.password});if(t.success){e.remember&&localStorage.setItem("rememberMe","true"),console.log("\u767B\u5F55\u6210\u529F\uFF01");const o=s.query?.redirect||"/";await n.replace(o)}else{const o=t.error||r("login.errors.invalid");throw new Error(o)}},c=()=>{console.log("\u8DF3\u8F6C\u5230\u6CE8\u518C\u9875")},i=()=>{console.log("\u8DF3\u8F6C\u5230\u5FD8\u8BB0\u5BC6\u7801\u9875")};return w(()=>{if(l.isLoggedIn.value){const e=s.query?.redirect||"/";n.replace(e)}}),(e,t)=>(B(),f("div",y,[C(" TemplateRenderer \u73B0\u5728\u81EA\u52A8\u5904\u7406\u8BBE\u5907\u68C0\u6D4B\u548C\u6A21\u677F\u52A0\u8F7D "),a(u(E),{category:"login","component-props":{title:u(r)("login.title"),subtitle:u(r)("login.subtitle"),showSocialLogin:!1},onLogin:m,onRegister:c,onForgotPassword:i},{loginPanel:b(({handleSubmit:o,loading:p,error:g})=>[a(R,{"on-submit":o,loading:p,error:g,onForgotPassword:i},null,8,["on-submit","loading","error"])]),_:1},8,["component-props"])]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{A as default};
//# sourceMappingURL=Login.vue2.js.map
