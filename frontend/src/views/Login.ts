import { navigate } from "../main.js";
import { t } from "../translations/index.js";

export function LoginView(app: HTMLElement, state: any): void {
  app.innerHTML = `
    <div class="text-center mb-4">
      <h1 class="text-poke-yellow text-2xl">POKéMON</h1>
      <p class="text-poke-light text-xs">PONG</p>
    </div>
    <div class="bg-poke-light bg-opacity-60 text-poke-dark border-3 border-poke-dark p-4 rounded-lg shadow-lg">
      <h2 class="text-sm leading-relaxed mb-4">${t("Login")}</h2>
      <input type="text" id="username" placeholder="${t("username")}"
        class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
      <input type="password" id="password" placeholder="${t("Password")}"
        class="border-2 border-pixel-black px-4 py-2 mb-4 w-full" />
      <div class="flex justify-center gap-4">
        <button id="loginBtn"
          class="bg-poke-blue bg-opacity-80 text-poke-light py-2 border-3 border-poke-blue border-b-blue-800 rounded hover:bg-gradient-to-b hover:from-blue-500 hover:to-blue-600 active:animate-press">
          ${t("Login")}
        </button>
        <button id="back"
          class="bg-gradient-to-b from-poke-red to-red-700 text-poke-light py-2 border-3 border-poke-red border-b-red-900 rounded 
                 hover:from-red-500 hover:to-red-600 active:animate-press">
          ${t("Back")}
        </button>
      </div>
      <div id="loginError" class="text-red-600 text-center mt-3 text-sm"></div>
    </div>
  `;

  const loginBtn = document.getElementById("loginBtn");
  const backBtn = document.getElementById("back");

  backBtn?.addEventListener("click", () => navigate("/register"));

  loginBtn?.addEventListener("click", async () => {
    const usernameInput = document.getElementById("username") as HTMLInputElement;
    const passwordInput = document.getElementById("password") as HTMLInputElement;
    const errorDiv = document.getElementById("loginError")!;

    const username = usernameInput.value.trim();
    const pass = passwordInput.value.trim();

    if (!username || !pass) {
      errorDiv.textContent = "⚠️ Please fill in all fields";
      return;
    }

    try {
      const response = await fetch("http://localhost:8085/api/login.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, pass }),
      });

      const text = await response.text();
      console.log("Backend returned:", text);

      let data: any;
      try {
        data = JSON.parse(text);
      } catch {
        throw new Error("Invalid JSON response from backend");
      }

      // ❌ Aquí comprobamos si hay error y lo mostramos
      if (data.error) {
        errorDiv.textContent = data.error;
        return; // ¡detenemos la navegación!
      }

      // ✅ Si requiere 2FA
      if (data.pending_2fa) {
        localStorage.setItem("pendingUserId", data.user_id);
        navigate("/choose");
      } else {
        navigate("/"); // login exitoso
      }

    } catch (err) {
      console.error("❌ Network or server error:", err);
      errorDiv.textContent = "Network error. Backend unreachable.";
    }
  });
}
