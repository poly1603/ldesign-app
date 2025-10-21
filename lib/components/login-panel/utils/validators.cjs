"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */const e=u=>/^[a-zA-Z0-9_]{4,20}$/.test(u),t=u=>/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$/.test(u),s=u=>/^1[3-9]\d{9}$/.test(u),d=(u,r=4)=>new RegExp(`^[A-Za-z0-9]{${r}}$`).test(u),i=u=>/^\d{6}$/.test(u),l=u=>/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(u),a=u=>typeof u=="string"?u.trim().length>0:u!=null,F={username:{required:{message:"\u8BF7\u8F93\u5165\u7528\u6237\u540D",validator:a},pattern:{message:"\u7528\u6237\u540D\u683C\u5F0F\u4E0D\u6B63\u786E\uFF084-20\u4F4D\u5B57\u6BCD\u3001\u6570\u5B57\u6216\u4E0B\u5212\u7EBF\uFF09",validator:e}},password:{required:{message:"\u8BF7\u8F93\u5165\u5BC6\u7801",validator:a},pattern:{message:"\u5BC6\u7801\u81F3\u5C118\u4F4D\uFF0C\u5305\u542B\u5B57\u6BCD\u548C\u6570\u5B57",validator:t}},phone:{required:{message:"\u8BF7\u8F93\u5165\u624B\u673A\u53F7",validator:a},pattern:{message:"\u8BF7\u8F93\u5165\u6B63\u786E\u7684\u624B\u673A\u53F7",validator:s}},captcha:{required:{message:"\u8BF7\u8F93\u5165\u9A8C\u8BC1\u7801",validator:a},pattern:{message:"\u9A8C\u8BC1\u7801\u683C\u5F0F\u4E0D\u6B63\u786E",validator:d}},smsCode:{required:{message:"\u8BF7\u8F93\u5165\u77ED\u4FE1\u9A8C\u8BC1\u7801",validator:a},pattern:{message:"\u8BF7\u8F93\u51656\u4F4D\u6570\u5B57\u9A8C\u8BC1\u7801",validator:i}}};exports.validateCaptcha=d,exports.validateEmail=l,exports.validatePassword=t,exports.validatePhone=s,exports.validateRequired=a,exports.validateSmsCode=i,exports.validateUsername=e,exports.validationRules=F;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=validators.cjs.map
