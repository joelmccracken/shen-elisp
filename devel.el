;; [[file:shen-elisp.org::*The Runner][The Runner:1]]
(defun compile-and-load (F)
  (byte-compile-file
   (concat (file-name-as-directory default-directory)
           (file-relative-name F))
   't))
(defun load-klambda () (insert-klambda-files *klambda-files*))
(defun load-only ()
  (progn
    (compile-and-load "shen-primitives.el")
    (compile-and-load "install.el")))
(defun runner ()
  (progn
    (compile-and-load "shen-primitives.el")
    (compile-and-load "install.el")
    (insert-klambda-files *klambda-files*)
    (compile-and-load "shen-elisp.el")
    (compile-and-load "shen-overlays.el")
    (compile-and-load "shen-repl.el")
    (add-to-list 'load-path default-directory)
    (shen/repl)))
;; The Runner:1 ends here
