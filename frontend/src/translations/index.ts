import en from "./en.js";
import fr from "./fr.js";
import es from "./es.js";

let currentLang: "en" | "fr" | "es" = (localStorage.getItem("lang") as "en" | "fr" | "es") || "en";

const translations: Record<string, Record<string, string>> = { en, fr, es };

export function setLanguage(lang: "en" | "fr" | "es") {
  currentLang = lang;
  localStorage.setItem("lang", lang);
}

export function getLanguage(): "en" | "fr" | "es" {
  return currentLang;
}

export function t(key: string): string {
  return translations[currentLang]?.[key] || key;
}
