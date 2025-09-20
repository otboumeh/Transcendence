import { navigate } from "../main.js";
import { t } from "../translations/index.js";

export function ChatView(app: HTMLElement, state: any): void {
  app.innerHTML = `
    <div class="text-center mb-4">
      <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
      <p class="text-poke-light text-xs">PONG</p>
    </div>
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
      <h2 class="text-sm leading-relaxed mb-4">${t("chat")}</h2>
      <p class="text-sm leading-relaxed mb-4">
        ${t("welcome")}, ${state.player.alias || t("player")}! ${t("chat_info")}
      </p>
      <button id="goBackBtn3" class="bg-poke-red bg-opacity-80 text-poke-light py-2 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 hover:border-b-red-800 active:animate-press active:border-b-red-800">
        ${t("go_back")}
      </button>
    </div>
  `;

  document.getElementById("goBackBtn3")?.addEventListener("click", () => navigate("/"));
}
