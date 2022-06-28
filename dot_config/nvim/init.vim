call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
 "Plug 'jeetsukumaran/vim-buffergator'
 "Plug 'nanotech/jellybeans.vim'
 Plug 'vim-autoformat/vim-autoformat'
 Plug 'jamessan/vim-gnupg'
 Plug 'tpope/vim-surround'
 Plug 'lambdalisue/suda.vim'
 "Plug 'mg979/vim-visual-multi', {'branch': 'master'}
 Plug 'dracula/vim'
 Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
 Plug 'junegunn/fzf.vim'
 Plug 'voldikss/vim-floaterm'
 Plug 'pbrisbin/vim-mkdir'
 Plug 'fladson/vim-kitty'
 "Plug 'SirVer/ultisnips'
 "Plug 'honza/vim-snippets'
 Plug 'scrooloose/nerdtree'
 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 Plug 'ryanoasis/vim-devicons'
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'itchyny/lightline.vim'
 Plug 'itchyny/vim-gitbranch'
 "Plug 'christoomey/vim-tmux-navigator'
 Plug 'szw/vim-maximizer'
 "Plug 'vimwiki/vimwiki'
 "Plug 'tbabej/taskwiki'
 "Plug 'plasticboy/vim-markdown'
 Plug 'preservim/vim-markdown'
" Plug 'kassio/neoterm'
 call plug#end()

set splitright
set splitbelow



" Maximizer
nnoremap <silent><F3> :MaximizerToggle<CR>
vnoremap <silent><F3> :MaximizerToggle<CR>gv
inoremap <silent><F3> <C-o>:MaximizerToggle<CR>

" Supress vim-buffergattor keymaps
let g:buffergator_suppress_keymaps = 1

"FloatTerm
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F12>'

"nnoremap <leader>s :FloatermToggle<CR>
"filetype plugin on

set autochdir
let g:NERDTreeChDirMode = 2

let mapleader = " " 

" NEOTerm Bindings
"nnoremap <c-q> :Ttoggle<CR>
"inoremap <c-q> <Esc>:Ttoggle<CR>
"inoremap <c-q> <c-\><c-n>:Ttoggle<CR>

"FZF Bindings
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fcc :Colors<CR>
nnoremap <leader>fm :Maps<CR>
nnoremap <leader>fh :Helptags<CR>
nnoremap <leader>fc :Commands<CR>
nnoremap <leader>fgs :GFiles?<CR>


" Direnv Directory specific Vim Config
if exists("$EXTRA_VIM")
  for path in split($EXTRA_VIM, ':')
    exec "source ".path
  endfor
endif
" Autopair Vanilla Vim Bindings

inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O


"NERDTree Bindings
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree .<CR>
map <leader>t :NERDTreeToggle<CR>
" nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

:set number

set guifont=Fira\ Code\ 11
set encoding=utf8

" Configuration for vim-markdown
autocmd FileType vimwiki setlocal syntax=markdown
let g:vim_markdown_conceal = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_math = 1
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_edit_url_in = 'tab'
let g:vim_markdown_follow_anchor = 1
"let g:vim_markdown_folding_style_pythonic = 1

" Set vimwiki to markdown
"
"au BufNewFile ~/PKM/Personal/diary/*.md :silent 0r !~/.config/nvim/bin/generate-vimwiki-diary-template '%'

"command! Diary VimwikiDiaryIndex
"augroup vimwikigroup
    "autocmd!
    "" automatically update links on read diary
    "autocmd BufRead,BufNewFile diary.wiki VimwikiDiaryGenerateLinks
"augroup end

"let g:vimwiki_list = [{'path': '~/PKM/Personal', 'syntax': 'markdown', 'ext': '.md'},{'path': '~/PKM/Work/BeCode', 'syntax': 'markdown', 'ext': '.md'},{'path': '~/PKM/Work/tech', 'syntax': 'markdown', 'ext': '.md'}]
"let g:vimwiki_markdown_link_ext = 1

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

" color schemes
 if (has("termguicolors"))
 set termguicolors
 endif
 syntax enable
 " colorscheme evening
colorscheme dracula" open new split panes to right and below
set splitright
set splitbelow


inoremap <Tab> <C-P>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Light Git Config
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name',
      \   'filename': 'FilenameForLightline'  
      \ },
      \ }

" Function To provide full path to lightline from https://codeyarns.com/tech/2017-10-25-how-to-show-full-file-path-in-lightline.html 
function! FilenameForLightline()
    return expand('%')
endfunction

" Pane Switching Key Bindings
" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" set relativenumber
set nocompatible            " disable compatibility to old-time vi
set hidden
set showmatch               " show matching 
set scrolloff=8
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set linebreak
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.
