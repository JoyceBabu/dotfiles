local wezterm = require 'wezterm'
local mux = wezterm.mux;

local function font_with_sym_fallback(font_family, options)
    -- family names, not file names
    return wezterm.font_with_fallback({
        font_family,
        -- "Hack",
        -- "Cascadia Code",
        -- "JetBrains Mono",
        -- "Hack Nerd Font",
        "MesloLGS NF",
        "PowerlineSymbols",
        "Noto Color Emoji", -- for emoji support, weather icons, etc...
    }, options)
end
--
local env = {}
local launch_menu = {}
-- local default_prog = { "/bin/bash", "-l" }

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    default_prog = {"powershell.exe", "-NoLogo"}
else
    table.insert(launch_menu, { label = "Bash", args = {"bash", "-l"} })
    table.insert(launch_menu, { label = "Zsh", args = {"zsh", "-l"} })
    table.insert(launch_menu, { label = "Fish", args = {"fish", "-l"} })
end

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():toggle_fullscreen()
end)

return {
    color_scheme = 'OneDark (Gogh)',
    -- default_prog = {"/usr/bin/zsh", "-l"},
    font = font_with_sym_fallback("JetBrains Mono",{foreground="#b0b0b0"}),
    font_size = 16.0,
    -- dpi = 96.0,
    enable_scroll_bar = true,
    scrollback_lines = 100000,

    -- set_environment_variables = {
    -- TERM = "xterm-256color-italic",
    -- },
    -- default_cursor_style = "SteadyUnderline",
    launch_menu = launch_menu,
    default_cursor_style = "BlinkingBar",
    -- font_dirs = {"/usr/share/fonts/iosevka-term"},
    -- font_rules = {
    --     {
    --         italic = true,
    --         font = wezterm.font_with_fallback({"Iosevka Term SS09 Light Italic"},{foreground="#b0b0b0"}),
    --     },
    --     {
    --         intensity = "Bold",
    --         font = wezterm.font_with_fallback({"Iosevka Term SS09 Medium"}, {foreground="#ffffff"}),
    --     },
    --     {
    --         italic = true,
    --         intensity = "Bold",
    --         font = wezterm.font_with_fallback({"Iosevka Term SS09 Medium Italic"}, {foreground="#ffffff"}),
    --     },
    --     {
    --         intensity = "Half",
    --         font = wezterm.font_with_fallback({"Iosevka Term SS09 Extralight"}, {foreground="#c0c0c0"}),
    --     },
    --     {
    --         italic = true,
    --         intensity = "Half",
    --         font = wezterm.font_with_fallback({"Iosevka Term SS09 Extralight Italic"}, {foreground="#c0c0c0"}),
    --     },
    -- },
    font_shaper = "Harfbuzz",
    --font_shaper = "Allsorts",
    --font_antialias = "Subpixel",
    harfbuzz_features = {"kern", "liga", "clig", "calt"},
    freetype_load_target = "HorizontalLcd",
    -- font_antialias = "Greyscale",
    --font_antialias = "None",
    --font_hinting = "Full",
    -- font_hinting = "Vertical",
    --font_hinting = "VerticalSubpixel",
    --font_hinting = "None",
    keys = {
        -- -- Create a new tab in the same domain as the current tab
        -- {key="t", mods="CTRL", action=wezterm.action{SpawnTab="CurrentTabDomain"}},
        -- -- Create a new tab in the default domain
        -- {key="t", mods="ALT", action=wezterm.action{SpawnTab="DefaultDomain"}},
        -- -- move tabs
        -- {key="LeftArrow", mods="CTRL", action=wezterm.action{MoveTabRelative=-1}},
        -- {key="RightArrow", mods="CTRL", action=wezterm.action{MoveTabRelative=1}},
        -- -- move focus between tabs
        --     {key="LeftArrow", mods="ALT", action=wezterm.action{ActivateTabRelative=-1}},
        -- {key="RightArrow", mods="ALT", action=wezterm.action{ActivateTabRelative=1}},
        {key="1", mods="ALT", action=wezterm.action{ActivateTab=0}},
        -- {key="2", mods="ALT", action=wezterm.action{ActivateTab=1}},
        -- {key="3", mods="ALT", action=wezterm.action{ActivateTab=2}},
        -- {key="4", mods="ALT", action=wezterm.action{ActivateTab=3}},
        -- {key="5", mods="ALT", action=wezterm.action{ActivateTab=4}},
        -- {key="6", mods="ALT", action=wezterm.action{ActivateTab=5}},
        -- {key="7", mods="ALT", action=wezterm.action{ActivateTab=6}},
        -- {key="8", mods="ALT", action=wezterm.action{ActivateTab=7}},
        -- {key="9", mods="ALT", action=wezterm.action{ActivateTab=8}},
        -- {key="0", mods="ALT", action=wezterm.action{ActivateTab=-1}},
        {key="q", mods="CMD", action=wezterm.action{CloseCurrentTab={confirm=true}}},
        {key="s", mods="CMD", action="Nop"},
    },
    colors = {
        tab_bar = {

            -- The color of the strip that goes along the top of the window
            background = "#262626",

            -- The active tab is the one that has focus in the window
            active_tab = {
                -- The color of the background area for the tab
                bg_color = "#404040",
                -- The color of the text for the tab
                fg_color = "#c0c0c0",

                -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
                -- label shown for this tab.
                -- The default is "Normal"
                intensity = "Bold",

                -- Specify whether you want "None", "Single" or "Double" underline for
                -- label shown for this tab.
                -- The default is "None"
                underline = "None",

                -- Specify whether you want the text to be italic (true) or not (false)
                -- for this tab.  The default is false.
                italic = false,

                -- Specify whether you want the text to be rendered with strikethrough (true)
                -- or not for this tab.  The default is false.
                strikethrough = false,
            },

            -- Inactive tabs are the tabs that do not have focus
            inactive_tab = {
                bg_color = "#202020",
                fg_color = "#808080",

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `inactive_tab`.
            },

            -- You can configure some alternate styling when the mouse pointer
            -- moves over inactive tabs
            inactive_tab_hover = {
                bg_color = "#363636",
                fg_color = "#909090",
                italic = false,

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `inactive_tab_hover`.
            }
        }
    },
    color_schemes = {
        ["Dracula"] = {
            foreground = "#f8f8f2",
            background = "#282a36",
            cursor_bg = "#44475a",
            cursor_fg = "#ff79c6",
            -- cursor_border = "#50fa7b",
            selection_bg = "#44475a",
            selection_fg = "#f8f8f2",
            scrollbar_thumb = "#bd93f9",
            ansi = {
                "#000000", -- white
                "#ff5555", -- red
                "#50fa7b", -- reen
                "#f1fa8c", -- yellow
                "#bd93f9", -- purple
                "#ff79c6", -- pink
                "#8be9fd", -- cyan
                "#bbbbbb", -- grey (not in dracula)
            },
            brights = {"#555555","#ff5555","#50fa7b","#f1fa8c","#bd93f9","#ff79c6","#8be9fd","#ffffff"},
        }
    },
    term = "xterm-256color",
    window_decorations = "RESIZE", -- Hide title bar
    hide_tab_bar_if_only_one_tab = true
}

