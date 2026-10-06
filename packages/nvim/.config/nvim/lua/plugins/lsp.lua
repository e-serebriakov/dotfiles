return {
  {
    -- Configure Lua completion, annotations, and signatures for Neovim and its plugins.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason installs servers and tools in Neovim's data directory.
      -- Initialize it before dependent plugins. opts = {} calls setup({}).
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Show language server status.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Add nvim-cmp completion capabilities.
      'hrsh7th/cmp-nvim-lsp',

      -- JSON schema support
      'b0o/SchemaStore.nvim',
    },
    config = function()
      -- Language servers provide navigation, completion, and other language features.
      -- Mason installs the servers configured below, except Biome.
      -- See :help lsp-vs-treesitter.

      -- Configure the buffer when a language server attaches.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Set buffer-local LSP mappings. Normal mode is the default.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition. Press <C-t> to return.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Find the implementation of a declared type or interface.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Find the type definition, not the variable definition.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Search document symbols, such as variables, functions, and types.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Search symbols across the workspace.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the symbol, including other files if the server supports this.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Run a code action at the cursor, such as a suggested correction.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- Find the declaration, not the definition; for example, a C header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Support the Neovim 0.10 method signature and the signature used since 0.11.
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- Highlight references on CursorHold; clear them when the cursor moves.
          -- See :help CursorHold.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Enable the inlay hint shortcut if the server supports hints. Hints can shift displayed code.
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
      }

      -- Tell language servers which completion features nvim-cmp supports.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Configure language servers here.
      -- Overrides: cmd (start command), filetypes, capabilities, and settings.
      -- Lua settings: https://luals.github.io/wiki/settings/
      local servers = {
        clojure_lsp = {},
        ts_ls = {},
        ruff = {},
        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                ignore = { '*' },
              },
            },
          },
        },
        cssls = {},
        html = {},
        emmet_language_server = {},
        tailwindcss = {},
        marksman = {},

        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },

        -- Use project-local Biome from node_modules when available; bypass Mason.
        biome = {
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' }))
          end,
          workspace_required = true,
          cmd = function(dispatchers)
            local file = vim.api.nvim_buf_get_name(0)
            local exe = 'biome'
            for dir in vim.fs.parents(file) do
              local cand = dir .. '/node_modules/.bin/biome'
              if vim.fn.executable(cand) == 1 then
                exe = cand
                break
              end
            end
            return vim.lsp.rpc.start({ exe, 'lsp-proxy' }, dispatchers)
          end,
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      }

      -- Install the configured servers and additional tools below.
      -- Use :Mason to inspect or install tools; press g? for help.
      -- Configure Mason in the dependencies table above.
      local ensure_installed = vim.tbl_filter(function(name)
        return name ~= 'biome'
      end, vim.tbl_keys(servers))
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        -- markdownlint-cli2, vale, prettierd are managed by mise (see packages/mise)
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- mason-tool-installer manages installation.
        automatic_enable = false,
      }

      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
