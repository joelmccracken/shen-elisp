;;; build.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Joel McCracken
;;
;; Author: Joel McCracken <mccraken.joel@gmail.com>
;; Maintainer: Joel McCracken <mccraken.joel@gmail.com>
;; Created: April 13, 2025
;; Modified: April 13, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/joelmccracken/build
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(progn
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  (message "default-directory: %s" default-directory)
  (add-to-list 'load-path default-directory)
  (require 'org)
  (find-file "./shen-elisp.org")
  (org-babel-tangle)
  (load-file "install.el")
  (build-elisp-klambda-all-file)
  (build-shen-elisp-file)
  )

(provide 'build)
;;; build.el ends here
