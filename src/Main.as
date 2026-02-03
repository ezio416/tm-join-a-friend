bool permissionsAreOkay = false;
string title = "\\$3AD" + Icons::Kenney::UsersAlt + "\\$G Join a Friend";

[Setting hidden]
string friendLink = "";

void Main() {
    PermissionsOkay();
}

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
        UI::BeginDisabled(friendLink == "" || !permissionsAreOkay);
            if (UI::Button(Icons::ArrowRight + " Join new server")) {
                Meta::SaveSettings();
                string jl = friendLink.Replace("#join", "#qjoin").Replace("#spectate", "#qspectate");
                cast<CTrackMania@>(GetApp()).ManiaPlanetScriptAPI.OpenLink(jl, CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser);
            }
        UI::EndDisabled();

        UI::BeginDisabled(friendLink == "");
            UI::SameLine();
            if (UI::Button(Icons::Times + " Clear")) {
                Meta::SaveSettings();
                friendLink = "";
            }
        UI::EndDisabled();
    UI::End();
}

// from RejoinLastServer plugin - https://github.com/XertroV/tm-rejoin-last-server
void PermissionsOkay() {
    bool allowed = Permissions::PlayPublicClubRoom();
    if (!allowed) {
        NotifyPermissionsError("Permissions::PlayPublicClubRoom (club access required)");
        while (true)
            yield();
    }

    permissionsAreOkay = allowed;
}

// from RejoinLastServer plugin - https://github.com/XertroV/tm-rejoin-last-server
void NotifyPermissionsError(const string &in issues) {
    warn("Lacked permissions: " + issues);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Permissions Error", "Lacking permission(s): " + issues, vec4(.9, .6, .1, .5), 15000);
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