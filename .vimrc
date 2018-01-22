set nocompatible
" load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'ap/vim-buftabline'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'Shougo/deoplete.nvim'
Plug 'SirVer/ultisnips'
Plug 'sjl/gundo.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'w0rp/ale'
Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot'
Plug 'vimwiki/vimwiki'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'bfredl/nvim-ipy'
Plug 'ludovicchabant/vim-gutentags'

" deoplete external sources
Plug 'zchee/deoplete-jedi'
Plug 'Rip-Rip/clang_complete'

" themes
call plug#end()

filetype plugin indent on     " auto indent
set number relativenumber     " show line numbers, make them relative
syntax enable                 " enable syntax highlighting
set t_co=256                  " force 256 colors
set wrap                      " enable word wrap
set showmatch mat=5           " blink match parenthesis, blink match time
set ruler cursorline
set so=12                     " avoid cursor getting to extreme bottom/top
set tm=400                    " Time waited for special sequences
set noerrorbells novisualbell
set hidden
colorscheme zenburn
highlight ColorColumn ctermbg=1
call matchadd('ColorColumn', '\%81v', 100)

" ==================== BASIC EDITOR SETTINGS AND MAPPINGS ====================
" set leader key
let g:mapleader = ","

" folding options
set foldlevelstart=10 foldnestmax=10 foldmethod=indent

" filetype settings
set ffs=unix,dos,mac
set wildignore=*.o,*~,*.pyc

" prevents syntax highlighting for long lines (performance)
set synmaxcol=120

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
autocmd! BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

nnoremap <leader>w :w<CR>
" save write protected file as root
nnoremap <leader>sw :w !sudo tee %<CR>

" prevent slowdown due to large lines, disable syntax highlighting beyond the
" given column
set synmaxcol=120

" Statusline
set statusline=\ %M\ %y\ %r
set statusline+=%=
set statusline+=%f
set statusline+=\ %{gutentags#statusline('[Generating...]')}
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
au FileType tex setl conceallevel=0
au FileType vimwiki setl textwidth=80

" Set spell checks
autocmd FileType tex setlocal spell
autocmd FileType vimwiki setlocal spell

" ==================== PLUGIN SETTINGS AND MAPPINGS ======================

" set netrw options
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
nnoremap <leader><TAB> :Lexplore<cr>

" comment line
nmap <space> gcc
" comment selection
vmap <space> gc

let g:vim_markdown_folding_disabled=1

" gundo bindings
nnoremap <leader>u :GundoToggle<CR>

" fzf bindings
nnoremap <C-o> :Files<CR>

" use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
" close preview window after completion
autocmd! CompleteDone * pclose!

" ultisnips settings
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/ultisnips']

" ale settings
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_save = 1
let g:ale_cpp_clang_options = '-std=c++14 -Wall -Wshadow'
let g:ale_linters = {'cpp': ['clang']}

let g:vimwiki_table_mappings = 0

let g:buftabline_indicators = 1
highlight BufTabLineFill ctermbg=8
highlight BufTabLineHidden ctermbg=8
highlight BufTabLineCurrent ctermbg=None ctermfg=10
highlight BufTabLineActive ctermbg=8 ctermfg=4

" vim-indent-guide
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2

autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=0

" gutentags
let g:gutentags_exclude_project_root = ['/usr/local', $HOME]

" ==================== CUSTOM SETTINGS ======================

" remove stray ^M
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" open/source .vimrc
:nnoremap <leader>ev :e $MYVIMRC<cr>
:nnoremap <leader>sv :so $MYVIMRC<cr>

" copy code to clipboard
nnoremap <leader>cc :%y+<CR>

if executable('ag') 
    " Note we extract the column as well as the file and line number
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m
endif
