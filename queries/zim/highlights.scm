; Tree-sitter highlighting for zim-dsp
; This is a placeholder - full grammar would need to be implemented

; Comments
(comment) @comment

; Numbers
(number) @number

; Operators
"<-" @operator
"+" @operator
"-" @operator
"*" @operator
"/" @operator

; Keywords
"out" @keyword

; Module types
[
  "osc"
  "oscillator"
  "filter"
  "env"
  "envelope"
  "vca"
  "mix"
  "mixer"
] @type

; Waveforms
[
  "sine"
  "saw"
  "square"
  "triangle"
] @constant

; Module names
(module_name) @variable

; Ports
(port) @function