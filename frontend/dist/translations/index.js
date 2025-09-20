import en from "./en.js";
import fr from "./fr.js";
import es from "./es.js";
let currentLang = localStorage.getItem("lang") || "en";
const translations = { en, fr, es };
export function setLanguage(lang) {
    currentLang = lang;
    localStorage.setItem("lang", lang);
}
export function getLanguage() {
    return currentLang;
}
export function t(key) {
    var _a;
    return ((_a = translations[currentLang]) === null || _a === void 0 ? void 0 : _a[key]) || key;
}
