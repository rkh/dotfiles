let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <silent> <Plug>IMAP_JumpBack =IMAP_Jumpfunc('b', 0)
imap <silent> <Plug>IMAP_JumpForward =IMAP_Jumpfunc('', 0)
imap <Nul> <C-Space>
inoremap <expr> <C-Space> pumvisible() || &omnifunc == '' ? "\<C-n>" : "\<C-x>\<C-o>=pumvisible() ?" . "\"\\<c-n>\\<c-p>\\<c-n>\" :" . "\" \\<bs>\\<C-n>\"\"
map 	 :tabnext:cd %:p:h:
vmap <NL> <Plug>IMAP_JumpForward
nmap <NL> <Plug>IMAP_JumpForward
map  :tabnew
map  :VE
map  :tabnext:cd %:p:h:
map  :w:tabclose:cd %:p:h:
map [6~ 
map [5~ 
map [4~ $
map [1~ ^
map [3~ x
map [2~ i
noremap ,gf $T y$:if isdirectory("""):cd ":bd:norm ,direlse:norm gfendif
map ,dir :sp ~/tmp/vimdirG1dG:r!ls -al:se nomod
map ,x vawy:! grep " .* *
map ,tex ggO\documentclass[a4paper]{article}\usepackage{amsmath, amssymb}\usepackage[ngerman]{babel}\usepackage[utf8x]{inputenc}\usepackage[T1]{fontenc}\usepackage{listings}\author{Tim Felgentreff, 738147}\title{}\date{\today}\begin{document}\maketitle\end{document}kkkkk$i
map ,els oelse{}O
map ,for ofor(;;){}kk$hhi
map ,if oif(){}kk$i
map ,kom o/**/hi*^4i+kk4A+jYpPA 
map ,Kom o/**/hi*60a*kk60i*jYpPA 
map ,m :w:!make
map ,deb o#ifdef DEBUGMESSAGEfprintf(stderr,ANSI_COLOR_RED);fprintf(stderr,"\n");fprintf(stderr,COLOR_OFF);#endifkk$hhhhi
map ,Q 0xxx$xxxj
map ,q 0i/* A */j
map ,l :call LoadSession()
nmap :Q :q
nmap :W :w
map <Meta-O> :wincmd n:E
map E :VE
map N :wincmd n
map S :w!
map X :w:q:cd %:p:h:
nmap gx <Plug>NetrwBrowseX
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
vmap <silent> <Plug>IMAP_JumpBack `<i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpBack "_<Del>i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpForward "_<Del>i=IMAP_Jumpfunc('', 0)
nmap <silent> <Plug>IMAP_JumpBack i=IMAP_Jumpfunc('b', 0)
nmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
map <F5> maH:let x="Shown: lines ".line(".")L:let x=x." - ".line("."):echo x`a
nmap <F9> :if has("syntax_items")syntax offelsesyntax onendif
map <F3> :se t_Co=16:se t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm:se t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
map <F2> :source $VIM/vim71/syntax/
map <F4> :xa
map <S-Tab> W:cd %:p:h:
imap <NL> <Plug>IMAP_JumpForward
inoremap <expr>  pumvisible() ? "\" : "\u\"
cmap CI !ci -u %:e! %
cmap CO !co -l %:e! %
let &cpo=s:cpo_save
unlet s:cpo_save
set autochdir
set autowrite
set background=dark
set backspace=indent,eol,start
set cindent
set fileencodings=ucs-bom,utf-8,default,latin1
set grepprg=grep\ -nH\ $*
set helplang=de
set hidden
set hlsearch
set ignorecase
set incsearch
set iskeyword=@,48-57,_,192-255,-
set printoptions=paper:a4
set ruler
set runtimepath=~/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim71,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after
set shell=sh
set shiftwidth=3
set showcmd
set showmatch
set smartcase
set nostartofline
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Dokumente/Studium/HPI/Projekte\\Seminare/2008\\2009/AoP/FeatureOrientedProgramming/AheadTutorial/Dsub
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 calc.jak
args calc.jak
edit calc.jak
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal keymap=
setlocal noarabic
setlocal noautoindent
setlocal balloonexpr=
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal completefunc=
setlocal nocopyindent
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != ''
setlocal filetype=
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
set foldmethod=marker
setlocal foldmethod=marker
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,-
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=3
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != ''
setlocal syntax=
endif
setlocal tabstop=8
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
let s:l = 3 - ((2 * winheight(0) + 21) / 43)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
3
normal! 016l
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . s:sx
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
