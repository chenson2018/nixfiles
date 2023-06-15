{ config, pkgs, ... }:

{
  home.username = "chenson";
  home.homeDirectory = "/home/chenson";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      			set so=999
      			set mouse=
            set number relativenumber
            set tabstop=2
            set shiftwidth=2
            au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      		'';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
                    local builtin = require('telescope.builtin')
                    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
                    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
                    vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
                    vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
          				'';
      }
      {
        plugin = undotree;
        config = ''
          nnoremap <F5> :UndotreeToggle<CR>
        '';
      }
    ];
  };

  programs.git = {
    enable = true;
    aliases = { st = "status"; };
    extraConfig = { pull.ff = "only"; };
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    # This does work to set variables, but because of __HM_SESS_VARS_SOURCED in 
    # ~/.nix-profile/etc/profile.d/hm-session-vars.sh will require a reboot
    # TODO find a better way!
    #
    # sessionVariables = {
    # 	HELLO = "world";
    # };
    historySize = 1000;
    historyFileSize = 2000;
    shellOptions = [ "histappend" "globstar" "checkwinsize" ];
    shellAliases = {
      sw = "home-manager switch";
      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "la -A";
      l = "ls -CF";
    };
    bashrcExtra = ''
            # make less more friendly for non-text input files, see lesspipe(1)
            [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
            
            # set variable identifying the chroot you work in (used in the prompt below)
            if [ -z "''${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
                debian_chroot=$(cat /etc/debian_chroot)
            fi
            
            # If this is an xterm set the title to user@host:dir
            case "$TERM" in
            xterm*|rxvt*)
      					PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
                PS1="\[\e]0;''${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
                ;;
            *)
                ;;
            esac      
      		'';
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Nix tools
    pkgs.nixfmt

    # Rust tools
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.clippy

    # General command line tools
    pkgs.ripgrep

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # see https://github.com/nix-community/home-manager/issues/432
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
