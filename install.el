;; [[file:shen-elisp.org::*Collecting KLambda files][Collecting KLambda files:1]]
(require 'shen-primitives)
(setq *klambda-directory-name* "KLambda")
(setq *klambda-directory* (file-name-as-directory (concat (file-name-directory load-file-name) *klambda-directory-name*)))
(setq *klambda-files*
      (mapcar (lambda (klFile) (concat *klambda-directory* klFile))
              '( "yacc.kl" "core.kl" "load.kl"
                 "prolog.kl" "reader.kl" "sequent.kl" "sys.kl" "t-star.kl"
                 "toplevel.kl" "track.kl" "types.kl" "writer.kl" ;; "backend.kl"
                 "declarations.kl")))
;; Collecting KLambda files:1 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:1]]
(setq shen/*klambda-syntax-table*
      (let ((table (make-syntax-table lisp-mode-syntax-table)))
        (modify-syntax-entry 59 "_" table) ;; semi-colon
        (modify-syntax-entry ?, "_" table)
        (modify-syntax-entry ?# "_" table)
        (modify-syntax-entry ?' "_" table)
        (modify-syntax-entry ?` "_" table)
        table))

(defun shen/get-klambda-sexp-strings (klambda-file)
  (with-temp-buffer
    (insert-file-contents klambda-file)
    (with-syntax-table shen/*klambda-syntax-table*
      (let* ((klambda-code (buffer-string))
             (current-sexp-end (scan-lists 0 1 0))
             (groups nil))
        (progn
          (while current-sexp-end
            (let ((current-sexp-start (scan-lists current-sexp-end -1 0)))
              (progn
                (setq groups (nconc groups (list (buffer-substring current-sexp-start current-sexp-end))))
                (setq current-sexp-end (scan-lists current-sexp-end 1 0)))))
          groups)))))
;; Modifying The Elisp Reader For KLambda:1 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:2]]
(setq shen/*illegal-character->spelling*
      '((59 "_sneomlioccoilmoens")  ;; semicolon
        (?, "_caommmmoac")
        (35 "_hhassshh")            ;; hash
        (?' "_tkiccikt")
        (?` "_beatcokuqqukoctaeb")))

(setq shen/*spelling->illegal-character*
      (mapcar #'reverse shen/*illegal-character->spelling*))
;; Modifying The Elisp Reader For KLambda:2 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:3]]
(defun shen/remove-reserved-elisp-characters (klambda-sexp-string)
  (let ((InString nil)
        (illegal-characters
         (mapcar
          (lambda (char->spelling) (nth 0 char->spelling))
          shen/*illegal-character->spelling*))
        (res)
        (curr klambda-sexp-string))
    (cl-flet ((append-and-advance
               (&optional X)
               (progn
                 (if X (setq res (concat res X))
                   (setq res (concat res (substring curr 0 1))))
                 (setq curr (substring curr 1)))))
      (while (not (= 0 (length curr)))
        (cond
         ((char-equal (string-to-char curr) ?\")
          (if InString
              (progn
                (setq InString nil)
                (append-and-advance))
            (progn
              (setq InString 't)
              (append-and-advance))))
         ((memq (string-to-char curr) illegal-characters)
          (if InString
              (append-and-advance)
            (append-and-advance
             (car (assoc-default
                   (string-to-char curr)
                   shen/*illegal-character->spelling*)))))
         (t (append-and-advance))))
      res)))
;; Modifying The Elisp Reader For KLambda:3 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:4]]
(defun shen/put-reserved-elisp-chars-back (sexp)
  (let ((symbols (shen/find-symbols sexp)))
    (shen/internal/modify-ast sexp
                     symbols
                     (lambda (path ast)
                       (shen/change-back (shen/internal/get-element-at path ast))))))
;; Modifying The Elisp Reader For KLambda:4 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:5]]
(defun shen/change-back (symbol)
  (let* ((original-length (length (symbol-name symbol)))
         (string-left (symbol-name symbol))
         (spelling->character
          (let ((hash (make-hash-table)))
            (mapc (lambda (spelling-character)
                      (puthash (nth 0 spelling-character) (nth 1 spelling-character) hash))
                    shen/*spelling->illegal-character*)
            hash))
         (spellings (hash-table-keys spelling->character))
         (get-character-and-remaining
          (lambda (S)
            (let ((found-at-index (shen/internal/index-of (lambda (spelling) (string-prefix-p spelling S)) spellings)))
              (if found-at-index
                  (let ((spelling (nth found-at-index spellings)))
                    (list (string (gethash spelling spelling->character))
                          (substring S (length spelling))))
                (list (string (aref S 0))
                      (substring S 1))))))
         (reversed-result))
    (while (> (length string-left) 0)
      (let ((character-and-remaining (funcall get-character-and-remaining string-left)))
        (push (nth 0 character-and-remaining) reversed-result)
        (setq string-left (nth 1 character-and-remaining))))
    (intern (apply #'concat (reverse reversed-result)))))
;; Modifying The Elisp Reader For KLambda:5 ends here

;; [[file:shen-elisp.org::*Modifying The Elisp Reader For KLambda][Modifying The Elisp Reader For KLambda:6]]
(defun shen/find-symbols (sexp)
  (let ((symbols)
        (current-path)
        (current-list sexp)
        (current-list-length (length sexp))
        (current-index 0)
        (locally-scoped-symbols)
        (inner-lists))
    (while (or (< current-index current-list-length)
               inner-lists)
      (cond
       ((and (= current-index current-list-length) inner-lists)
        (progn
          (setq current-path (car inner-lists))
          (setq inner-lists (cdr inner-lists))
          (setq current-list (shen/internal/get-element-at current-path sexp))
          (setq current-index 0)
          (setq current-list-length (length current-list))))
       ((< current-index current-list-length)
        (let ((current-token (nth current-index current-list)))
          (cond
           ((symbolp current-token)
            (push (cons current-index current-path) symbols))
           ((consp current-token)
            (push (cons current-index current-path)
                  inner-lists))
           (t nil))
          (setq current-index (+ current-index 1))))
       (t nil)))
    symbols))
;; Modifying The Elisp Reader For KLambda:6 ends here

;; [[file:shen-elisp.org::*Iterating over KLambda Files][Iterating over KLambda Files:1]]
(defun build-shen-elisp-file ()
  (with-temp-file
    (concat (file-name-as-directory default-directory)
            (file-relative-name "shen-elisp.el"))
    (progn
      (erase-buffer)
      (insert "\
;;; shen-elisp.el --- An implementation of the Shen programming language  -*- lexical-binding: t -*-

;; Copyright (C) 2015-2018  Aditya Siram

;; Author: Aditya Siram <aditya.siram@gmail.com>
;; Homepage: https://github.com/deech/shen-elisp
;; License: BSD 3-Clause License
;;   http://opensource.org/licenses/BSD-3-Clause

;;; Commentary:

;; This is an implemenatation of the Shen programming language in
;; Elisp. The end goal is to provide:
;;
;; 1. An easy way to play with Shen with no other installation
;;    hassle (assuming you use Emacs).
;; 2. A first-class development experience when writing Shen.
;;    The idea is that an editor that understands the code can
;;    be much more helpful than one that does not. To this end
;;    the roadmap involves a full gamut of source code
;;    introspection and debugging tools.

;;; Code:

(require 'shen-primitives)
(setq max-lisp-eval-depth 60000)
(setq max-specpdl-size 13000)\n\n")
      (goto-char (point-max))
      (insert-file
       (concat (file-name-as-directory default-directory)
               (file-relative-name "shen-primitives.el")))
      (goto-char (point-max))
      (insert-file
       (concat (file-name-as-directory default-directory)
               (file-relative-name "shen-klambda-all.el")))
      (goto-char (point-max))
      (insert (format "%s\n" "(provide 'shen-elisp)")))))

(defun build-elisp-klambda-all-file ()
  (with-temp-file
     (concat (file-name-as-directory default-directory)
             (file-relative-name "shen-klambda-all.el"))
     (message "klambda files are %s" *klambda-files*)
     (dolist (klambda-file *klambda-files* nil)
        (message "klambda file is %s" klambda-file)
        (insert-klambda-file klambda-file))))

(defun insert-klambda-file (klambda-file)
  (dolist (klambda-sexp-string (shen/get-klambda-sexp-strings klambda-file) nil)
    (insert-klambda-sexp-string klambda-sexp-string)))

(defun insert-klambda-sexp-string (klambda-sexp-string)
  (let ((ast (shen/put-reserved-elisp-chars-back
              (read
               (shen/remove-reserved-elisp-characters
                klambda-sexp-string)))))
    (save-excursion
      (goto-char (point-max))
      (insert (pp-to-string (shen/klambda-to-elisp-object ast))))))
;; Iterating over KLambda Files:1 ends here
