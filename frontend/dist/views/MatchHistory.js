import { navigate } from "../main.js";
import { t } from "../translations/index.js";
export function MatchHistoryView(app, state) {
    var _a;
    // Generate random matches for demonstration
    const matches = Array.from({ length: 5 }, (_, i) => {
        const won = Math.random() > 0.5;
        return {
            opponent: `Opponent${i + 1}`,
            result: won ? t("victory") : t("defeat"),
            score: `${Math.floor(Math.random() * 10)} - ${Math.floor(Math.random() * 10)}`
        };
    });
    app.innerHTML = `
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-6 rounded-lg shadow-lg max-w-sm mx-auto flex flex-col items-center text-center">
      
      <h1 class="text-sm leading-relaxed mb-4 font-bold">${t("matchHistory")}</h1>

      <div class="w-full mb-4">
        <div class="flex justify-between font-semibold border-b-2 border-poke-dark pb-2 mb-2">
          <span>${t("opponent")}</span>
          <span>${t("result")}</span>
          <span>${t("score")}</span>
        </div>

        ${matches.map(m => `
          <div class="flex justify-between items-center p-2 border-2 border-poke-dark rounded mb-2">
            <span class="truncate">${m.opponent}</span>
            <span>${m.result}</span>
            <span>${m.score}</span>
          </div>
        `).join("")}
      </div>

      <button id="goBackBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 px-6 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 hover:border-b-red-800 active:animate-press active:border-b-red-800">
        ${t("goBack")}
      </button>
    </div>
  `;
    // Go back to statistics view
    (_a = document.getElementById("goBackBtn")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => navigate("/statistics"));
}
