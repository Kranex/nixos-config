# Install and configure neovim + plugins.
{pkgs, lib, ...}:
let
  # Plugins that have configurations attached.
  configuredPlugins = import ./configuredPlugins.nix {inherit pkgs;};

  # Language support configurations and plugins.
  languages = import ./languages.nix {inherit pkgs; inherit lib;};

  # The configured plugins I actually want to use.
  plugins = with configuredPlugins; with languages; [
    colorscheme

    # file browsing
    telescope # fzf
    nerdtree

    # completion
    # YouCompleteMe

    # linting
    treesitter

    # languages
    lspconfig
  ] ++ lib.mapAttrsToList (name: value: value) languages; # currently I just want all the languages...

  # Extra plugins that either don't need configuration or I haven't configured yet.
  unconfiguredPlugins = with pkgs.vimPlugins; [
    # Language Support
    vim-pandoc
    vim-pandoc-syntax
    plantuml-syntax
    i3config-vim

    # QOL
    vim-gitgutter
    vim-repeat
    auto-pairs
    vim-surround
    #vim-table-mode

    # IDE
    # ale
  ];

in {
  # Add in all the dependencies that some languages have (also some plugins have
  # "optional?" dependencies that nix won't add).
  # TODO: I want to use a wrapper for this so they don't all endup on my path.
  environment.systemPackages = builtins.concatLists (builtins.catAttrs "requires" plugins);

  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;

    defaultEditor = true;
    # viAlias = true; # vi is actually useful when neovim breaks.
    vimAlias = true;

    # Merge all the runtime attrsets from all the selected configuredPlugins.
    runtime = lib.fold (x: y: lib.mergeAttrs x y ) {} (builtins.catAttrs "runtime" plugins);

    configure = {
      packages.myPlugins = {
        # Merge the selected configured plugins, any extras from them and the
        # unconfigured plugins.
        start =
          builtins.catAttrs "plugin" plugins ++
          builtins.concatLists (builtins.catAttrs "extras" plugins) ++
          unconfiguredPlugins;

        opt = [];
      };

      # Merge the configs from all the configured plugins and the main neovim
      # config.
      customRC =
        (builtins.concatStringsSep "\n" (builtins.catAttrs "config" plugins)) +
        builtins.readFile ./config.vim;
    };
  };
}
