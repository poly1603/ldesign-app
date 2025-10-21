/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineComponent as l,createElementBlock as i,openBlock as m,createElementVNode as r,toDisplayString as o,unref as s}from"vue";import{useRouter as p}from"@ldesign/router";import{useI18n as u}from"../../i18n/index.js";const d={class:"error-page"},b={class:"error-content"},f={class:"error-title"},k={class:"error-message"},g={class:"error-actions"};var h=l({__name:"NotFound",setup(v){const t=p(),{t:e}=u(),a=()=>{t.push("/")},c=()=>{t.back()};return(y,n)=>(m(),i("div",d,[r("div",b,[n[0]||(n[0]=r("h1",{class:"error-code"},"404",-1)),r("h2",f,o(s(e)("errors.404.title")),1),r("p",k,o(s(e)("errors.404.message")),1),r("div",g,[r("button",{onClick:a,class:"btn btn-primary"},o(s(e)("errors.404.action")),1),r("button",{onClick:c,class:"btn btn-secondary"},o(s(e)("errors.404.back")),1)])])]))}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{h as default};
//# sourceMappingURL=NotFound.vue2.js.map
