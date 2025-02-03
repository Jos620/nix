{ config, users, pkgs, lib, ... }:

let
  mkDotfileSymlink = name: {
    ".config/${name}".source = config.lib.file.mkOutOfStoreSymlink "/Users/mateusito/dotfiles/${name}";
  };

  dotfiles = [
    "nvim"
  ];
in {
  imports = [ ./modules/default.nix ];
  home.username = "mateusito";
  home.homeDirectory = "/Users/mateusito";
  home.stateVersion = "24.11";

  home.file = lib.mkMerge [
    (lib.mkMerge (map mkDotfileSymlink dotfiles))
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.gpg.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.home-manager.enable = true;
}
