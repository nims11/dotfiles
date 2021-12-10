set nocompatible
" load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'ap/vim-buftabline'
Plug 'tpope/vim-commentary'
Plug 'rhysd/vim-clang-format'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

filetype plugin indent on     " auto indent
set number relativenumber     " show line numbers, make them relative
syntax enable                 " enable syntax highlighting
set t_co=256                  " force 256 colors
set wrap                      " enable word wrap
set showmatch mat=5           " blink match parenthesis, blink match time
set cursorline
set ruler
set so=12                     " avoid cursor getting to extreme bottom/top
set tm=400                    " Time waited for special sequences
set noerrorbells novisualbell
set hidden
set lazyredraw
colorscheme zenburn

" ==================== BASIC EDITOR SETTINGS AND MAPPINGS ====================
" set leader key
let g:mapleader = ","

" folding options
set foldlevelstart=10 foldnestmax=10 foldmethod=indent

" filetype settings
set ffs=unix,dos,mac
set wildignore=*.o,*~,*.pyc

" prevents syntax highlighting for long lines (performance)
set synmaxcol=250

" search options
set ignorecase smartcase incsearch
" clear highlighting
nnoremap // :noh<cr>

" disable extra files created by vim
set nobackup nowb noswapfile

" indentation
set expandtab smarttab shiftwidth=4 tabstop=8 softtabstop=4 autoindent smartindent

" navigate through word wrap
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" Set undofile
set undodir=$HOME."/.undodir"
set undofile

" pane bindings
nnoremap <leader>- :split<CR>
nnoremap <leader>\| :vsplit<CR>

" buffer management
nmap <leader>n :enew<cr>
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>
nmap <leader>bq :bp <BAR> bd #<CR>

" remap command key
inoremap jk <esc>

nnoremap ; :

" open at the previous cursor position
function! ResCur()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction
augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END

nnoremap <leader>w :w<CR>
" save write protected file as root
nnoremap <leader>sw :w !sudo tee %<CR>

" Statusline
set statusline=\ %M\ %y\ %r
set statusline+=%=
set statusline+=%f
set statusline+=%=
set statusline+=[L]\ %3l/%L\ \ [C]\ %2c\ 

" Theming
hi Statusline ctermbg=10 ctermfg=0 cterm=reverse
hi StatuslineNC ctermbg=7 ctermfg=0 cterm=reverse
hi CursorLineNr ctermfg=10 ctermbg=8
hi LineNr ctermfg=7 ctermbg=0
hi Normal ctermfg=15 ctermbg=None
hi CursorLine ctermbg=8

" Conceal is turned on only in normal mode

au FileType tex setl textwidth=80
au FileType markdown setl textwidth=80
au FileType tex setl conceallevel=0
let g:polyglot_disabled = ['latex']

" Set spell checks
autocmd FileType tex setlocal spell

" Terminal bindings
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l
tnoremap jk <C-\><C-n>

" ==================== PLUGIN SETTINGS AND MAPPINGS ======================

" comment line
nmap <space> gcc
" comment selection
vmap <space> gc

let g:vim_markdown_folding_disabled=1

" undotree bindings
nnoremap <leader>u :UndotreeToggle<CR>

" telescope bindings
nnoremap <C-o> <cmd>Telescope find_files<cr>
nnoremap <leader><TAB> <cmd>Telescope file_browser<cr>


let g:buftabline_indicators = 1
highlight BufTabLineFill ctermbg=8
highlight BufTabLineHidden ctermbg=8
highlight BufTabLineCurrent ctermbg=None ctermfg=10
highlight BufTabLineActive ctermbg=8 ctermfg=4

" Treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF

" ==================== IDE stuff =======================

set completeopt=menuone,noselect
let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.resolve_timeout = 800
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.nvim_lsp = v:true



lua << EOF
    local nvim_lsp = require('lspconfig')

    -- Use an on_attach function to only map the following keys 
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        --Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end

    -- Use a loop to conveniently call 'setup' on multiple servers and
    -- map buffer local keybindings when the language server attaches
    local servers = { "clangd", "pyright", "cmake" }
    for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup { on_attach = on_attach }
    end
EOF

" clang-format
let g:clang_format#detect_style_file = 1
let g:clang_format#auto_format = 1


" ==================== CUSTOM SETTINGS ======================

" remove stray ^M
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" open/source .vimrc
:nnoremap <leader>ev :e $MYVIMRC<cr>
:nnoremap <leader>sv :so $MYVIMRC<cr>

if executable('ag') 
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m
endif
