"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("vue"),i=require("@ldesign/router"),m=require("../i18n/index.cjs"),l=require("../composables/useAuth.cjs"),v=require("@ldesign/template"),F=require("@/components/CustomLoginPanel.vue");const w={class:"login-page-wrapper"};var B=e.defineComponent({__name:"Login",setup(C){const n=i.useRouter(),s=i.useRoute(),{t:u}=m.useI18n();e.reactive({username:"",password:""});const c=async r=>{const t=await l.auth.login({username:r.username,password:r.password});if(t.success){r.remember&&localStorage.setItem("rememberMe","true"),console.log("\u767B\u5F55\u6210\u529F\uFF01");const o=s.query?.redirect||"/";await n.replace(o)}else{const o=t.error||u("login.errors.invalid");throw new Error(o)}},d=()=>{console.log("\u8DF3\u8F6C\u5230\u6CE8\u518C\u9875")},a=()=>{console.log("\u8DF3\u8F6C\u5230\u5FD8\u8BB0\u5BC6\u7801\u9875")};return e.onMounted(()=>{if(l.auth.isLoggedIn.value){const r=s.query?.redirect||"/";n.replace(r)}}),(r,t)=>(e.openBlock(),e.createElementBlock("div",w,[e.createCommentVNode(" TemplateRenderer \u73B0\u5728\u81EA\u52A8\u5904\u7406\u8BBE\u5907\u68C0\u6D4B\u548C\u6A21\u677F\u52A0\u8F7D "),e.createVNode(e.unref(v.TemplateRenderer),{category:"login","component-props":{title:e.unref(u)("login.title"),subtitle:e.unref(u)("login.subtitle"),showSocialLogin:!1},onLogin:c,onRegister:d,onForgotPassword:a},{loginPanel:e.withCtx(({handleSubmit:o,loading:g,error:p})=>[e.createVNode(F,{"on-submit":o,loading:g,error:p,onForgotPassword:a},null,8,["on-submit","loading","error"])]),_:1},8,["component-props"])]))}});exports.default=B;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=Login.vue2.cjs.map
