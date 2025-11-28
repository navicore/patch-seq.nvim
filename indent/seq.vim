" Vim indent file
" Language: Seq
" Maintainer: Ed Sweeney

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetSeqIndent()
setlocal indentkeys+=0;,0],0=then,0=else

if exists("*GetSeqIndent")
  finish
endif

function! GetSeqIndent()
  let lnum = prevnonblank(v:lnum - 1)
  if lnum == 0
    return 0
  endif

  let prev_line = getline(lnum)
  let curr_line = getline(v:lnum)
  let ind = indent(lnum)

  " Increase indent after word definition start
  if prev_line =~ '^\s*:\s*\S\+'
    let ind += shiftwidth()
  endif

  " Increase indent after 'if'
  if prev_line =~ '\<if\>\s*$'
    let ind += shiftwidth()
  endif

  " Increase indent after 'else'
  if prev_line =~ '\<else\>\s*$'
    let ind += shiftwidth()
  endif

  " Increase indent after opening bracket
  if prev_line =~ '\[\s*$'
    let ind += shiftwidth()
  endif

  " Decrease indent for 'then', 'else', closing bracket, semicolon
  if curr_line =~ '^\s*\<then\>'
    let ind -= shiftwidth()
  endif
  if curr_line =~ '^\s*\<else\>'
    let ind -= shiftwidth()
  endif
  if curr_line =~ '^\s*\]'
    let ind -= shiftwidth()
  endif
  if curr_line =~ '^\s*;'
    let ind -= shiftwidth()
  endif

  return ind < 0 ? 0 : ind
endfunction
