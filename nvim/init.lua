-- ───────────────────────────────────────────
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.mouse = "a"
vim.api.nvim_set_keymap('n', ',', '<C-w>', { noremap = true, silent = true })
vim.keymap.set({'n','v','i'}, '<PageUp>', '<Nop>')
vim.keymap.set({'n','v','i'}, '<PageDown>', '<Nop>')

vim.opt.termguicolors = true
vim.cmd [[
  highlight Normal guibg=#1e1e1e guifg=#cdd6f4
  highlight NormalNC ctermbg=NONE
  highlight SignColumn ctermbg=NONE
  highlight LineNr ctermbg=NONE
  highlight EndOfBuffer ctermbg=NONE
]]

-- ───────────────────────────────────────────
-- Lazy.nvim bootstrap + plugin list
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "numToStr/Comment.nvim",          config = true },
  { "windwp/nvim-autopairs",         config = true },
  { "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
      vim.cmd [[
        highlight Normal guibg=#1d2021
        highlight NormalNC guibg=#1d2021
      ]]
    end,
  },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdateSync",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        incremental_selection = { enable = false },
        indent = { enable = false },
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = { null_ls.builtins.formatting.clang_format },
        -- no on_attach autocmd; you may manually format if needed
      })
    end,
  },
})

-- ───────────────────────────────────────────
-- Comment & Autopairs
require("Comment").setup()
require("nvim-autopairs").setup({
  check_ts = true,
  enable_check_bracket_line = false,
  map_cr = true,
  enable_moveright = true,
  disable_filetype = { "TelescopePrompt" },
})

-- ───────────────────────────────────────────
-- nvim‑cmp setup (autocomplete manual trigger)
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"]     = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  completion = { autocomplete = false },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }),
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- ───────────────────────────────────────────
-- Configure LSP using new built-in API (Neovim 0.11+)
-- ( avoids deprecated `lspconfig.*.setup` style )
vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed', '--limit-results=200' },
  filetypes = { 'c', 'cpp', 'h', 'hpp' },
  root_markers = { '.git', 'compile_commands.json', 'compile_flags.txt' },
  flags = { debounce_text_changes = 500 },
}
vim.lsp.enable('clangd')

-- When clangd attaches, adjust settings & keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "clangd" then
      -- disable semantic tokens (heavy)
      client.server_capabilities.semanticTokensProvider = nil

      local bufnr = args.buf
      local opts = { buffer = bufnr, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end
  end,
})

-- Diagnostics minimal
vim.diagnostic.config({
  float = { border = "single" },
  virtual_text = false,
  signs = true,
  update_in_insert = false,
})

-- Netrw settings
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

vim.cmd [[
  highlight Pmenu ctermbg=NONE ctermfg=NONE
  highlight PmenuSel ctermbg=NONE ctermfg=NONE
  highlight PmenuThumb ctermbg=NONE
  highlight FloatBorder ctermbg=NONE ctermfg=NONE
  highlight NormalFloat ctermbg=NONE ctermfg=NONE
]]
