set nocompatible
" Load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/syntastic'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tComment'
Plug 'flazz/vim-colorschemes'
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'Rip-Rip/clang_complete'
Plug 'Shougo/deoplete.nvim'
Plug 'SirVer/ultisnips'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'
Plug 'tmhedberg/SimpylFold'
Plug 'Yggdroot/indentLine'
Plug 'neomake/neomake'

" deoplete external sources
Plug 'eagletmt/neco-ghc'
Plug 'zchee/deoplete-jedi'

call plug#end()

filetype plugin indent on     " Auto indent
set number                    " Show line numbers
set relativenumber            " Make the line numbers relative to current position
syntax enable                 " Enable syntax highlighting
set t_Co=256                  " Force 256 colors
colorscheme desert256
set cursorline                " Highlight current cursorline
set incsearch                 " Enable incremental search (Start searching while typing the search keyword)

" Folding
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

set ffs=unix,dos,mac
set so=12                     " Avoid cursor getting to extreme bottom/top
set wildignore=*.o,*~,*.pyc
set ruler                     " Show line numbers
set pastetoggle=<F2>

" Search options
set ignorecase
set smartcase

" Clear highlighting
nmap // :noh<cr>

set showmatch                 " Blink match parenthesis
set mat=5

set noerrorbells
set novisualbell
set tm=500                    " Time waited for special sequences

set nobackup
set nowb
set noswapfile

" Indentation
set expandtab
set smarttab
set shiftwidth=4
set	tabstop=4
set softtabstop=4
set autoindent

set ai
set si
set wrap                       " Enable word wrap

" Navigate through word wrap
map j gj
map k gk

" Remap command key
inoremap jk <esc>

" Set leader key
let g:mapleader = ","

" Open at the previous cursor position
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Remove stray ^M
noremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Open .vimrc
:nnoremap <leader>ev :vsplit $MYVIMRC<cr>
:nnoremap <leader>sv :so $MYVIMRC<cr>

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'"
let g:airline_powerline_fonts = 1

set hidden
nmap <leader>n :enew<cr>
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>
nmap <leader>bq :bp <BAR> bd #<CR>

" Set netrw options
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

nnoremap <leader>sw :w !sudo tee %<CR>

" Competitive Programming Stuffs
" Open Input File
nnoremap <leader>ci :execute "vsplit %:r.in"<CR><C-W>r<CR>
" Execute
nnoremap <leader>cr :execute '!g++ --std=c++11 ' . shellescape(join([expand("%:r"),"cpp"],"."),1).
    \ ' && ./a.out < '. shellescape(join([expand("%:r"), "in"], "."), 1)<CR>
" Copy code to clipboard
nnoremap <leader>cc ggvG"+y``

nnoremap <leader>w :w<CR>
nnoremap <leader>co :Neomake<CR>

let g:vim_markdown_folding_disabled=1

" gundo bindings
nnoremap <F5> :GundoToggle<CR>

nnoremap <leader>- :split<CR>
nnoremap <leader>\| :vsplit<CR>

nnoremap <C-p> :w \| !firefox %<CR><CR>
" let delimitMate_expand_cr = 1
" let g:AutoPairsMapCR = 0

" Use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
" Close preview window after completion
autocmd CompleteDone * pclose!
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/ultisnips']

let g:neomake_cpp_clang_args = ["-std=c++14", "-Wall", "-Wshadow", "-g"]
let g:neomake_cpp_enabled_makers = ['clang']
let g:airline_theme='zenburn'
