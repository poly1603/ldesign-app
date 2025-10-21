/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as i,ref as m,onMounted as F,createBlock as c,openBlock as B}from"vue";import{useRouter as p}from"@ldesign/router";import"./login-panel/LoginPanelV2.vue.js";import{useAuth as f}from"../composables/useAuth.js";import{useMessage as g,setGlobalMessage as D}from"./login-panel/composables/useMessage.js";import C from"./login-panel/LoginPanelV2.vue2.js";var d=i({__name:"CustomLoginPanel",setup(h){const n=p(),{login:s}=f(),r=m(),o=g();F(()=>{r.value?.message&&D(r.value.message)});const t=async u=>{try{let e=!1;if(u.type==="account")e=await s(u.username,u.password);else{console.log("Phone login:",u.phone,u.smsCode),o.info("\u624B\u673A\u53F7\u767B\u5F55\u529F\u80FD\u5F85\u5B9E\u73B0");return}e?(o.success("\u767B\u5F55\u6210\u529F"),u.remember&&localStorage.setItem("remember","true"),n.push("/")):o.error("\u7528\u6237\u540D\u6216\u5BC6\u7801\u9519\u8BEF")}catch(e){console.error("\u767B\u5F55\u5931\u8D25",e),o.error("\u767B\u5F55\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5")}},l=u=>{console.log("Social login:",u),o.info(`${u} \u767B\u5F55\u529F\u80FD\u5F85\u5B9E\u73B0`)},a=()=>{o.info("\u5FD8\u8BB0\u5BC6\u7801\u529F\u80FD\u5F85\u5B9E\u73B0")};return(u,e)=>(B(),c(C,{ref_key:"loginPanelRef",ref:r,onLogin:t,onSocialLogin:l,onForgot:a},null,512))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{d as default};
//# sourceMappingURL=CustomLoginPanel.vue2.js.map
