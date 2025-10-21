export declare const validateUsername: (value: string) => boolean;
export declare const validatePassword: (value: string) => boolean;
export declare const validatePhone: (value: string) => boolean;
export declare const validateCaptcha: (value: string, length?: number) => boolean;
export declare const validateSmsCode: (value: string) => boolean;
export declare const validateEmail: (value: string) => boolean;
export declare const validateRequired: (value: any) => boolean;
export declare const validationRules: {
    username: {
        required: {
            message: string;
            validator: (value: any) => boolean;
        };
        pattern: {
            message: string;
            validator: (value: string) => boolean;
        };
    };
    password: {
        required: {
            message: string;
            validator: (value: any) => boolean;
        };
        pattern: {
            message: string;
            validator: (value: string) => boolean;
        };
    };
    phone: {
        required: {
            message: string;
            validator: (value: any) => boolean;
        };
        pattern: {
            message: string;
            validator: (value: string) => boolean;
        };
    };
    captcha: {
        required: {
            message: string;
            validator: (value: any) => boolean;
        };
        pattern: {
            message: string;
            validator: (value: string, length?: number) => boolean;
        };
    };
    smsCode: {
        required: {
            message: string;
            validator: (value: any) => boolean;
        };
        pattern: {
            message: string;
            validator: (value: string) => boolean;
        };
    };
};
