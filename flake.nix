{
  description = "Jos620 Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # Utils
          pkgs.mkalias
          pkgs.lua
          pkgs.luajit
          pkgs.ninja
          pkgs.cmake
          pkgs.git
          pkgs.postgresql
          pkgs.python3

          # GUI
          pkgs.alacritty
          pkgs.obsidian
          # pkgs.ghostty

          # CLI
          pkgs.neovim
          pkgs.fish
          pkgs.tmux
          pkgs.openssl
          pkgs.btop
          pkgs.curl
          pkgs.eza
          pkgs.ffmpeg
          pkgs.fzf
          pkgs.gh
          pkgs.httpie
          pkgs.hyperfine
          pkgs.lazygit
          pkgs.ripgrep
          pkgs.sqlite
          pkgs.supabase-cli
          pkgs.zoxide
          pkgs.gum
        ];

      homebrew = {
        enable = true;
        brews = [
          "rust"
          "asdf"
          "sesh"
        ];
        casks = [
          "ghostty"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in

      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      system.defaults = {
        finder.FXPreferredViewStyle = "clmv";
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      programs.zsh.enable = true;
      programs.fish.enable = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      users.users.mateusito.shell = pkgs.fish;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration 
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "mateusito";
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
