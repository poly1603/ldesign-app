"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var o=require("vue"),F=require("@ldesign/router");require("./login-panel/LoginPanelV2.vue.cjs");var B=require("../composables/useAuth.cjs"),s=require("./login-panel/composables/useMessage.cjs"),g=require("./login-panel/LoginPanelV2.vue2.cjs"),f=o.defineComponent({__name:"CustomLoginPanel",setup(m){const t=F.useRouter(),{login:a}=B.useAuth(),n=o.ref(),u=s.useMessage();o.onMounted(()=>{n.value?.message&&s.setGlobalMessage(n.value.message)});const l=async e=>{try{let r=!1;if(e.type==="account")r=await a(e.username,e.password);else{console.log("Phone login:",e.phone,e.smsCode),u.info("\u624B\u673A\u53F7\u767B\u5F55\u529F\u80FD\u5F85\u5B9E\u73B0");return}r?(u.success("\u767B\u5F55\u6210\u529F"),e.remember&&localStorage.setItem("remember","true"),t.push("/")):u.error("\u7528\u6237\u540D\u6216\u5BC6\u7801\u9519\u8BEF")}catch(r){console.error("\u767B\u5F55\u5931\u8D25",r),u.error("\u767B\u5F55\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5")}},i=e=>{console.log("Social login:",e),u.info(`${e} \u767B\u5F55\u529F\u80FD\u5F85\u5B9E\u73B0`)},c=()=>{u.info("\u5FD8\u8BB0\u5BC6\u7801\u529F\u80FD\u5F85\u5B9E\u73B0")};return(e,r)=>(o.openBlock(),o.createBlock(g.default,{ref_key:"loginPanelRef",ref:n,onLogin:l,onSocialLogin:i,onForgot:c},null,512))}});exports.default=f;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=CustomLoginPanel.vue2.cjs.map
