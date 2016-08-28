syntax on
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'tComment'
Plugin 'flazz/vim-colorschemes'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'honza/vim-snippets'
Plugin 'godlygeek/tabular'
" Plugin 'plasticboy/vim-markdown'
" Plugin 'Raimondi/delimitMate'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tpope/vim-surround'

Plugin 'Rip-Rip/clang_complete'
" Plugin 'Shougo/neocomplete.vim'
Plugin 'Shougo/deoplete.nvim'
Plugin 'SirVer/ultisnips'
Plugin 'sjl/gundo.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tmhedberg/SimpylFold'
Plugin 'christoomey/vim-tmux-navigator'
" Plugin 'kien/ctrlp.vim'

" deoplete external sources
Plugin 'eagletmt/neco-ghc'
Plugin 'zchee/deoplete-jedi'
call vundle#end()

filetype plugin indent on     " Auto indent

set number                    " Show line numbers
set relativenumber            " Make the line numbers relative to current position

syntax enable
" colorscheme badwolf
colorscheme muon
set cursorline
set guifont=Inconsolata\ for\ Powerline\ 10
set incsearch

" Folding
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

set laststatus=2
set encoding=utf-8
set ffs=unix,dos,mac
" set t_Co=256

set so=12                     " Avoid cursor getting to bottom/top
set wildignore=*.o,*~,*.pyc
set ruler
set cmdheight=1

" Search options
set ignorecase
set smartcase
set hlsearch
nmap // :noh<cr>

set pastetoggle=<F2>

set showmatch
set mat=2

set noerrorbells
set novisualbell
" set t_vb=
set tm=500

set nobackup
set nowb
set noswapfile

set expandtab
set smarttab
set shiftwidth=4
set	tabstop=4
set softtabstop=4
" set textwidth=79
set autoindent

set ai
set si
set wrap

map j gj
map k gk

inoremap jk <esc>

nnoremap H 0
nnoremap L $
vnoremap H 0
vnoremap L $

inoremap <C-Space> <esc>

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

" " Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'"
let g:airline_powerline_fonts = 1

set hidden
nmap <leader>n :enew<cr>
nmap <leader>l :bnext<CR>
nmap <leader>h :bprevious<CR>
nmap <leader>bq :bp <BAR> bd #<CR>
nmap <leader>bl :ls<CR>

" Open Nerd Tree split explorer
nnoremap <leader><TAB> :NERDTreeToggle<cr>
" comment line
nmap <space> gcc
" comment selection
vmap <space> gc

map <Leader> <Plug>(easymotion-prefix)
let g:EasyMotion_smartcase = 1

let g:syntastic_cpp_compiler = 'g++'
let g:syntastic_cpp_compiler_options = ' --std=c++11'
nnoremap <leader>sw :w !sudo tee %<CR>

" Competitive Programming Stuffs
" Open Input File
nnoremap <leader>ci :execute "vsplit %:r.in"<CR><C-W>r<CR>
" Execute
nnoremap <leader>cr :execute '!g++ --std=c++11 ' . shellescape(join([expand("%:r"),"cpp"],"."),1).
    \ ' && ./a.out < '. shellescape(join([expand("%:r"), "in"], "."), 1)<CR>
" Copy code to clipboard
nnoremap <leader>cc ggvG"+y``

" Copy to clipboard
vnoremap <leader>y "+y
" Paste from clipboard
vnoremap <leader>p "+p

nnoremap <leader>w :w<CR>

let g:vim_markdown_folding_disabled=1

inoremap <esc> <nop>

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
" Clang complete
let g:clang_complete_auto = 0
let g:clang_auto_select = 0
let g:clang_omnicppcomplete_compliance = 0
let g:clang_make_default_keymappings = 0
