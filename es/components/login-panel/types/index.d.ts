export type LoginType = 'username' | 'phone';
export interface LoginFormData {
    username?: string;
    password?: string;
    phone?: string;
    smsCode?: string;
    captcha?: string;
    remember?: boolean;
}
export type SocialLoginType = 'wechat' | 'qq' | 'github' | 'google' | 'facebook';
export interface SocialLoginConfig {
    type: SocialLoginType;
    icon: string;
    title: string;
    color?: string;
}
export type CaptchaType = 'image' | 'sms';
export interface TabItem {
    key: string;
    label: string;
    icon?: string;
}
export interface ValidationRule {
    required?: boolean;
    pattern?: RegExp;
    message: string;
    validator?: (value: any) => boolean;
}
export interface FormField {
    name: string;
    type: string;
    placeholder?: string;
    rules?: ValidationRule[];
}
