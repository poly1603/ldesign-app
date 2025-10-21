/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */const n=()=>import("@/views/Main.vue"),m=()=>import("@/views/Home.vue"),u=()=>import("@/views/Login.vue"),l=()=>import("@/views/Dashboard.vue"),r=()=>import("@/views/About.vue"),p=()=>import("@/views/CryptoDemo.vue"),i=()=>import("@/views/HttpDemo.vue"),h=()=>import("@/views/ApiDemo.vue"),t=[{path:"/",name:"home",component:n,meta:{titleKey:"nav.home",requiresAuth:!1,layout:"default"},children:[{path:"",name:"Home",component:m,meta:{titleKey:"nav.home",requiresAuth:!1,layout:"default"}},{path:"about",name:"About",component:r,meta:{titleKey:"nav.about",requiresAuth:!1,layout:"default"}},{path:"crypto",name:"CryptoDemo",component:p,meta:{titleKey:"nav.crypto",requiresAuth:!1,layout:"default"}},{path:"http",name:"HttpDemo",component:i,meta:{titleKey:"nav.http",requiresAuth:!1,layout:"default"}},{path:"api",name:"ApiDemo",component:h,meta:{titleKey:"nav.api",requiresAuth:!1,layout:"default"}}]},{path:"/login",name:"login",component:u,meta:{titleKey:"nav.login",requiresAuth:!1,layout:"blank"}}],e=[{path:"/dashboard",name:"dashboard",component:l,meta:{titleKey:"nav.dashboard",requiresAuth:!1,layout:"default",roles:["user","admin"]}}],a=[{path:"/:pathMatch(.*)*",name:"not-found",component:()=>import("@/views/errors/NotFound.vue"),meta:{titleKey:"errors.404.title",layout:"blank"}}],o=[...t,...e,...a];/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{e as authRoutes,o as default,a as errorRoutes,t as publicRoutes,o as routes};
//# sourceMappingURL=routes.js.map
