import { navigate } from "../main.js";
export function GameView(app, state) {
    var _a;
    app.innerHTML = `
    <div class="text-center mb-4">
        <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
        <p class="text-poke-light text-xs">PONG</p>
    </div>
    <div id="gameCanvasContainer" 
      class="bg-white border-2 border-dashed border-poke-dark rounded-lg w-[95vw] h-[32rem] mx-auto mb-6 flex items-center justify-center">
    </div>
    <div class="text-center">
        <button id="goBackBtn" class="bg-poke-red bg-opacity-80 text-poke-light py-2 px-6 border-3 border-poke-red border-b-red-800 rounded hover:bg-gradient-to-b hover:from-red-500 hover:to-red-600 hover:border-b-red-800 active:animate-press active:border-b-red-800">
            Go Back
        </button>
    </div>
  `;
    (_a = document.getElementById("goBackBtn")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => navigate("/"));
}
