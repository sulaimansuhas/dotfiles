set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'lifepillar/vim-mucomplete'
Plugin 'liuchengxu/space-vim-dark'
Plugin 'arcticicestudio/nord-vim'
Plugin 'glepnir/oceanic-material'
"The following are examples of different formats supported.

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"VIM TIPS BEGINS HERE
" %       = for every line
" norm    = type the following commands
"A*      = append '*' to the end of current line
"VIM TIPS END HERE
syntax on
set nu
" Enable folding
set foldmethod=indent
set foldlevel=99
" Enable folding with the spacebar
nnoremap <space> za

au BufNewFile,BufRead *.py
    \ set tabstop=4|
    \ set softtabstop=4|
    \ set shiftwidth=4|
"    \ set textwidth=79|
    \ set expandtab|
    \ set autoindent|
    \ set fileformat=unix|

"mucomplete settings
set completeopt-=preview
set completeopt+=menuone,noselect
let g:jedi#popup_on_dot = 0  " It may be 1 as well
let g:mucomplete#enable_auto_at_startup = 1

"highlight settings:
hi PmenuSel ctermfg=250 ctermbg=167 guifg=#bcbcbc guibg=#af5f5f
hi Pmenu ctermfg=0 ctermbg=67 guifg=#bcbcbc guibg=#262626  


"bracket and quote matching

inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

"color scheme settings
let g:oceanic_material_transparent_background=1
colorscheme oceanic_material
