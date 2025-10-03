var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
/* import { navigate } from "../main.js";
import { t } from "../translations/index.js";

export function Profile1View(app: HTMLElement, state: any): void {
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
     <input type="text" id="mailEnter" placeholder="mail"
        class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
    <input type="text" id="userEnter" placeholder="pasword"
        class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
      <div class="flex justify-center">
        <button id="userButton"
          class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 hover:border-b-blue-800 active:animate-press active:border-b-blue-800">
          ${t("enter_user")}
        </button>
      </div>
    </div>
  `;

  document.getElementById("userButton")?.addEventListener("click", () => {
    const input = document.getElementById("userEnter") as HTMLInputElement | null;
    if (!input) return;

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
      
      document.getElementById("returnBtn")?.addEventListener("click", () => {
        navigate("/profile1");
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
} */
import { navigate } from "../main.js";
import { t } from "../translations/index.js";
export function Profile1View(app, state) {
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
        <input type="email" id="mailEnter" placeholder="Email"
          class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
        <input type="password" id="passEnter" placeholder="Password"
          class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
        <div class="flex justify-center">
          <button id="userButton"
            class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 hover:border-b-blue-800 active:animate-press active:border-b-blue-800">
            ${t("enter_user")}
          </button>   
        </div>
      </div>
    `;
    (_a = document.getElementById("userButton")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", () => __awaiter(this, void 0, void 0, function* () {
        const usernameInput = document.getElementById("userEnter");
        const emailInput = document.getElementById("mailEnter");
        const passwordInput = document.getElementById("passEnter");
        if (!usernameInput || !emailInput || !passwordInput) {
            alert("Error interno: no se encontraron los inputs");
            return;
        }
        const username = usernameInput.value.trim();
        const email = emailInput.value.trim();
        const pass = passwordInput.value.trim();
        if (!username || !email || !pass) {
            alert("Todos los campos son obligatorios");
            return;
        }
        try {
            const response = yield fetch("http://localhost:8085/api/users.php", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ username, email, pass })
            });
            // Intentamos parsear JSON, pero validamos antes si es correcto
            const text = yield response.text();
            let data;
            try {
                data = JSON.parse(text);
            }
            catch (_a) {
                console.error("Respuesta no JSON:", text);
                alert("Error inesperado del servidor");
                return;
            }
            if (!response.ok) {
                alert("Error: " + (data.error || "Bad Request"));
                return;
            }
            alert("Usuario creado correctamente");
            // Actualizamos estado local y navegamos si es necesario
            state.player.user = username;
            localStorage.setItem("player", JSON.stringify(state.player));
            if (state.player.avatar === 0)
                navigate("/choose");
            else
                navigate("/");
        }
        catch (err) {
            console.error(err);
            alert("Error de conexión con el servidor");
        }
    }));
}
