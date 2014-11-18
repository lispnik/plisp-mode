;;; picolisp-mode.el --- major mode for PicoLisp programming.

;; Copyright (C) 2014  Alexis <flexibeast@gmail.com>

;; Author: Alexis <flexibeast@gmail.com>
;; Maintainer: Alexis <flexibeast@gmail.com>
;; Created: 2014-11-18
;; URL: https://github.com/flexibeast/picolisp-mode
;; Keywords: picolisp, lisp, programming

;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

;;; Commentary:

;; `picolisp-mode` provides a major mode for PicoLisp programming.

;; ## Table of Contents

;; - [Features](#features)
;; - [Installation](#installation)
;; - [Usage](#usage)
;; - [Issues](#issues)
;; - [License](#license)

;; ## Features

;; * Syntax highlighting of PicoLisp code.

;; * Comint-based `pil` REPL buffers.

;; * Quick access to documentation for function at point.

;; ## Installation

;; Install [picolisp-mode from MELPA](http://melpa.org/#/picolisp-mode), or put the `picolisp-mode` folder in your load-path and do a `(require 'picolisp-mode)`.

;; ## Usage

;; Enable syntax highlighting for a PicoLisp source buffer with `M-x picolisp-mode`.

;; Start a `pil` REPL session with `M-x picolisp-repl`.

;; Access documentation for the function at point with `C-c C-f` (`picolisp-describe-function`). The browser used by `pil` is specified by the variable `picolisp-browser`. By default, it is set to the `eww` helper shell script in the `picolisp-mode` source directory, which opens an `eww` buffer via `emacsclient`. If you're using a pre-24.4 version of Emacs (and thus don't have `eww` available), or don't want to run an Emacs daemon/server, you can set `picolisp-browser` to any other HTML browser on your system, e.g. `/usr/bin/iceweasel`.

;; Various customisation options, including the faces used for syntax highlighting, are available via the `picolisp` customize-group.

;; <a name="issues"></a>

;; ## Issues / bugs

;; If you discover an issue or bug in `picolisp-mode` not already noted:

;; * as a TODO item, or

;; * in [the project's 'Issues' section on GitHub](https://github.com/flexibeast/picolisp-mode/issues),

;; please create a new issue with as much detail as possible, including:

;; * which version of Emacs you're running on which operating system, and

;; * how you installed `picolisp-mode`.

;; ## License

;; [GNU General Public License version 3](http://www.gnu.org/licenses/gpl.html), or (at your option) any later version.

;;; Code:


;;
;; User-customisable settings.
;;

(defgroup picolisp nil
  "PicoLisp support."
  :group 'languages)

(defcustom picolisp-picolisp-executable "/usr/bin/picolisp"
  "Absolute path of the `picolisp' executable."
  :type '(file :must-match t)
  :group 'picolisp)

(defcustom picolisp-pil-executable "/usr/bin/pil"
  "Absolute path of the `pil' executable."
  :type '(file :must-match t)
  :group 'picolisp)

(defcustom picolisp-browser (concat (file-name-directory load-file-name) "eww.sh")
  "Absolute path of the preferred Web browser."
  :type '(file :must-match t)
  :group 'picolisp)

(defcustom picolisp-repl-debug-p t
  "Whether to enable debug mode in the REPL.
Must be `t' to access documentation via `picolisp-describe-function'."
  :type 'boolean
  :group 'picolisp)

(defgroup picolisp-faces nil
  "Faces for PicoLisp syntax highlighting."
  :group 'picolisp)

(defface picolisp-abstract-class-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp abstract classes."
  :group 'picolisp-faces)

(defface picolisp-builtin-face
  '((((background light)) :foreground "Purple"))
  "Face for PicoLisp builtins."
  :group 'picolisp-faces)

(defface picolisp-comment-face
  '((((background light)) :foreground "green"))
  "Face for PicoLisp comments."
  :group 'picolisp-faces)

(defface picolisp-global-constant-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp global constants."
  :group 'picolisp-faces)

(defface picolisp-global-variable-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp global variables."
  :group 'picolisp-faces)

(defface picolisp-local-function-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp local functions."
  :group 'picolisp-faces)

(defface picolisp-method-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp methods."
  :group 'picolisp-faces)

(defface picolisp-normal-class-face
  '((((background light)) :foreground "blue"))
  "Face for PicoLisp normal classes."
  :group 'picolisp-faces)


;;
;; Internal variables.
;;

;; http://software-lab.de/doc/ref.html#fun

(defvar picolisp-builtins
  '("!" "$" "$dat" "$tim" "%" "&" "*" "**" "*/" "*Allow" "*Bye" "*CPU" "*Class" "*Class" "*DB" "*Dbg" "*Dbg" "*Dbs" "*EAdr" "*Err" "*Fork" "*Hup" "*Led" "*Msg" "*OS" "*PPid" "*Pid" "*Prompt" "*Run" "*Scl" "*Sig1" "*Sig2" "*Solo" "*Tsm" "*Uni" "*Zap" "+" "+Alt" "+Any" "+Aux" "+Bag" "+Blob" "+Bool" "+Date" "+Dep" "+Entity" "+Fold" "+Hook" "+Hook2" "+Idx" "+IdxFold" "+Joint" "+Key" "+Link" "+List" "+Mis" "+Need" "+Number" "+Ref" "+Ref2" "+Sn" "+String" "+Swap" "+Symbol" "+Time" "+UB" "+index" "+relation" "-" "->" "/" ":" "::" ";" "<" "<=" "<>" "=" "=0" "=:" "==" "====" "=T" ">" ">=" ">>" "?" "@" "@@" "@@@" "This" "^" "abort" "abs" "accept" "accu" "acquire" "adr" "alarm" "align" "all" "allow" "allowed" "and" "any" "append" "append/3" "apply" "arg" "args" "argv" "as" "asoq" "assert" "asserta" "asserta/1" "assertz" "assertz/1" "assoc" "at" "atom" "aux" "balance" "be" "beep" "bench" "bin" "bind" "bit?" "blob" "blob!" "bool" "bool/3" "box" "box?" "by" "bye" "bytes" "caaaar" "caaadr" "caaar" "caadar" "caaddr" "caadr" "caar" "cache" "cadaar" "cadadr" "cadar" "caddar" "cadddr" "caddr" "cadr" "call" "call/1" "can" "car" "case" "casq" "catch" "cd" "cdaaar" "cdaadr" "cdaar" "cdadar" "cdaddr" "cdadr" "cdar" "cddaar" "cddadr" "cddar" "cdddar" "cddddr" "cdddr" "cddr" "cdr" "center" "chain" "char" "chdir" "chkTree" "chop" "circ" "circ?" "class" "clause" "clause/2" "clip" "close" "cmd" "cnt" "co" "collect" "commit" "con" "conc" "cond" "connect" "cons" "copy" "count" "ctl" "ctty" "curry" "cut" "d" "daemon" "dat$" "datStr" "datSym" "date" "day" "db" "db/3" "db/4" "db/5" "db:" "dbSync" "dbck" "dbs" "dbs+" "de" "debug" "dec" "def" "default" "del" "delete" "delete/3" "delq" "dep" "depth" "diff" "different/2" "dir" "dirname" "dm" "do" "doc" "e" "echo" "edit" "em" "env" "eof" "eol" "equal/2" "err" "errno" "eval" "expDat" "expTel" "expr" "ext?" "extend" "extern" "extra" "extract" "fail" "fail/0" "fetch" "fifo" "file" "fill" "filter" "fin" "finally" "find" "fish" "flg?" "flip" "flush" "fmt64" "fold" "fold/3" "for" "fork" "forked" "format" "free" "from" "full" "fully" "fun?" "gc" "ge0" "genKey" "get" "getd" "getl" "glue" "goal" "group" "gt0" "hash" "hax" "hd" "head" "head/3" "heap" "hear" "here" "hex" "host" "id" "idx" "if" "if2" "ifn" "import" "in" "inc" "inc!" "index" "info" "init" "insert" "intern" "ipid" "isa" "isa/2" "iter" "job" "journal" "key" "kids" "kill" "last" "later" "ld" "le0" "leaf" "length" "let" "let?" "lieu" "line" "lines" "link" "lint" "lintAll" "list" "listen" "lit" "load" "loc" "local" "locale" "lock" "loop" "low?" "lowc" "lst/3" "lst?" "lt0" "lup" "macro" "made" "mail" "make" "map" "map/3" "mapc" "mapcan" "mapcar" "mapcon" "maplist" "maps" "mark" "match" "max" "maxKey" "maxi" "member" "member/2" "memq" "meta" "meth" "method" "min" "minKey" "mini" "mix" "mmeq" "money" "more" "msg" "n0" "n==" "nT" "name" "nand" "native" "need" "new" "new!" "next" "nil" "nil/1" "nond" "nor" "not" "not/1" "nth" "num?" "obj" "object" "oct" "off" "offset" "on" "onOff" "once" "one" "open" "opid" "opt" "or" "or/2" "out" "pack" "pad" "pair" "part/3" "pass" "pat?" "patch" "path" "peek" "permute/2" "pick" "pico" "pilog" "pipe" "place" "poll" "pool" "pop" "port" "pp" "pr" "prEval" "pre?" "pretty" "prin" "prinl" "print" "println" "printsp" "prior" "proc" "prog" "prog1" "prog2" "prop" "protect" "prove" "prune" "push" "push1" "put" "put!" "putl" "pwd" "qsym" "query" "queue" "quit" "quote" "rand" "range" "range/3" "rank" "raw" "rc" "rd" "read" "recur" "recurse" "redef" "rel" "release" "remote/2" "remove" "repeat" "repeat/0" "replace" "request" "rest" "retract" "retract/1" "reverse" "rewind" "rollback" "root" "rot" "round" "rules" "run" "same/3" "scan" "scl" "script" "sect" "seed" "seek" "select" "select/3" "send" "seq" "set" "set!" "setq" "show" "show/1" "sigio" "size" "skip" "solve" "sort" "sp?" "space" "split" "sqrt" "stack" "stamp" "state" "stem" "step" "store" "str" "str?" "strDat" "strip" "sub?" "subr" "sum" "super" "sym" "sym?" "symbols" "sync" "sys" "t" "tab" "tail" "task" "telStr" "tell" "test" "text" "throw" "tick" "till" "tim$" "time" "timeout" "tmp" "tolr/3" "touch" "trace" "traceAll" "trail" "tree" "trim" "true/0" "try" "type" "u" "ubIter" "udp" "ultimo" "unbug" "undef" "unify" "uniq" "uniq/2" "unless" "until" "untrace" "up" "upd" "update" "upp?" "uppc" "use" "useKey" "usec" "val" "val/3" "var" "var:" "version" "vi" "view" "wait" "week" "what" "when" "while" "who" "wipe" "with" "wr" "wrap" "xchg" "xor" "x|" "yield" "yoke" "zap" "zapTree" "zero" "|"))

(defvar picolisp-builtins-by-length
  (let ((bs (copy-sequence picolisp-builtins)))
    (sort bs #'(lambda (e1 e2)
                 (> (length e1) (length e2)))))
  "List of PicoLisp builtins, sorted by length for use by
`picolisp-builtins-regex'.")

(defvar picolisp-builtins-regex
  (let ((s "")
        (firstp t))
    (dolist (b picolisp-builtins-by-length)
      (if (not firstp)
          (setq s (concat s "\\|" (regexp-quote b)))
        (progn
          (setq s (regexp-quote b))
          (setq firstp nil))))
    s)
  "Regex for use by `picolisp-font-lock-keywords'.")

;; http://software-lab.de/doc/ref.html#conv

(defvar picolisp-font-lock-keywords
  `(("\\(\\+[a-z]\\S-*\\)"
     (1 'picolisp-abstract-class-face))
    (,(concat "(\\(" picolisp-builtins-regex "\\)")
     (1 'picolisp-builtin-face))
    ("\\(#.*\\)"
     (1 'picolisp-comment-face))
    ("\\(T[^[:alpha:]]+\\|NIL\\)"
     (1 'picolisp-global-constant-face))
    ("\\(\\*[[:alpha:]]+\\)"
     (1 'picolisp-global-variable-face))
    ("\\(_\\S-+\\)"
     (1 'picolisp-local-function-face))
    ("\\(\\S-+>\\s-\\)"
     (1 'picolisp-method-face))
    ("\\(\\+[A-Z][[:alpha:]]*\\)"
     (1 'picolisp-normal-class-face))))

;;
;; http://software-lab.de/doc/ref.html#symbol:
;;
;; Internal symbol names can consist of any printable (non-whitespace)
;; character, except for the following meta characters:
;;
;; "  '  (  )  ,  [  ]  `  ~ { }
;;

(defvar picolisp-mode-syntax-table
  (let ((table (make-syntax-table))
        (i 0))
    
    ;;; Symbol syntax

    (while (< i ?0)
      (modify-syntax-entry i "_   " table)
      (setq i (1+ i)))
    (setq i (1+ ?9))
    (while (< i ?A)
      (modify-syntax-entry i "_   " table)
      (setq i (1+ i)))
    (setq i (1+ ?Z))
    (while (< i ?a)
      (modify-syntax-entry i "_   " table)
      (setq i (1+ i)))
    (setq i (1+ ?z))
    (while (< i 128)
      (modify-syntax-entry i "_   " table)
      (setq i (1+ i)))
    (modify-syntax-entry ?@ "_   " table)
    ;; { and } delimit external symbol names.
    (modify-syntax-entry ?\{ "_   " table)
    (modify-syntax-entry ?\} "_  " table)
    ;; . can be used in a symbol name, even though,
    ;; when surrounded by white space, it's
    ;; a metacharacter indicating a dotted pair.
    (modify-syntax-entry ?. "_   " table)
    ;; " primarily indicates a transient symbol, even
    ;; though it can also be used to indicate strings.
    (modify-syntax-entry ?\" "_    " table)
    
    ;;; Whitespace syntax
    
    (modify-syntax-entry ?\s "    " table)
    (modify-syntax-entry ?\x8a0 "    " table)
    (modify-syntax-entry ?\t "    " table)
    (modify-syntax-entry ?\f "    " table)

    ;;; Comment syntax
    
    (modify-syntax-entry ?# "<   " table)
    (modify-syntax-entry ?\n ">   " table)

    ;;; Quote syntax
    
    (modify-syntax-entry ?` "'   " table)
    (modify-syntax-entry ?' "'   " table)
    (modify-syntax-entry ?, "'   " table)
    (modify-syntax-entry ?~ "'   " table)

    ;;; Parenthesis syntax
    
    (modify-syntax-entry ?\( "()  " table)
    (modify-syntax-entry ?\) ")(  " table)
    (modify-syntax-entry ?\[ "(]  " table)
    (modify-syntax-entry ?\] ")[  " table)

    ;;; Escape syntax

    (modify-syntax-entry ?\\ "\\   " table)
    
    table)
  
  "Syntax table used in `picolisp-mode'.")


;;
;; User-facing functions.
;;

(defun picolisp-describe-function ()
  "Display docs for symbol at point using `picolisp-browser'."
  (interactive)
  (let ((process-environment
         (add-to-list 'process-environment
                      (concat "BROWSER=" picolisp-browser)))
        (func (symbol-name
               (symbol-at-point))))
    (if (member func picolisp-builtins)
        (start-process-shell-command "picolisp-doc" nil
                                     (concat "pil -\"doc (car (nth (argv) 3)\" -bye - '" func "' +"))
      (message "No PicoLisp builtin at point."))))

;;;###autoload
(define-derived-mode picolisp-mode lisp-mode "PicoLisp"
  "Major mode for PicoLisp programming. Derived from lisp-mode.

\\{picolisp-mode-map}"
  (set-syntax-table picolisp-mode-syntax-table)
  (setq font-lock-defaults '((picolisp-font-lock-keywords)))
  (define-key picolisp-mode-map (kbd "C-c C-f") 'picolisp-describe-function))

;;;###autoload
(define-derived-mode picolisp-repl-mode comint-mode "PicoLisp REPL"
  "Major mode for `pil' REPL sessions. Derived from comint-mode.

\\{picolisp-repl-mode-map}"
  (set-syntax-table picolisp-mode-syntax-table)
  (setq font-lock-defaults '((picolisp-font-lock-keywords)))
  (define-key picolisp-repl-mode-map (kbd "C-c C-f") 'picolisp-describe-function))

;;;###autoload
(defun picolisp-repl ()
  "Start a `pil' session in a new `picolisp-repl-mode' buffer."
  (interactive)
  (let ((process-environment
         (add-to-list 'process-environment
                      (concat "BROWSER=" picolisp-browser))))
    (make-comint "picolisp-repl" "pil" nil (if picolisp-repl-debug-p "+" nil))
    (switch-to-buffer "*picolisp-repl*")
    (picolisp-repl-mode)))


;; --

(provide 'picolisp-mode)

;;; picolisp-mode.el ends here
