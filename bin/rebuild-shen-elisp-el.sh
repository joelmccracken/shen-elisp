#!/usr/bin/env sh

emacs --batch -l "bin/build.el" # --eval "(progn (require 'org) (find-file \"./shen-elisp.org\")  (org-babel-tangle)
