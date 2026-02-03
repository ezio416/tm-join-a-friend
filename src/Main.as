bool permissionsAreOkay = false;
string title = "\\$3AD" + Icons::Kenney::UsersAlt + "\\$G Join a Friend";

[Setting hidden]
string friendLink;

void Main() {
    PermissionsOkay();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void Render() {
    if (false
        or !S_Enabled
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    string currentLink = GetServerLink();

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize)) {
        UI::Text("My server link:");
        if (currentLink.Length > 0) {
            if (UI::Selectable(currentLink, false)) {
                IO::SetClipboard(currentLink);
            }
            HoverTooltip("copy to clipboard");
        } else {
            UI::Text("\\$D22You're not in a server!");
        }

        UI::Text("\nMy friend's server link:");
        friendLink = UI::InputText("##friendLink", friendLink);
        UI::BeginDisabled(false
            or friendLink.Length == 0
            or !permissionsAreOkay
        );
        if (UI::Button(Icons::ArrowRight + " Join new server")) {
            Meta::SaveSettings();
            cast<CTrackMania>(GetApp()).ManiaPlanetScriptAPI.OpenLink(
                friendLink.Replace("#join", "#qjoin").Replace("#spectate", "#qspectate"),
                CGameManiaPlanetScriptAPI::ELinkType::ManialinkBrowser
            );
        }
        UI::EndDisabled();

        UI::BeginDisabled(friendLink.Length == 0);
        UI::SameLine();
        if (UI::Button(Icons::Times + " Clear")) {
            Meta::SaveSettings();
            friendLink = "";
        }
        UI::EndDisabled();
    }

    UI::End();
}

// from RejoinLastServer plugin - https://github.com/XertroV/tm-rejoin-last-server
void PermissionsOkay() {
    bool allowed = Permissions::PlayPublicClubRoom();
    if (!allowed) {
        NotifyPermissionsError("Permissions::PlayPublicClubRoom (club access required)");
        while (true) {
            yield();
        }
    }

    permissionsAreOkay = allowed;
}

// from RejoinLastServer plugin - https://github.com/XertroV/tm-rejoin-last-server
void NotifyPermissionsError(const string&in issues) {
    warn("Lacking permissions: " + issues);
    UI::ShowNotification(
        Meta::ExecutingPlugin().Name + ": Permissions Error",
        "Lacking permission(s): " + issues,
        vec4(0.9f, 0.6f, 0.1f, 0.5f),
        15000
    );
}

string GetServerLink() {
    auto App = cast<CTrackMania>(GetApp());

    auto Network = cast<CTrackManiaNetwork>(App.Network);
    if (Network is null) {
        return "";
    }

    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
    if (ServerInfo is null) {
        return "";
    }

    return ServerInfo.JoinLink;
}

void HoverTooltip(const string&in msg) {
    if (!UI::IsItemHovered()) {
        return;
    }

    UI::BeginTooltip();
    UI::Text(msg);
    UI::EndTooltip();
}
