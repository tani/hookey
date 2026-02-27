;;; hookey.el --- Minimal post-self-insert hooks -*- lexical-binding: t; -*-

(require 'subr-x)

(defgroup hookey nil
  "Post self-insert helpers using null-char for point matching."
  :group 'editing)

(defcustom hookey-context-length 60
  "Number of surrounding characters used for pattern matching."
  :type 'integer)

(defvar hookey-after-insert-functions nil
  "Functions called with (POS) after self-insertion.")

(defun hookey-match (pattern pos)
  "Match PATTERN against buffer context at POS.
Inside PATTERN, use \"\\0\" to represent the current insertion point."
  (let* ((window hookey-context-length)
         (context-left (buffer-substring-no-properties (max (point-min) (- pos window)) pos))
         (context-right (buffer-substring-no-properties pos (min (point-max) (+ pos window))))
         (context (concat context-left "\0" context-right)))
    (when (string-match pattern context)
      (list (match-data) context))))

(defun hookey-insert (template pos match-result)
  "Insert TEMPLATE at POS. If MATCH-RESULT is provided, expand back-references."
  (let ((expanded
         (save-match-data
           (set-match-data (car match-result))
           (match-substitute-replacement template t nil (cadr match-result)))))
    (save-excursion
      (goto-char pos)
      (insert expanded))))

(defun hookey--post-self-insert-handler ()
  "Handle self-insertion with a re-entry guard using dlet."
  (when (and (not (bound-and-true-p hookey--reentry-guard))
             (characterp last-command-event))
    (dlet ((hookey--reentry-guard t))
      (run-hook-with-args 'hookey-after-insert-functions (point)))))

;;;###autoload
(define-minor-mode hookey-mode
  "Enable post-self-insert hook dispatch."
  :lighter " Hookey"
  (if hookey-mode
      (add-hook 'post-self-insert-hook #'hookey--post-self-insert-handler nil t)
    (remove-hook 'post-self-insert-hook #'hookey--post-self-insert-handler t)))

;;;###autoload
(define-globalized-minor-mode global-hookey-mode
  hookey-mode hookey-on
  :group 'hookey)

(defun hookey-on ()
  "Turn on `hookey-mode` in the current buffer."
  (unless (minibufferp)
    (hookey-mode 1)))

(provide 'hookey)

