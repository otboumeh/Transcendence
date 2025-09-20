import { navigate } from "../main.js";
import { t } from "../translations/index.js";

export function SettingsView(app: HTMLElement, state: any): void {
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

  document.getElementById("cuseBtn")?.addEventListener("click", () => navigate("/profile"));
  document.getElementById("cavtBtn")?.addEventListener("click", () => navigate("/avatar"));
  document.getElementById("cfrBtn")?.addEventListener("click", () => navigate("/chat"));
  document.getElementById("clangBtn")?.addEventListener("click", () => navigate("/language"));
  document.getElementById("gbcBtn")?.addEventListener("click", () => navigate("/"));
}
