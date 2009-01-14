"
" Ruby snippets
" Last change: August 6 2007
" Version> 0.1.0
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
" Thanks to: Andy Wokula and Antonio Terceiro for help and patches.
"
if exists("b:rubysnippets_ignore")
	finish
endif
let b:rubysnippets_ignore	= 1
let b:rubysigncount			= 1

" 
" Create a dictionary for some options
"
let b:rubysnippets_options	= {}
if exists("g:rubysnippets_skip_names")
	let b:rubysnippets_options["class"]		= ["","$a "]
	let b:rubysnippets_options["module"]	= ["","$a "]
	let b:rubysnippets_options["def"]		= ["","$a "]
else
	let b:rubysnippets_options["class"]		= [" ClassName","w"]
	let b:rubysnippets_options["module"]	= [" ModuleName","w"]
	let b:rubysnippets_options["def"]		= [" method_name","w"]
endif

"
"	See the Ruby documentation for the word under the cursor.
"	Based on the tip on http://www.vim.org/tips/tip.php?tip_id=1200
"
function! s:RubySnippetsDoc(keyword)
	" We need a browser here! it gets the value from the g:rubysnippets_browser var
	" Some possible values we can use (GNU/Linux based):
	" firefox -new-window
	" firefox -new-tab
	" xterm -bg black -fg white -e lynx
	if !exists("g:rubysnippets_browser")
		return
	endif
	" default URL, thanks James Britt!
	let url = "http://www.rollyo.com/search.html?sid=10307\&q=".a:keyword
	" if you want to search elsewhere ...
	if exists("g:rubysnippets_search_url")
		let url = g:rubysnippets_search_url
	endif
	exec "!".g:rubysnippets_browser." '".url."'"
endfunction
map <buffer> <silent> rd :call <SID>RubySnippetsDoc(expand("<cword>"))<cr><cr>

"
"	Insert a sign on the current file. The sign can be text (>>) if you're
"	using vim on a console'or a little ruby icon if you're using GUI.
"	'
function! s:RubySnippetsInsertSign()
	exe ":sign place ".b:rubysigncount." line=".line(".")." name=rubysign file=".expand("%:p")
	let b:rubysigncount += 1
endfunction

" just enable the feature if vim was compiled with signs support
if has("signs")
	let icon_image	= "ruby.xpm"
	let icon_path	= split(&rtp,",")[0]."/pixmaps/"
	if has("win32")
		let icon_image="ruby.bmp"
	endif
	exe ":sign define rubysign text=>> linehl=Warning texthl=Error icon=".icon_path.icon_image
	map <buffer> is :call <SID>RubySnippetsInsertSign()<CR> 
	map <buffer> rs :sign unplace<CR>
endif

" Simple abbreviations
iab <buffer> <silent> atr attr_reader
iab <buffer> <silent> atw attr_writer
iab <buffer> <silent> atc attr_accessor

" 
" Keep the current line value with the contents of the abbreviation.
" Used as a way to guess when a keyword does not need to behave the usual way
" on this script.
"
function! s:RubySnippetsKeepLine(line,expr)
	let pos	= getpos(".")
	let pre	= strpart(a:line,0,pos[2])
	let aft  = strpart(a:line,pos[2])
	let char = nr2char(getchar(1))
	let inc  = char!=" " ? 1 : -1
	let move = strlen(a:expr)+inc
	call setline(line("."),pre.a:expr.char.aft)
	call feedkeys("\<esc>".move."la".(inc<0?" ":""),"m")
endfunction

"
" Create a indentation string with tabs, based on the
" current line indentation. It checks if the expandtab
" option is set, and if so insert space characters, if
" not, find how many tabs are inserted based on the value
" of the tabstop option.
"
function! s:RubySnippetsCreateIndentation()
	let char = &expandtab==1 ? " " : "\t"
	let qty	= indent(".") / (&expandtab==1 ? 1 : &tabstop)
	return repeat(char,qty)
endfunction

" RubySnippetsFor()
"
" Here we have a snippet to work with for.
" It works on empty lines, or lines with one or two strings, 
" where it insert a default 'for' structure and change its 
" strings checking how many strings are on the current line.
" It works like this:
"
" current line		result
" ------------		------
" <empty>			for item in collection
"						end
" @people			for item in @people
"						end
" person @people	for person in @people
"						end												
"
" It works on Insert Mode, when you type 'for' as the first string on
" the line, and <C-F> on Insert and Normal Modes.
"
function! s:RubySnippetsFor(insert)
	let line		= getline(".")
	let token	= split(line)
	let listc	= ["for","item","in","collection"]
	let indent  = s:RubySnippetsCreateIndentation() 
	if len(token)>0 && token[0]!="for" && a:insert==1
		call s:RubySnippetsKeepLine(line,"for")
		return
	endif
	if len(token)==1
		let listc[3] = token[0]
	endif
	if len(token)==2
		let listc[1] = token[0]
		let listc[3] = token[1]
	endif
	call setline(line("."),indent.join(listc))
	call append(line("."),indent."end")
	call feedkeys("o")
endfunction
iab  <buffer> for <esc>:call <SID>RubySnippetsFor(1)<cr>
map  <buffer> <C-F> :call <SID>RubySnippetsFor(0)<cr>
imap <buffer> <C-F> <ESC>:call <SID>RubySnippetsFor(0)<cr>

"
" Used to create 'one-liners' and blocks, but just when 
" the method have a dot before its name. 
"
function! s:RubySnippetsOneLinersAndBlocks(expr,aft,append,match,keys)
	let line		= getline(".")
	let pos		= getpos(".")
	let pre		= strpart(line,0,pos[2]) 
	let subs		= strpart(line,pos[2]-1,1)

	" let's check for a match to fire the transformation
	if len(a:match)>0
		if subs!=a:match
			call s:RubySnippetsKeepLine(line,a:expr)
			return
		end
	else
		" if the match is an empty string, we check for nothing more there
		let tokens = split(line)
		if len(tokens)>0 && tokens[0]!=a:expr
			call s:RubySnippetsKeepLine(line,a:expr)
			return
		endif
	end	

	" change the current line
	call setline(".",pre.a:expr.a:aft)

	" check for the append list size
	let size = len(a:append)

	" if don't need to append something, change the cursor position and go to
	" insert mode'
	if size<1
		let pos[2] = pos[2]+len(a:expr)+len(a:aft)-1
		call setpos(".",pos)
		call feedkeys("i","n")
	else
		let indent = s:RubySnippetsCreateIndentation() 
		let cnt    = 0
		while cnt < size
			let a:append[cnt] = indent.a:append[cnt]
			let cnt = cnt + 1
		endwhile	
		call append(line("."),a:append)
	endif		
	if len(a:keys)>0
		call feedkeys(a:keys)
	endif
endfunction

" blocks
iab <buffer> <silent> each					<esc>:call <SID>RubySnippetsOneLinersAndBlocks("each"					," do \|item\|"		,["end"],".","o")<cr>
iab <buffer> <silent> each_with_index	<esc>:call <SID>RubySnippetsOneLinersAndBlocks("each_with_index"	," do \|item,index\|",["end"],".","o")<cr>
iab <buffer> <silent> inject				<esc>:call <SID>RubySnippetsOneLinersAndBlocks("inject"				," do \|memo,obj\|"	,["end"],".","o")<cr>
iab <buffer> <silent> begin				<esc>:call <SID>RubySnippetsOneLinersAndBlocks("begin"				,"",["rescue Exception => e","end"],"","o")<cr>
iab <buffer> <silent> class				<esc>:call <SID>RubySnippetsOneLinersAndBlocks("class"				,b:rubysnippets_options["class"][0],["end"],"",b:rubysnippets_options["class"][1])<cr>
iab <buffer> <silent> module				<esc>:call <SID>RubySnippetsOneLinersAndBlocks("module"				,b:rubysnippets_options["module"][0],["end"],"",b:rubysnippets_options["module"][1])<cr>
iab <buffer> <silent> def					<esc>:call <SID>RubySnippetsOneLinersAndBlocks("def"					,b:rubysnippets_options["def"][0],["end"],"",b:rubysnippets_options["def"][1])<cr>

" one-liners
iab <buffer> <silent> collect		<esc>:call <SID>RubySnippetsOneLinersAndBlocks("collect"	," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> detect		<esc>:call <SID>RubySnippetsOneLinersAndBlocks("detect"	," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> find			<esc>:call <SID>RubySnippetsOneLinersAndBlocks("find"		," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> find_all	<esc>:call <SID>RubySnippetsOneLinersAndBlocks("find_all"," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> map			<esc>:call <SID>RubySnippetsOneLinersAndBlocks("map"		," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> reject		<esc>:call <SID>RubySnippetsOneLinersAndBlocks("reject"	," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> select		<esc>:call <SID>RubySnippetsOneLinersAndBlocks("select"	," {\|item\| }",[],".","")<cr>
iab <buffer> <silent> partition	<esc>:call <SID>RubySnippetsOneLinersAndBlocks("partition"," {\|item\| }",[],".","")<cr>

"
" Create a Ruby hash representation with a list of even string parameters.
" If it's an odd number, do nothing.
"
function! s:RubySnippetsMakeHash(line)
	let tokens	= split(a:line)
	let leng		= len(tokens)
	if leng==0 || leng%2!=0
		return ""
	endif
	let qtde = leng/2
	let lnum = 0
	let list = []
	let lpos = 0
	while lnum < qtde
		call add(list,tokens[lpos]."=>".tokens[lpos+1])
		let lnum = lnum+1
		let lpos = lpos+2
	endwhile
	return "{".join(list,",")."}"
endfunction

"
" The hash is created using <C-H> on Insert and Normal Modes, where it will search
" for the positions of { and } and convert all the strings PAIRS inside 
" a hash, like this:
"
" {1 :one 2 :two 3 :three 4 :four}
"
" will become
"
" {1=>:one,2=>:two,3=>:three,4=>:four}
"
" The { and } are mandatory, they identify a hash needing to be formatted.
" If it is an odd number, do nothing.
"
function! s:RubySnippetsHash()
	let line = getline(".")
	let cpos = getpos(".")								" check where the cursor is
	let flag = line[cpos[2]-1]=="{" ? "" : "b"	" if its over a { char, we need to search forward
	let ppos	= searchpairpos("{","","}",flag)		" search for the open/close pair
	if ppos[0]==0 || ppos[1]==0						" if it's not found, we just return
		return
	endif
	let ini  = flag=="b" ? ppos[1] : cpos[2]		" check the start position
	let end	= stridx(line,"}",ini+1)				" check the end position
	let subs = strpart(line,ini,end-ini)			" get the substring
	if match(subs,'[a-zA-Z0-9: ''""]\+')<0			" if there is a hash already there, return
	  return
	end 
	let pre  = strpart(line,0,ini-1)					" the substring before the hash
	let pos  = strpart(line,end+1)					" the substring after the hash
	let rst  = s:RubySnippetsMakeHash(subs)		" make the hash!
	if strlen(rst)<1										" nothing there, go away!
		return
	endif
	call setline(line("."),pre.rst.pos)				" change the current line
	let posi		= getpos(".") 
	let endp		= stridx(getline("."),"}",ini+1)
	let posi[2]	= endp+1
	call setpos(".",posi)								" position the cursor
endfunction
imap <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
map  <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
