{ config, pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if status is-interactive
          # Commands to run in interactive sessions can go here
      end

      set fish_greeting

      # Zoxide
      eval "$(zoxide init fish)"

      # Load secret environment keys
      load_secret_variables &

      # Remove ctrl+h binding
      bind \ch kill-backward-char

      source /usr/local/opt/asdf/libexec/asdf.fish
    '';

    shellInit = ''
      # Environment variables
      set -gx PATH $HOME/.local/bin $PATH
      set -gx PATH $HOME/go/bin $PATH
      set -gx PATH $HOME/Tools/flutter/bin $PATH
      set -gx PATH $HOME/.orbstack/bin $PATH
      set -gx PATH /run/current-system/sw/bin $PATH
      set -gx PATH $HOME/.bun/bin $PATH
      set -gx PATH $HOME/.volta/bin $PATH

      set -gx LC_ALL "en_US.UTF-8"
      set -gx LANG "en_US.UTF-8"
      set -gx XDG_CONFIG_HOME "$HOME/.config"
      set -gx CPPFLAGS "-I/usr/local/opt/openjdk/include"
      set -gx EDITOR "$(which nvim)"
      set -gx GIGET_AUTH "pass show github/personal"
      set -gx LAUNCH_EDITOR "vim"
      set -gx HOMEBREW_NO_AUTO_UPDATE "1"
      set -gx BUN_INSTALL "$HOME/.bun"
      set -gx VOLTA_HOME "$HOME/.volta"

      # Theme settings
      set -g theme_display_group no
      set -g theme_display_user no
      set -g theme_display_hostname no
      set -g theme_display_jobs no
      set -g theme_display_jobs_always yes
      set -g theme_display_rw no

      # Theme colors
      set -g theme_color_error red
      set -g theme_color_superuser red
      set -g theme_color_user green
      set -g theme_color_host brgreen
      set -g theme_color_separator brblack
      set -g theme_color_bracket brblue
      set -g theme_color_normal normal
      set -g theme_color_path brwhite
      set -g theme_color_prompt white
      set -g theme_color_virtualenv bryellow
      set -g theme_color_status_prefix brblue
      set -g theme_color_status_jobs brgreen
      set -g theme_color_status_rw brwhite
      set -g theme_color_batt_icon white
      set -g theme_color_batt_charging brgreen
      set -g theme_color_batt_discharging red
      set -g theme_color_batt_0 red
      set -g theme_color_batt_25 red
      set -g theme_color_batt_50 bryellow
      set -g theme_color_batt_75 bryellow
      set -g theme_color_batt_100 brgreen

      # Git prompt settings
      set -g __fish_git_prompt_color_merging red
      set -g __fish_git_prompt_color_branch brblue
      set -g __fish_git_prompt_showcolorhints yes
      set -g __fish_git_prompt_show_informative_status yes
      set -g __fish_git_prompt_char_stateseparator ' '
      set -g __fish_git_prompt_char_branch_begin ' '
      set -g __fish_git_prompt_char_branch_end ' '
      set -g __fish_git_prompt_color_branch_begin bryellow
      set -g __fish_git_prompt_color_branch_end bryellow
    '';

    shellAliases = {
      # General
      reload = "source ~/.config/fish/config.fish";
      docs = "tldr --list | fzf --preview 'tldr {1} --color=always' --preview-window=right,70% | xargs tldr";
      ls = "eza --long --git --color=always --icons=always --sort=type --no-filesize --no-time --no-user --no-permissions";
      la = "ls -a";
      c = "clear";
      cl = "clear";
      cle = "clear";
      clea = "clear";
      clera = "clear";
      celar = "clear";
      cealr = "clear";
      claer = "clear";

      # NeoVIM
      vim = "nvim";
      vnim = "nvim";
      nvimo = "NVIM_APPNAME=nvim-personal nvim";
      nv = "nvimo";
      "nvim." = "nvim .";

      # Git
      g = "git";
      gs = "git st";
      gcz = "git cz";
      gac = "ga . && gc";
      gacz = "ga . && g cz";
      lg = "lazygit";

      # TMUX
      tn = "tnew";
      tk = "tmux kill-server";
      kt = "tmux kill-server";
      k = "tmux kill-pane";
    };

    functions = {
      load_secret_variables = ''
        if type -q pass
          set -gx OPENAI_API_KEY (pass show openai/api/neovim | head -n 1 2>/dev/null)
        end
      '';

      ta = ''
        tmux attach -t 0 2> /dev/null

        if test $status -ne 0
          tmux
        end
      '';

      git_branch = ''
        test -z "$(git rev-parse --is-inside-work-tree 2> /dev/null)"

        if git branch --list 2> /dev/null | grep -iq "\*"
          echo (string split ' ' (git branch --list 2> /dev/null | grep "\*") | tail -1)
        end
      '';

      fish_prompt = ''
        set -l branch (git_branch)

        set primary_color             "blue"
        set bg_color                  "#131313"
        set branch_color              "#262626"

        set fish_color_command        "green"
        set fish_color_error         "yellow"
        set fish_color_param         "blue"
        set fish_color_autosuggestion "#565453"
        set fish_color_comment       "#565453"
        set fish_color_valid_path    "blue"

        if test -n "$branch"
          string join ' ' -- (set_color $bg_color --background $primary_color) $(prompt_pwd) (set_color $primary_color --background $branch_color) "$(git_branch) "(set_color normal --background $bg_color) \n(set_color $primary_color --background $bg_color)' » '(set_color normal)' '
        else
          string join ' ' -- (set_color $bg_color --background $primary_color) $(prompt_pwd) (set_color normal --background $bg_color) \n(set_color $primary_color --background $bg_color)' » '(set_color normal)' '
        end
      '';

      s = ''
        ~/Tools/bin/sesh
      '';
    };
  };
}
