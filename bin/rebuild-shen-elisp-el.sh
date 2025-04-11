#!/usr/bin/env sh

emacs --batch --eval "(progn (require 'org) (find-file \"./shen-elisp.org\")  (org-babel-tangle))"
