set nocompatible
" load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'ap/vim-buftabline'
Plug 'tpope/vim-commentary'
Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'Shougo/deoplete.nvim'
Plug 'SirVer/ultisnips'
Plug 'sjl/gundo.vim'
" Plug 'tmhedberg/SimpylFold'
Plug 'Yggdroot/indentLine'
Plug 'neomake/neomake'
Plug 'junegunn/goyo.vim'
Plug 'hynek/vim-python-pep8-indent'
Plug 'airblade/vim-gitgutter'
Plug 'sheerun/vim-polyglot'
Plug 'vimwiki/vimwiki'

" deoplete external sources
Plug 'eagletmt/neco-ghc'
Plug 'zchee/deoplete-jedi'
Plug 'Rip-Rip/clang_complete'

" themes
Plug 'flazz/vim-colorschemes'
call plug#end()

filetype plugin indent on     " auto indent
set number relativenumber     " show line numbers, make them relative
syntax enable                 " enable syntax highlighting
set t_co=256                  " force 256 colors
set wrap                      " enable word wrap
set showmatch mat=5           " blink match parenthesis, blink match time
set ruler cursorline
set pastetoggle=<F2>          " shortcut for paste mode
set so=12                     " avoid cursor getting to extreme bottom/top
set tm=400                    " Time waited for special sequences
set noerrorbells novisualbell
set hidden
colorscheme molokai_dark

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
nmap // :noh<cr>

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
set statusline=\ %M\ %.20f\ %y\ %r
set statusline+=%=
set statusline+=%l/%L\ %3c

set conceallevel=0
au FileType tex setl textwidth=80

" ==================== PLUGIN SETTINGS AND MAPPINGS ======================

" enable the list of buffers
" let g:airline#extensions#tabline#enabled = 1
" show just the filename
" let g:airline#extensions#tabline#fnamemod = ':t'"
" let g:airline_powerline_fonts = 1
" let g:airline_theme='zenburn'

" set netrw options
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
nnoremap <leader><TAB> :Vexplore<cr>

" comment line
nmap <space> gcc
" comment selection
vmap <space> gc

let g:vim_markdown_folding_disabled=1

" gundo bindings
nnoremap <C-z> :GundoToggle<CR>

" use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
" close preview window after completion
autocmd! CompleteDone * pclose!

" ultisnips settings
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/ultisnips']

" neomake settings
let g:neomake_cpp_clang_args = ["-std=c++14", "-Wall", "-Wshadow", "-g"]
let g:neomake_cpp_enabled_makers = ['clang']
let g:neomake_python_pylint_exe = 'pylint'
autocmd! BufWritePost * Neomake

" goyo settings
let g:goyo_width = 120
function! s:goyo_enter()
    silent !tmux set status off
endfunction

function! s:goyo_leave()
    silent !tmux set status on
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
noremap <F5> <C-O>:Goyo<CR>

let g:vimwiki_table_mappings = 0
let g:buftabline_indicators = 1
highlight BufTabLineFill ctermbg=0
highlight BufTabLineHidden ctermbg=0
highlight BufTabLineCurrent ctermbg=0 ctermfg=3
highlight BufTabLineActive ctermbg=0 ctermfg=4

" ==================== CUSTOM SETTINGS ======================

" remove stray ^M
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" open/source .vimrc
:nnoremap <leader>ev :vsplit $MYVIMRC<cr>
:nnoremap <leader>sv :e $MYVIMRC<cr>

nnoremap <C-p> :w \| !firefox %<CR><CR>

" competitive programming stuffs
" open input file
nnoremap <leader>ci :execute "vsplit %:r.in"<CR><C-W>r<CR>
" execute
nnoremap <leader>cr :execute '!g++ --std=c++11 ' . shellescape(join([expand("%:r"),"cpp"],"."),1).
    \ ' && ./a.out < '. shellescape(join([expand("%:r"), "in"], "."), 1)<CR>
" copy code to clipboard
nnoremap <leader>cc ggvG"+y``
