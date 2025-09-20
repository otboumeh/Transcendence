import { navigate } from "../main.js";
export function updateHeader(state) {
    const header = document.querySelector("header");
    if (!header)
        return;
    // Determine avatar source
    let avatarSrc = "";
    if (state.player.avatar !== null && state.player.avatar !== undefined) {
        if (typeof state.player.avatar === "number") {
            avatarSrc = `/assets/avatar${state.player.avatar}.png`; // built-in avatar
        }
        else if (typeof state.player.avatar === "string") {
            avatarSrc = state.player.avatar; // uploaded avatar (base64 or URL)
        }
    }
    header.innerHTML = `
    <div class="relative flex items-center justify-center">
      <p class="text-lg font-bold">PONG</p>
      ${avatarSrc
        ? `<div class="absolute right-4 flex items-center space-x-2">
                <img src="${avatarSrc}"
                     id="avBtn"
                     alt="avatar"
                     class="w-10 h-10 rounded-full cursor-pointer hover:opacity-80"/>
                <img src="/assets/settings.png"
                     id="settingsBtn"
                     alt="settings"
                     class="w-10 h-10 rounded-full cursor-pointer hover:opacity-80"/>
             </div>`
        : ""}
    </div>
  `;
    const settingsBtn = document.getElementById("settingsBtn");
    const avBtn = document.getElementById("avBtn");
    if (settingsBtn)
        settingsBtn.addEventListener("click", () => navigate("/settings"));
    if (avBtn)
        avBtn.addEventListener("click", () => navigate("/statistics"));
}
