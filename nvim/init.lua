-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.mouse = "a"
vim.opt.termguicolors = true

vim.api.nvim_set_keymap('n', ',', '<C-w>', { noremap = true })
vim.keymap.set({'n','v','i'}, '<PageUp>', '<Nop>')
vim.keymap.set({'n','v','i'}, '<PageDown>', '<Nop>')

-- Highlight tweaks
vim.cmd [[
  highlight Normal guibg=#1e1e1e guifg=#cdd6f4
  highlight NormalNC ctermbg=NONE
  highlight SignColumn ctermbg=NONE
  highlight LineNr ctermbg=NONE
  highlight EndOfBuffer ctermbg=NONE
  highlight Pmenu ctermbg=NONE ctermfg=NONE
  highlight PmenuSel ctermbg=NONE ctermfg=NONE
  highlight PmenuThumb ctermbg=NONE
  highlight FloatBorder ctermbg=NONE ctermfg=NONE
  highlight NormalFloat ctermbg=NONE ctermfg=NONE
]]

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data").."/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable",lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "numToStr/Comment.nvim", config = true },
  { "windwp/nvim-autopairs", config = true },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
      vim.cmd [[
        highlight Normal guibg=#1d2021
        highlight NormalNC guibg=#1d2021
      ]]
    end
  },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function() vim.cmd("TSUpdateSync") end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp" },
        highlight = { enable = true },
        incremental_selection = { enable = false },
        indent = { enable = false },
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > 500
        end
      })
    end
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = { null_ls.builtins.formatting.clang_format },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = true })
              end
            })
          end
        end,
      })
    end
  },
})

-- Comment & autopairs
require("Comment").setup()
require("nvim-autopairs").setup({
  check_ts = true,
  enable_check_bracket_line = false,
  map_cr = true,
  enable_moveright = true,
  disable_filetype = { "TelescopePrompt" }
})

-- CMP setup (manual trigger only)
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  completion = { autocomplete = false },
  sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }),
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Mason & LSP setup
require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "clangd" } })

local lspconfig = require("lspconfig")
lspconfig.clangd.setup({
  filetypes = { "c", "cpp", "objc", "objcpp" },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  init_options = { semanticHighlighting = false },
})

-- Diagnostics
vim.diagnostic.config({
  float = { border = "single" },
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
