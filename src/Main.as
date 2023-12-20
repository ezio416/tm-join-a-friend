// c 2023-12-20
// m 2023-12-20

string title = "\\$3AD" + Icons::Kenney::UsersAlt + "\\$G Join a Friend";

[Setting hidden]
string friendLink = "";

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled ||
        (S_HideWithGame && !UI::IsGameUIVisible()) ||
        (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    string currentLink = GetServerLink();

    UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize);
        UI::Text("My server link:");
        if (currentLink != "") {
            if (UI::Selectable(currentLink, false))
                IO::SetClipboard(currentLink);
            HoverTooltip("copy to clipboard");
        } else
            UI::Text("\\$D22You're not in a server!");

        UI::Text("\nMy friend's server link:");
        friendLink = UI::InputText("##friendLink", friendLink, false);
        UI::BeginDisabled(friendLink == "");
            if (UI::Button(Icons::ArrowRight + " Join new server")) {
                Meta::SaveSettings();
                string jl = friendLink.Replace("#join", "#qjoin").Replace("#spectate", "#qspectate");
                cast<CTrackMania@>(GetApp()).ManiaPlanetScriptAPI.OpenLink(jl, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
            }
            UI::SameLine();
            if (UI::Button(Icons::Times + " Clear")) {
                Meta::SaveSettings();
                friendLink = "";
            }
        UI::EndDisabled();
    UI::End();
}

string GetServerLink() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    if (Network is null)
        return "";

    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);
    if (ServerInfo is null)
        return "";

    return ServerInfo.JoinLink;
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}