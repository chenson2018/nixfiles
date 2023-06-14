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

	  viAlias = true;
 		vimAlias = true;

		extraConfig = ''
			set mouse=
      set number relativenumber
      set tabstop=2
      set shiftwidth=2
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
		'';

		# TODO fix issues with telescope

		plugins = with pkgs.vimPlugins; [ 
			telescope-nvim 
		];
  };

	programs.git = {
		enable = true;
    aliases = {
      st = "status";
    };
    extraConfig = {
      pull.ff = "only";
    };
	};

	programs.bash = {
		enable = true;
		historyControl = [ 
			"ignoredups" 
			"ignorespace" 
		];
		historySize = 1000;
		historyFileSize = 2000;
		shellOptions = [ 
			"histappend" 
			"globstar" 
			"checkwinsize"
		];
		shellAliases = {
			sw = "home-manager switch";
			eh = "vim /home/chenson/git/nixfiles/home.nix";
			ls = "ls --color=auto";
			ll = "ls -alF";
			la = "la -A";
			l  = "ls -CF";
		};
		#bashrcExtra = builtins.readFile /home/chenson/git/nixfiles/.bashrc;
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
	  pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.clippy

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

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/chenson/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
