;; [[file:../shen-elisp.org::*Infrastructure][Infrastructure:1]]
(progn
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  (message "default-directory: %s" default-directory)
  (add-to-list 'load-path default-directory)
  (require 'org)
  (find-file "./shen-elisp.org")
  (org-babel-tangle)
  (load-file "install.el")
  (build-elisp-klambda-file)
 (build-shen-elisp-file)
  )

(provide 'build)
;; Infrastructure:1 ends here
