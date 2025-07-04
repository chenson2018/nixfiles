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
						nnoremap <leader>hh :lua vim.diagnostic.open_float()<cr>
						nnoremap <leader>tt :lua vim.lsp.buf.hover()<cr>
            nnoremap <leader>\ :lua require'lean.abbreviations'.show_reverse_lookup()<cr>
      			set so=999
      			set mouse=
            set number relativenumber
            set tabstop=2
            set shiftwidth=2
            set expandtab
            set listchars=tab:>-
            au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
            au BufReadPost,BufNewFile *.md,*.txt,*.tex setlocal tw=80 spell
      		'';

    plugins = with pkgs.vimPlugins; [
      unicode-vim
			vimtex
			{
				plugin = lean-nvim;
				type = "lua";
				config = ''
					require('lean').setup{
  					lsp = { on_attach = on_attach },
  					mappings = true,
            goal_markers = {
              unsolved = " ",
              accomplished = '🎉',
            },
					}
					-- from https://github.com/Julian/lean.nvim/issues/43#issuecomment-1850633100
					local group = vim.api.nvim_create_augroup('LeanAutoOpenClose', {})
					
					vim.api.nvim_create_autocmd('BufWinEnter', {
					  group = group,
					  pattern = {'*.lean'},
					  callback = function ()
					    require('lean.infoview').open()
					  end
					})
					
					vim.api.nvim_create_autocmd({'BufWinLeave', 'QuitPre'}, {
					  group = group,
					  pattern = {'*.lean'},
					  callback = function ()
					    local infoview = require('lean.infoview').get_current_infoview()
					    if infoview then
					      local tab_wins = vim.api.nvim_tabpage_list_wins(0)
					      local lean_wins = vim.tbl_filter(function (w)
					        local buf = vim.api.nvim_win_get_buf(w)
					        local buf_ft = vim.api.nvim_buf_get_option(buf, 'filetype')
					        return buf_ft == 'lean'
					      end, tab_wins)
					      if #lean_wins <= 1 then
					        infoview:close()
					      end
					    end
					  end
					})
				'';
			}
			Coqtail
      {
        plugin = rose-pine;
        type = "lua";
        config =
          "	vim.cmd.colorscheme(\"rose-pine\")\n	vim.api.nvim_set_hl(0, \"Normal\", { bg = \"none\" })\n	vim.api.nvim_set_hl(0, \"NormalFloat\", { bg = \"none\" })\n";
      }
      promise-async
      nvim-treesitter
      {
        plugin = nvim-ufo;
        type = "lua";
        config = ''
           vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
           vim.o.foldlevelstart = 99
           vim.o.foldenable = true
           
           -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
           vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
           vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)


          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true
          }
          local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
          for _, ls in ipairs(language_servers) do
              require('lspconfig')[ls].setup({
                  capabilities = capabilities
                  -- you can add other fields for setting up lsp server in this table
              })
          end
          require('ufo').setup()
           				'';
      }
      nvim-lspconfig
      luasnip
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
                    local cmp = require('cmp')
                    local cmp_select_opts = {behavior = cmp.SelectBehavior.Select}
                    
                    cmp.setup({
                      sources = {
                        {name = 'nvim_lsp'},
                      },
                      mapping = {
                        ['<C-y>'] = cmp.mapping.confirm({select = true}),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-d>'] = cmp.mapping.scroll_docs(4),
                        ['<Up>'] = cmp.mapping.select_prev_item(cmp_select_opts),
                        ['<Down>'] = cmp.mapping.select_next_item(cmp_select_opts),
                        ['<C-p>'] = cmp.mapping(function()
                          if cmp.visible() then
                            cmp.select_prev_item(cmp_select_opts)
                          else
                            cmp.complete()
                          end
                        end),
                        ['<C-n>'] = cmp.mapping(function()
                          if cmp.visible() then
                            cmp.select_next_item(cmp_select_opts)
                          else
                            cmp.complete()
                          end
                        end),
                      },
                      snippet = {
                        expand = function(args)
                          require('luasnip').lsp_expand(args.body)
                        end,
                      },
                      window = {
                        documentation = {
                          max_height = 15,
                          max_width = 60,
                        }
                      },
                      formatting = {
                        fields = {'abbr', 'menu', 'kind'},
                        format = function(entry, item)
                          local short_name = {
                            nvim_lsp = 'LSP',
                            nvim_lua = 'nvim'
                          }
                    
                          local menu_name = short_name[entry.source.name] or entry.source.name
                    
                          item.menu = string.format('[%s]', menu_name)
                          return item
                        end,
                      },
                    })
          				'';
      }
			{
				plugin = haskell-tools-nvim;
				type = "lua";
				config = ''
					-- ~/.config/nvim/after/ftplugin/haskell.lua
					local ht = require('haskell-tools')
					local bufnr = vim.api.nvim_get_current_buf()
					local opts = { noremap = true, silent = true, buffer = bufnr, }
					-- haskell-language-server relies heavily on codeLenses,
					-- so auto-refresh (see advanced configuration) is enabled by default
					vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, opts)
					-- Hoogle search for the type signature of the definition under the cursor
					vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
					-- Evaluate all code snippets
					vim.keymap.set('n', '<leader>ea', ht.lsp.buf_eval_all, opts)
					-- Toggle a GHCi repl for the current package
					vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
					-- Toggle a GHCi repl for the current buffer
					vim.keymap.set('n', '<leader>rf', function()
					  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
					end, opts)
					vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
				'';
			}
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = ''
                    local rt = require("rust-tools")
                    
                    rt.setup({
                      server = {
                        on_attach = function(_, bufnr)
                          -- Hover actions
                          vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
                          -- Code action groups
                          vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
                        end,
                      },
                    })
          				'';
      }
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
    userName = "Chris Henson";
    userEmail = "chrishenson.net@gmail.com";
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
			oa = "eval $(opam env)";
      llvm_vm_start = "vboxmanage startvm \"CompilerDesignClass\" --type headless";
      llvm_vm_stop = "vboxmanage controlvm \"CompilerDesignClass\" poweroff --type headless";
      llvm_vm_ssh = "ssh -p 2222 llvm@127.0.0.1";
      hs = "source /home/chenson/.ghcup/env";
      leanpath = "export PATH=\"/home/chenson/.elan/bin:$PATH\"";
      us = "rsync -r --delete /home/chenson/git/website-hakyll/_site/ chris@chrishenson.net:/var/www/chrishenson.net/_site/";
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

		# for Coq packages that don't work with Nix
		pkgs.opam

		# Lean
		pkgs.elan
    # pkgs.cadical
    pkgs.libllvm

    # for lean.nvim unit testing
    pkgs.just

    # Sage
    # pkgs.sage

    # Typst tools
    pkgs.typst
    pkgs.typst-fmt
    # pkgs.typst-lsp

    # Nix tools
    pkgs.nixfmt

		# Haskell
		# pkgs.haskellPackages.haskell-language-server
		# pkgs.haskellPackages.stack
    # pkgs.haskellPackages.cabal-install
    # pkgs.haskellPackages.ghc
    pkgs.haskellPackages.ormolu

    # Terminal presentations
    pkgs.presenterm

    # Rust tools
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.clippy

    # General command line tools
    pkgs.ripgrep

		# LaTex
    pkgs.ott
		pkgs.texlive.combined.scheme-full
    pkgs.texlivePackages.tikz-cd

    # for building TikZ diagrams in Hakyll
    pkgs.rubber
    pkgs.poppler_utils 

    # syntax highlighting for website
    pkgs.python312Packages.pygments

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
