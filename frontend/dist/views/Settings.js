import { navigate } from "../main.js";
import { t } from "../translations/index.js";
export function SettingsView(app, state) {
    var _a, _b, _c, _d, _e;
    app.innerHTML = `
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
        <h1 class="text-sm leading-relaxed mb-4">${t("settings")}</h1>

        <button id="cuseBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded mb-2 w-full hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press active:border-b-red-800">
            ${t("changeUser")}
        </button>

        <button id="cavtBtn" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded mb-2 w-full hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press active:border-b-blue-800">
            ${t("changeAvatar")}
        </button>

        <button id="cfrBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded mb-2 w-full hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press active:border-b-red-800">
            ${t("friends")}
        </button>

        <button id="clangBtn" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded mb-2 w-full hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press active:border-b-blue-800">
            ${t("changeLanguage")}
        </button>

        <button id="gbcBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded mb-2 w-full hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press active:border-b-red-800">
            ${t("goBack")}
        </button>
    </div>
  `;
    (_a = document.getElementById("cuseBtn")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => navigate("/profile"));
    (_b = document.getElementById("cavtBtn")) === null || _b === void 0 ? void 0 : _b.addEventListener("click", () => navigate("/avatar"));
    (_c = document.getElementById("cfrBtn")) === null || _c === void 0 ? void 0 : _c.addEventListener("click", () => navigate("/chat"));
    (_d = document.getElementById("clangBtn")) === null || _d === void 0 ? void 0 : _d.addEventListener("click", () => navigate("/language"));
    (_e = document.getElementById("gbcBtn")) === null || _e === void 0 ? void 0 : _e.addEventListener("click", () => navigate("/"));
}
