import { navigate } from "../main.js";
import { updateHeader } from "./Header.js";
import { t } from "../translations/index.js";

export function ChooseView(app: HTMLElement, state: any): void {
  app.innerHTML = `
    <div class="text-center mb-4">
      <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
      <p class="text-poke-light text-xs">PONG</p>
    </div>
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
      <h1 class="text-sm leading-relaxed mb-4">${t("new_avatar")}</h1>
      <button id="withABtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded mb-2 w-full
        hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 active:animate-press active:border-b-red-800">
        ${t("choose_new_avatar")}
      </button>
      <button id="withoutABtn" class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded mb-2 w-full
        hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press active:border-b-blue-800">
        ${t("continue_without_avatar")}
      </button>
    </div>
  `;

  document.getElementById("withABtn")?.addEventListener("click", () => navigate("/avatar"));
  document.getElementById("withoutABtn")?.addEventListener("click", () => {
    state.player.avatar = 10;
    updateHeader(state);
    navigate("/");
  });
};
