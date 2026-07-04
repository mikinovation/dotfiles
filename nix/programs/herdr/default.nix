{ ... }:

{
  xdg.configFile."herdr/config.toml".text = ''
    [keys]
    prefix = "ctrl+b"

    # Monitoring: zoom the focused agent to fullscreen, or jump via the goto
    # picker. The sidebar (toggle_sidebar) is a secondary at-a-glance view.
    zoom = "prefix+z"
    toggle_sidebar = "prefix+b"

    # tmux-like split/navigation muscle memory
    split_vertical = "prefix+|"
    split_horizontal = "prefix+minus"
    focus_pane_left = "prefix+h"
    focus_pane_down = "prefix+j"
    focus_pane_up = "prefix+k"
    focus_pane_right = "prefix+l"
    new_tab = "prefix+c"

    [ui]
    mouse_capture = true
    agent_panel_sort = "priority"
    sidebar_width = 32
    sidebar_collapsed_mode = "hidden"

    [advanced]
    scrollback_limit_bytes = 10485760
  '';
}
