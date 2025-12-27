vim.api.nvim_create_user_command('Q', function()
    vim.cmd('Ex ~')
end, {})

vim.api.nvim_create_user_command('Wq', function()
    vim.cmd('w')
    vim.cmd('Ex ~')
end, {})

vim.api.nvim_create_user_command('Wqa', function()
    vim.cmd('wa')
    vim.cmd('bufdo bwipeout')
    vim.cmd('Ex ~')
end, {})

vim.api.nvim_create_user_command('W', function()
    vim.cmd('w')
end, {})

vim.cmd('cnoreabbrev <expr> q   getcmdtype() == ":" && getcmdline() == "q"   ? "Q"   : "q"')
vim.cmd('cnoreabbrev <expr> wq  getcmdtype() == ":" && getcmdline() == "wq"  ? "Wq"  : "wq"')
vim.cmd('cnoreabbrev <expr> wqa getcmdtype() == ":" && getcmdline() == "wqa" ? "Wqa" : "wqa"')
vim.cmd('cnoreabbrev <expr> w   getcmdtype() == ":" && getcmdline() == "w"   ? "W"   : "w"')

vim.opt.number = true
vim.g.netrw_keepdir = 0
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.api.nvim_set_keymap('n', ',', '<C-w>', { noremap = true })
vim.keymap.set({'n', 'v', 'i'}, '<PageUp>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<PageDown>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<S-Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<S-Down>', '<Nop>')
vim.api.nvim_create_user_command('L', 'terminal', {})
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
vim.api.nvim_create_augroup("TermToEx", { clear = true })
vim.api.nvim_create_autocmd("TermClose", {
    group = "TermToEx",
    callback = function()
        local f = io.open(os.getenv("HOME") .. "/.nvim_term_cwd", "r")
        if f then
            local cwd = f:read("*l")
            f:close()
            vim.cmd("Ex " .. vim.fn.fnameescape(cwd))
        end
    end,
})
vim.api.nvim_create_user_command('Lv', 'vsp | wincmd l | terminal', {})
vim.api.nvim_create_user_command('Ls', 'sp | wincmd j | terminal', {})
vim.opt.termguicolors = true
vim.keymap.set('t', '<C-e>', [[<C-\><C-n>:vsplit | Ex<CR>]])
vim.cmd [[
  highlight Normal guibg=#1e1e1e guifg=#cdd6f4
  highlight NormalNC ctermbg=NONE
  highlight SignColumn ctermbg=NONE
  highlight LineNr ctermbg=NONE
  highlight EndOfBuffer ctermbg=NONE
]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

{
  "stevearc/overseer.nvim",
  config = true
}
,


  { "numToStr/Comment.nvim" },
  { "windwp/nvim-autopairs" },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
{
  "mg979/vim-visual-multi",
  branch = "master",
},
{ "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
{
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.black,
      },
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
})
vim.cmd("colorscheme gruvbox")
vim.cmd [[
  highlight Normal guibg=#1d2021
  highlight NormalNC guibg=#1d2021
]]

require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "python" },
  highlight = { enable = true },
})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }),
})

vim.cmd [[
  highlight Pmenu ctermbg=NONE ctermfg=NONE
  highlight PmenuSel ctermbg=NONE ctermfg=NONE
  highlight PmenuThumb ctermbg=NONE
  highlight FloatBorder ctermbg=NONE ctermfg=NONE
  highlight NormalFloat ctermbg=NONE ctermfg=NONE
]]
  
require("nvim-autopairs").setup({
  check_ts = true,
  enable_check_bracket_line = false,
  map_cr = true,
  enable_moveright = true,
  disable_filetype = { "TelescopePrompt" },
})

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

require("mason-lspconfig").setup({
  ensure_installed = { "clangd"},
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config["clangd"] = {
  cmd = { "clangd" , "--tweaks=-std=c++23" },
  capabilities = capabilities,
  on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
}

vim.lsp.enable("clangd")
vim.lsp.config["pyright"] = {
  on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
}
vim.lsp.enable("pyright")
require("Comment").setup()
vim.diagnostic.config({
  float = { border = "single" },
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.schedule(function()
            vim.cmd("normal! gg")
        end)
    end,
})
