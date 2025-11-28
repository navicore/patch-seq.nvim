" Vim syntax file
" Language: Seq
" Maintainer: Ed Sweeney
" Latest Revision: 2024

if exists("b:current_syntax")
  finish
endif

" Comments
syn match seqComment "#.*$" contains=seqTodo
syn keyword seqTodo contained TODO FIXME XXX NOTE HACK

" Strings
syn region seqString start=/"/ skip=/\\"/ end=/"/ contains=seqEscape
syn match seqEscape contained /\\[nrt"\\]/

" Numbers
syn match seqNumber "\<-\?\d\+\>"
syn match seqFloat "\<-\?\d\+\.\d\+\>"

" Booleans
syn keyword seqBoolean true false

" Word definitions
syn match seqWordDef "^:\s*\S\+" contains=seqDefColon,seqWordName
syn match seqDefColon contained "^:"
syn match seqWordName contained "\s\zs\S\+"

" Stack effect signatures
syn region seqStackEffect start="(" end=")" contains=seqStackType,seqStackSeparator,seqRowVar
syn match seqStackSeparator contained "--"
syn keyword seqStackType contained Int Float String Bool Variant Quotation
syn match seqRowVar contained "\.\.\w\+"

" Control flow
syn keyword seqConditional if else then
syn keyword seqLoop while until times forever

" Include
syn keyword seqInclude include

" Word terminator
syn match seqTerminator ";"

" Quotations
syn region seqQuotation start="\[" end="\]" contains=ALL

" ============================================================================
" Builtins
" ============================================================================

" Stack manipulation
syn keyword seqStackOp dup drop swap over rot nip tuck pick roll

" Arithmetic
syn keyword seqArithOp add subtract multiply divide modulo negate
syn keyword seqArithOp f.add f.subtract f.multiply f.divide

" Comparison operators
syn match seqCompareOp "\<>\>"
syn match seqCompareOp "\<<\>"
syn match seqCompareOp "\<>=\>"
syn match seqCompareOp "\<<=\>"
syn match seqCompareOp "\<=\>"
syn match seqCompareOp "\<<>\>"
syn match seqCompareOp "\<f\.>\>"
syn match seqCompareOp "\<f\.<\>"
syn match seqCompareOp "\<f\.>=\>"
syn match seqCompareOp "\<f\.<=\>"
syn match seqCompareOp "\<f\.=\>"
syn match seqCompareOp "\<f\.<>\>"

" Logic
syn keyword seqLogicOp and or not

" I/O
syn keyword seqIOOp write write_line read_line
syn keyword seqIOOp file-slurp file-exists?
syn keyword seqIOOp arg arg-count

" String operations
syn keyword seqStringOp string-length string-concat string-equal
syn keyword seqStringOp string-find string-substring string-trim
syn keyword seqStringOp string-char-at char->string string-empty
syn keyword seqStringOp string-contains string-starts-with
syn keyword seqStringOp string-to-upper string-to-lower
syn keyword seqStringOp string-byte-length string-split

" Conversion
syn keyword seqConvertOp string->float float->string int->string
syn keyword seqConvertOp int->float float->int

" Variant operations
syn keyword seqVariantOp make-variant variant-tag variant-field-at
syn keyword seqVariantOp variant-field-count variant-append
syn keyword seqVariantOp variant-last variant-init

" Quotation/combinator operations
syn keyword seqCombinatorOp call spawn cond

" Concurrency
syn keyword seqConcurrencyOp make-channel send receive close-channel yield

" TCP networking
syn keyword seqNetworkOp tcp-listen tcp-accept tcp-read tcp-write tcp-close

" ============================================================================
" Highlighting
" ============================================================================

hi def link seqComment Comment
hi def link seqTodo Todo
hi def link seqString String
hi def link seqEscape SpecialChar
hi def link seqNumber Number
hi def link seqFloat Float
hi def link seqBoolean Boolean
hi def link seqDefColon Keyword
hi def link seqWordName Function
hi def link seqStackEffect Type
hi def link seqStackType Type
hi def link seqStackSeparator Operator
hi def link seqRowVar Special
hi def link seqConditional Conditional
hi def link seqLoop Repeat
hi def link seqInclude Include
hi def link seqTerminator Delimiter
hi def link seqQuotation Special

" Builtin categories with distinct colors
hi def link seqStackOp Identifier
hi def link seqArithOp Operator
hi def link seqCompareOp Operator
hi def link seqLogicOp Operator
hi def link seqIOOp Function
hi def link seqStringOp Function
hi def link seqConvertOp Function
hi def link seqVariantOp Type
hi def link seqCombinatorOp Keyword
hi def link seqConcurrencyOp Special
hi def link seqNetworkOp Special

let b:current_syntax = "seq"
