set nocompatible
" load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'ap/vim-buftabline'
Plug 'tpope/vim-commentary'
Plug 'lifepillar/vim-mucomplete'
Plug 'mbbill/undotree'
Plug 'w0rp/ale'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
" Plug 'rhysd/vim-clang-format'

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'

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
set synmaxcol=400

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
au FileType markdown setl textwidth=80
au FileType tex setl conceallevel=0
let g:polyglot_disabled = ['latex']

" Set spell checks
autocmd FileType tex setlocal spell

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

" undotree bindings
nnoremap <leader>u :UndotreeToggle<CR>

" fzf bindings
nnoremap <C-o> :Files<CR>


let g:buftabline_indicators = 1
highlight BufTabLineFill ctermbg=8
highlight BufTabLineHidden ctermbg=8
highlight BufTabLineCurrent ctermbg=None ctermfg=10
highlight BufTabLineActive ctermbg=8 ctermfg=4

" gutentags
let g:gutentags_exclude_project_root = ['/usr/local', $HOME]

" ==================== IDE stuff =======================
" Autocompletion
set completeopt-=preview
set completeopt+=menuone,noselect
let g:mucomplete#enable_auto_at_startup = 1
if executable('clangd')
    augroup lsp_clangd
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd']},
                    \ 'whitelist': ['h', 'c', 'cpp', 'cc'],
                    \ })
        autocmd FileType h setlocal omnifunc=lsp#complete
        autocmd FileType c setlocal omnifunc=lsp#complete
        autocmd FileType cpp setlocal omnifunc=lsp#complete
        autocmd FileType cc setlocal omnifunc=lsp#complete
    augroup end
endif

" ale settings
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_save = 1
let g:ale_linters = {'cpp': ['clangd', 'clang-tidy']}
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 5

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
nmap <C-I> :%!clang-format -style=file<cr>
