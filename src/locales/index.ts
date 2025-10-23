/**
 * 语言包索引
 */

import zhCN from './zh-CN';
import enUS from './en-US';
import jaJP from './ja-JP';
import frFR from './fr-FR';

export const messages = {
  'zh-CN': zhCN,
  'en-US': enUS,
  'ja-JP': jaJP,
  'fr-FR': frFR
};

export const availableLocales = [
  { code: 'zh-CN', name: '简体中文', flag: '🇨🇳' },
  { code: 'en-US', name: 'English', flag: '🇺🇸' },
  { code: 'ja-JP', name: '日本語', flag: '🇯🇵' },
  { code: 'fr-FR', name: 'Français', flag: '🇫🇷' }
];

export default messages;