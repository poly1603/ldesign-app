"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var f=require("@ldesign/store"),u=require("vue");const d=f.defineStore("user",()=>{const r=u.ref(null),a=u.ref(null),t=u.ref(!1),s=u.computed(()=>!!r.value&&!!a.value),o=u.computed(()=>r.value?.username||"Guest"),l=u.computed(()=>r.value?.roles||[]),i=u.computed(()=>l.value.includes("admin"));async function c(e,p){t.value=!0;try{return await new Promise(n=>setTimeout(n,1e3)),r.value={id:"1",username:e,email:`${e}@example.com`,avatar:`https://api.dicebear.com/7.x/avataaars/svg?seed=${e}`,roles:e==="admin"?["admin","user"]:["user"]},a.value="mock-jwt-token-"+Date.now(),!0}catch(n){return console.error("Login failed:",n),!1}finally{t.value=!1}}function v(){r.value=null,a.value=null}async function m(){if(!a.value)return null;t.value=!0;try{return await new Promise(e=>setTimeout(e,500)),r.value}catch(e){return console.error("Failed to fetch user info:",e),null}finally{t.value=!1}}return{currentUser:r,token:a,isLoading:t,isAuthenticated:s,userName:o,userRoles:l,isAdmin:i,login:c,logout:v,fetchUserInfo:m}},{persist:{enabled:!0,paths:["currentUser","token"]}});exports.useUserStore=d;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=user.cjs.map
