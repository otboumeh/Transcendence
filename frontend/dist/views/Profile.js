import { navigate } from "../main.js";
import { t } from "../translations/index.js";
export function ProfileView(app, state) {
    var _a;
    app.innerHTML = `
    <div class="text-center mb-4">
      <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
      <p class="text-poke-light text-xs">PONG</p>
    </div>
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
      <h2 class="text-sm leading-relaxed mb-4">${t("profile")}</h2>
      <p class="text-sm mb-4">
        ${t("welcome")}, ${state.player.user || t("player")}!
        ${t("username_info")}
      </p>
      <input type="text" id="userEnter" placeholder="${t("new_username")}"
        class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
      <div class="flex justify-center">
        <button id="userButton"
          class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 hover:border-b-blue-800 active:animate-press active:border-b-blue-800">
          ${t("enter_username")}
        </button>   
      </div>
    </div>
  `;
    (_a = document.getElementById("userButton")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => {
        var _a;
        const input = document.getElementById("userEnter");
        if (!input)
            return;
        const user = input.value.trim();
        if (!user) {
            app.innerHTML = `
        <div class="text-center mb-4">
          <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
          <p class="text-poke-light text-xs">PONG</p>
        </div>
        <div class="bg-poke-light text-poke-red border-3 border-poke-red p-4 rounded-lg shadow-lg">
          <h2 class="text-sm leading-relaxed mb-4">${t("registration")}</h2>
          <p class="text-sm leading-relaxed mb-4">${t("error_empty_user")}</p>
          <div class="flex justify-center">
            <button id="returnBtn"
              class="bg-gradient-to-b from-poke-red to-red-700 text-poke-light py-2 border-3 border-poke-dark border-b-red-900 rounded 
                     hover:from-red-500 hover:to-red-600 active:animate-press active:border-b-poke-dark">
              ${t("return")}
            </button>
          </div>
        </div>
      `;
            (_a = document.getElementById("returnBtn")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => {
                navigate("/profile");
            });
            return;
        }
        state.player.user = user;
        localStorage.setItem("player", JSON.stringify(state.player));
        if (state.player.avatar === 0)
            navigate("/choose");
        else
            navigate("/");
    });
}
