import { navigate } from "../main.js";
import { setLanguage, t } from "../translations/index.js";
export function LanguageView(app, state) {
    var _a, _b, _c, _d;
    app.innerHTML = `
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg max-w-lg mx-auto">
      <h1 class="text-sm leading-relaxed mb-4 text-center">${t("chooseLanguage")}</h1>

      <div class="grid grid-cols-1 gap-3">
        <button id="lang-en" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press">
          🇬🇧 ${t("english")}
        </button>

        <button id="lang-fr" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press">
          🇫🇷 ${t("french")}
        </button>

        <button id="lang-es" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press">
          🇪🇸 ${t("spanish")}
        </button>

        <button id="lang-back" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press">
          ${t("back")}
        </button>
      </div>
    </div>
  `;
    (_a = document.getElementById("lang-en")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => {
        setLanguage("en");
        navigate("/settings");
    });
    (_b = document.getElementById("lang-fr")) === null || _b === void 0 ? void 0 : _b.addEventListener("click", () => {
        setLanguage("fr");
        navigate("/settings");
    });
    (_c = document.getElementById("lang-es")) === null || _c === void 0 ? void 0 : _c.addEventListener("click", () => {
        setLanguage("es");
        navigate("/settings");
    });
    (_d = document.getElementById("lang-back")) === null || _d === void 0 ? void 0 : _d.addEventListener("click", () => navigate("/settings"));
}
