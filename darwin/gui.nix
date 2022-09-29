{ config, pkgs, lib, ... }: with lib; {
  services = {
      yabai = {
        enable = true;
        enableScriptingAddition = true;
        config = {
          layout = "bsp";
          auto_balance = "on";
          split_ratio = "0.50";
          window_placement = "second_child";
          window_gap = 18;
          top_padding = 36;
          bottom_padding = 18;
          left_padding = 18;
          right_padding = 18;
          window_shadow = "on";
          window_border = "off";
          window_border_width = 3;
          window_opacity = "on";
          window_opacity_duration = "0.1";
          active_window_opacity = "1.0";
          normal_window_opacity = "1.0";
          mouse_modifier = "cmd";
          mouse_action1 = "move";
          mouse_action2 = "resize";
          mouse_drop_action = "swap";
        };
       extraConfig = ''
        yabai -m rule --add app='Firefox' manage=on
        yabai -m rule --add app='System Preferences' manage=off
        yabai -m rule --add app='Activity Monitor' manage=off
      '';
    };
    spacebar = {
      enable = true;
      package = pkgs.spacebar;
      config = {
        position = "top";
        height = 28;
        title = "off";
        spaces = "on";
        power = "on";
        clock = "on";
        right_shell = "on";
        padding_left = 20;
        padding_right = 20;
        spacing_left = 25;
        spacing_right = 25;
        text_font = ''"Menlo:16.0"'';
        icon_font = ''"Menlo:16.0"'';
        background_color = "0xff161616";
        foreground_color = "0xffFFFFFF";
        space_icon_color = "0xff3ddbd9";
        power_icon_strip = " ";
        space_icon_strip = "一 二 三 四 五 六 七 八 九 十";
        spaces_for_all_displays = "on";
        display_separator = "on";
        display_separator_icon = "|";
        clock_format = ''"%d/%m/%y %R"'';
        right_shell_icon = " ";
        right_shell_command = "whoami";
      };
    };
    skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # open terminal
        cmd - return : wezterm

        # focus window
        lalt - h : yabai -m window --focus west
        lalt - j : yabai -m window --focus south
        lalt - k : yabai -m window --focus north
        lalt - l : yabai -m window --focus east

        # swap managed window
        shift + lalt - h : yabai -m window --swap west
        shift + lalt - l : yabai -m window --swap east
        shift + lalt - j : yabai -m window --swap south
        shift + lalt - k : yabai -m window --swap north

        # focus spaces
        alt - x : yabai -m space --focus recent
        alt - 1 : yabai -m space --focus 1
        alt - 2 : yabai -m space --focus 2
        alt - 3 : yabai -m space --focus 3
        alt - 4 : yabai -m space --focus 4
        alt - 5 : yabai -m space --focus 5
        alt - 6 : yabai -m space --focus 6
        alt - 7 : yabai -m space --focus 7
        alt - 8 : yabai -m space --focus 8

        # focus on next/prev space
        alt + ctrl - q : yabai -m space --focus prev
        alt + ctrl - e : yabai -m space --focus next

        # send window to desktop
        shift + alt - x : yabai -m window --space recent
        shift + alt - 1 : yabai -m window --space 1
        shift + alt - 2 : yabai -m window --space 2
        shift + alt - 3 : yabai -m window --space 3
        shift + alt - 4 : yabai -m window --space 4
        shift + alt - 5 : yabai -m window --space 5
        shift + alt - 6 : yabai -m window --space 6
        shift + alt - 7 : yabai -m window --space 7
        shift + alt - 8 : yabai -m window --space 8

        # float / unfloat window and center on screen
        lalt - t : yabai -m window --toggle float;\
                   yabai -m window --grid 4:4:1:1:2:2

        # toggle window zoom
        lalt - d : yabai -m window --toggle zoom-parent

      '';
    };
  };
}
