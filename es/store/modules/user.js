/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineStore as d}from"@ldesign/store";import{ref as l,computed as u}from"vue";const p=d("user",()=>{const r=l(null),a=l(null),t=l(!1),o=u(()=>!!r.value&&!!a.value),i=u(()=>r.value?.username||"Guest"),s=u(()=>r.value?.roles||[]),c=u(()=>s.value.includes("admin"));async function m(e,h){t.value=!0;try{return await new Promise(n=>setTimeout(n,1e3)),r.value={id:"1",username:e,email:`${e}@example.com`,avatar:`https://api.dicebear.com/7.x/avataaars/svg?seed=${e}`,roles:e==="admin"?["admin","user"]:["user"]},a.value="mock-jwt-token-"+Date.now(),!0}catch(n){return console.error("Login failed:",n),!1}finally{t.value=!1}}function f(){r.value=null,a.value=null}async function v(){if(!a.value)return null;t.value=!0;try{return await new Promise(e=>setTimeout(e,500)),r.value}catch(e){return console.error("Failed to fetch user info:",e),null}finally{t.value=!1}}return{currentUser:r,token:a,isLoading:t,isAuthenticated:o,userName:i,userRoles:s,isAdmin:c,login:m,logout:f,fetchUserInfo:v}},{persist:{enabled:!0,paths:["currentUser","token"]}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{p as useUserStore};
//# sourceMappingURL=user.js.map
