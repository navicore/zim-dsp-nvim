" Vim syntax file for zim-dsp patches
" Language: Zim DSP
" Maintainer: zim-dsp-nvim

if exists("b:current_syntax")
  finish
endif

" Comments
syn match zimComment "#.*$" contains=zimTodo
syn keyword zimTodo TODO FIXME XXX NOTE contained

" Module types
syn keyword zimModuleType osc oscillator filter env envelope vca mix mixer nextgroup=zimWaveform,zimNumber skipwhite contained

" Module definition
syn match zimModuleDef "^\s*\w\+:" nextgroup=zimModuleType skipwhite

" Connections
syn match zimConnection "<-"
syn match zimPort "\<\w\+\.\w\+\>"

" Numbers
syn match zimNumber "\<\d\+\>"
syn match zimNumber "\<\d\+\.\d*\>"
syn match zimNumber "\<\.\d\+\>"
syn match zimNumber "\<\d\+\.\d*[eE][+-]\?\d\+\>"

" Operators
syn match zimOperator "[+\-*/]"

" Special destination
syn keyword zimSpecial out

" Waveforms (after osc/oscillator)
syn keyword zimWaveform sine saw square triangle contained

" Parameters
syn match zimParam "\<\w\+\>" contained

" Define highlighting
hi def link zimComment      Comment
hi def link zimTodo         Todo
hi def link zimModuleDef    Identifier
hi def link zimModuleType   Type
hi def link zimConnection   Operator
hi def link zimPort         Function
hi def link zimNumber       Number
hi def link zimOperator     Operator
hi def link zimSpecial      Special
hi def link zimWaveform     Constant
hi def link zimParam        Normal

let b:current_syntax = "zim"