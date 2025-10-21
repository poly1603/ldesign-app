export interface MessageApi {
    success: (content: string, duration?: number) => void;
    error: (content: string, duration?: number) => void;
    warning: (content: string, duration?: number) => void;
    info: (content: string, duration?: number) => void;
}
export declare function setGlobalMessage(messageApi: MessageApi): void;
export declare function useMessage(): MessageApi;
