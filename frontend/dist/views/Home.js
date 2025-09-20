import { navigate } from "../main.js";
import { t } from "../translations/index.js";
export function HomeView(app, state) {
    var _a, _b, _c;
    app.innerHTML = `
    <div class="text-center mb-4">
        <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
        <p class="text-poke-light text-xs">PONG</p>
    </div>

    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
        <h1 class="text-sm leading-relaxed mb-4">${t("subtitle")}</h1>
        <p class="text-sm leading-relaxed mb-4">${t("welcome")}, ${state.player.user || "Player"}!</p>

        <button id="gameBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 hover:border-b-red-800 active:animate-press active:border-b-red-800">
            ${t("game")}
        </button>

        <button id="tournamentBtn" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 hover:border-b-blue-800 active:animate-press active:border-b-blue-800">
            ${t("tournament")}
        </button>

        <button id="chatBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 hover:border-b-red-800 active:animate-press active:border-b-red-800">
            ${t("chat")}
        </button>
    </div>
  `;
    (_a = document.getElementById("gameBtn")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => navigate("/game"));
    (_b = document.getElementById("tournamentBtn")) === null || _b === void 0 ? void 0 : _b.addEventListener("click", () => navigate("/tournament"));
    (_c = document.getElementById("chatBtn")) === null || _c === void 0 ? void 0 : _c.addEventListener("click", () => navigate("/chat"));
}
