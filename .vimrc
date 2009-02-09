if version >= 600
set foldenable
set foldmethod=marker
endif

"" :filetype on
 set nocompatible

 "" C-style indenting
 " automatisch im C-Stil einruecken
 set cindent

 "" search case-insenitive
 " suchen case-insenitiv
 " set ignorecase

 "" show actual cursor position
 " Zeigt die aktuelle Cursorposition a
 " set ruler

 "" shell to start with !
 set shell=sh

 "" show matching braces
 " zeige passende Klammern
 set showmatch

 " Anzeige INSERT/REPLACE/...
 set showmode

 " halbfertige Kommandos werden angezeigt
 set showcmd

 " Einru:ckung
 set shiftwidth=3
 set tabstop=8

 "" when inserting TABs replace them with the appropriate
 "" number of spaces
 " Beim Einfuegen von TABs werden diese durch die passende
 " Anzahl von Spaces ersetzt
 set noexpandtab

 "" mapping some keys on my keyboard
 " einf
 map <ESC>[2~ i
 " del
 map <ESC>[3~ x
 " pos1
 map <ESC>[1~ ^
 " end
 map <ESC>[4~ $
 " PgUp
 map <ESC>[5~ <C-B>
 " PgDown
 map <ESC>[6~ <C-F>

 " Explorer
 map <S-E> :VE<CR><CR>
 
 " Tab helpers
 map <Tab> :tabnext<CR>:cd %:p:h<CR>:<CR>
 map <C-T> :tabnext<CR>:cd %:p:h<CR>:<CR>
 map <C-X> :w<CR>:tabclose:cd %:p:h<CR>:<CR>
 map <C-O> :VE<CR>
 map <C-N> :tabnew<CR>

 " Window Helpers
 set autochdir
 map <S-Tab> <C-W>W:cd %:p:h<CR>:<CR>
 map <S-X> :w<CR>:q<CR>:cd %:p:h<CR>:<CR>
 map <Meta-O> :wincmd n<CR>:E<CR>
 map <S-N> :wincmd n<CR>

 " Session helpers
 map <S-s> :w!<CR>
 map <F4> :xa<CR>
 function! MakeSession()
   let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
   if (filewritable(b:sessiondir) != 2)
     exe 'silent !mkdir -p ' b:sessiondir
     redraw!
   endif
   let b:filename = b:sessiondir . '/session.vim'
   exe "mksession! " . b:filename
 endfunction

 function! LoadSession()
   let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
   let b:sessionfile = b:sessiondir . "/session.vim"
   if (filereadable(b:sessionfile))
     exe 'source ' b:sessionfile
   else
     echo "No session loaded."
   endif
 endfunction
 map ,l :call LoadSession()<CR>
 au VimLeave * :call MakeSession()



 "" I love line numbers ;-)
 " Zeilen numeriert
 set number

 "" choose the right syntax highlightning per TAB-completion :-)
 " F2 welches Syntax-File ha:tten wir denn gerne? Einfach per <TAB> erweitern :-)
 map <F2> :source $VIM/vim71/syntax/

 "" colours in xterm
 " Farben im xterm
 map <F3> :se t_Co=16<C-M>:se t_AB=<C-V><ESC>[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm<C-V><C-M>:se t_AF=<C-V><ESC>[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm<C-V><C-M>


 "" C-style comment-in and comment-out
 map ,q 0i/* <ESC>A */<ESC>j
 map ,Q 0xxx$xxxj

 "" some shortcuts for programming
 " Abku:rzungen zum Programmieren
 map ,deb o#ifdef DEBUGMESSAGE<CR>fprintf(stderr,ANSI_COLOR_RED);<CR>fprintf(stderr,"\n");<CR>fprintf(stderr,COLOR_OFF);<CR>#endif<ESC>kk$hhhhi
 map ,m :w<CR>:!make<CR>
 map ,Kom o/**/<ESC>hi<RETURN>*<RETURN><ESC>60a*<ESC>kk60i*<ESC>jYpPA<SPACE>
 map ,kom o/**/<ESC>hi<RETURN>*<RETURN><ESC>^4i+<ESC>kk4A+<ESC>jYpPA<SPACE>
 map ,if oif()<CR>{<CR>}<ESC>kk$i
 map ,for ofor(;;)<CR>{<CR>}<ESC>kk$hhi
 map ,els oelse<CR>{<CR>}<ESC>O
 map ,tex ggO\documentclass[a4paper]{article}<CR>\usepackage{amsmath, amssymb}<CR>\usepackage[ngerman]{babel}<CR>\usepackage[utf8x]{inputenc}<CR>\usepackage[T1]{fontenc}<CR>\usepackage{listings}<CR>\author{Tim Felgentreff, 738147}<CR>\title{}<CR>\date{\today}<CR><CR>\begin{document}<CR>\maketitle<CR>\end{document}<ESC>kkkkk$i



 "" <F9> toggles highlightning
 " Syntax Highlightning an bzw. aus
 nmap <F9> :if has("syntax_items")<CR>syntax off<CR>else<CR>syntax on<CR>endif<CR><CR>

 map <F5> maH:let x="Shown: lines ".line(".")<CR>L:let x=x." - ".line(".")<CR>:echo x<CR>`a
 "" Let's see what it does:
 " Schauen wir doch mal, was das hier tut:
 "" ## use <F5> for mapping :)
 " ## <F5> wird benutzt :)
 " :map <F5>
 "" ## set a mark to store cursor position and jump to the top line
 " ## Merke die alte Cursorposition und springe zur ersten Zeile auf dem Bildschirm
 " maH
 "" ## set variable x to the value "Shown: " + current linenumber (== top line)
 " ## Setze die Variable x auf "Shown: " + die Zeilennummer
 " ##                                      (der ersten Zeile auf dem Bildschirm)
 " :let x="Shown: ".line(".")<CR>
 "" ## jump to bottom line
 " ## Springe zur letzten angezeigten Zeile
 " L
 "" ## append " - " + current linenumber (== bottom line) to variable x
 " ## ha:nge " - " und die aktuelle Zeilennummer an x an
 " :let x=x." - ".line(".")<CR>
 "" ## print the value of x
 " ## Gib x aus
 " :echo x<CR>
 "" ## jump back to the original cursor position
 " ## und zuru:ck zur Ausgangsposition
 " `a
 "
 "" ## You may need to add
 " ## evtl. muss noch ein
 " :let y='scrolloff'<CR>:set scrolloff=0<CR>
 "" ## at the beginning of the rhs, and
 " ## am Anfang des Mappings und ein
 " :exec ":set scrolloff=".y<CR>
 "" ## at the end of the rhs because H and L don't jump to the
 "" ## top/bottom line if the scrolloff option has a value greater 0.
 " ## am Ende des Mappings eingefu:gt werden, falls scrolloff einen
 " ## Wert != 0 hat

 nmap :W :w
 nmap :Q :q

 "" search the current word in all files in the working directory
 " suche das Wort unter dem Cursor in allen Dateien im aktuellen Verzeichnis
 map ,x vawy:! grep <C-R>" .* *<CR>

 :version 5.x
 " autocmd!

 "" let's use syntax highlightning
 "" source $VIM/syntax/syntax.vim

 "" keep the horizontal cursor position when moving vertically
 " behalte die Spalte bei beim Bla:ttern
 set nostartofline

 "" highlighted search
 set hlsearch
 set incsearch

 "" don't use the mouse
 " Die Maus ist fu:r Cut&Paste da ;-)
 set mouse=

 "" always show the name of the file being edited
 " Zeige immer den Dateinamen an
 "set ls=2

 "" let's adjust some colours
 " Farbeinstellungen a:ndern
 let mysyntaxfile = "~/.vimsyntax.vim"

 "" a dash "-" added for more fun with wordwise commands
 " ein "-" mehr - Kommandos, die sich auf ganze Worte beziehen, beinhalten
 " auch Worte mit "-"
 set iskeyword=@,48-57,_,192-255,-

 "" some adjustements for mails and news
 " ein paar Anpassungen zum Mail- / Newsschreiben
 au BufNewFile,BufReadPost .followup,snd.*,.letter,.article,.article.[0-9]\+,pico.[0-9]\+,mutt*[0-9] se nocin
 au BufNewFile,BufReadPost .followup,snd.*,.letter,.article,.article.[0-9]\+,pico.[0-9]\+,mutt*[0-9] se ai
 au BufNewFile,BufReadPost .followup,snd.*,.letter,.article,.article.[0-9]\+,pico.[0-9]\+,mutt*[0-9] se tw=72
 au BufNewFile,BufReadPost .followup so $VIM/syntax/mail.vim

 "" load some HTML specific mappings
 " einige mappings nur fu:r HTML dazuladen
 "" au BufNewFile,BufReadPost *.html,*.htm  so ~/.html.vim
 au BufNewFile,BufReadPost *.phtml so $VIM/syntax/html.vim


 "" TABs are needed in Makefiles
 " bei Makefiles braucht man TABs
 au BufNewFile,BufReadPost Makefile se noexpandtab

 "" Load Ruby stuff
 au BufNewFile,BufRead *.rb,*.rhtml,*.erb so ~/.vim/scripts/rubysnippets.vim 
 autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
 autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
 autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
 autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

 "" Autocompletion Stuff
 " :set completeopt=longest,menuone
 " :inoremap <expr> <CR> pumvisible() ? "\<Space>" : "\<c-g>u\<CR>"
 " :inoremap <expr> <c-n> pumvisible() ? "\<lt>c-n>" : "\<lt>c-n>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"
 " :inoremap <expr> <m-;> pumvisible() ? "\<lt>c-n>" : "\<lt>c-x>\<lt>c-o>\<lt>c-n>\<lt>c-p>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"

 :inoremap <expr> <CR> pumvisible() ? "\<c-y>" : "\<c-g>u\<CR>"
 inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
              \ "\<lt>C-n>" :
              \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
              \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
              \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
 imap <C-@> <C-Space>

 "" Type-Ahead
 "augroup foo
 "  au!
 "  au CursorMovedI,InsertEnter * if search('\k\{2,}\%#\k\@!','ncb') |
 "                   \ call feedkeys("\<c-x>\<c-o>","t") | endif
 "augroup END
 "inoremap <expr><cr> pumvisible()?"\<c-n>\<c-y> ":"\<cr>"
 



 " RCS stuff
 cmap CO !co -l %<CR>:e! %<CR><CR>
 cmap CI !ci -u %<CR>:e! %<CR><CR>

 " always show commands that are not yet typed in completely
 se showcmd



 " ,dir zeigt den aktuellen Verzeichnisinhalt,
 " ,gf editiert die Datei in der aktuellen Zeile bzw zeigt den
 " Verzeichnisinhalt im entsprechenden Verzeichnis
 map ,dir :sp ~/tmp/vimdir<CR>G1dG:r!ls -al<CR>:se nomod<CR>
 no ,gf $T y$:if isdirectory("<C-R>"")<CR>:cd <C-R>"<CR>:bd<CR>:norm ,dir<CR>else<CR>:norm gf<CR>endif<CR>

 "

 " :cmap <F8> <CR>:wn<CR>:@:<F8>

 " vim:comments=\:\"
 
 " REQUIRED. This makes vim invoke latex-suite when you open a tex file.
 filetype plugin on
 
 " IMPORTANT: grep will sometimes skip displaying the file name if you
 " search in a singe file. This will confuse latex-suite. Set your grep
 " program to alway generate a file-name.
 set grepprg=grep\ -nH\ $*

 " OPTIONAL: This enables automatic indentation as you type.
 filetype indent on

 " Startingwith Vim 7, the filetype of empty .tex files defaults to
 " 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
 " The following changes the default filetype back to 'tex':
 let g:tex_flavor='latex'

 " Strange bug with rkh's vim...
 :syntax enable
