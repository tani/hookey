;;; hookey-test.el --- Tests for hookey.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'hookey)

(ert-deftest hookey-test-match-across-point ()
  (with-temp-buffer
    (insert "abCD")
    (let ((result (hookey-match "b\0C" 3)))
      (should result))))

(ert-deftest hookey-test-insert-expands-backrefs ()
  (with-temp-buffer
    (insert "abCD")
    (let* ((pos 3)
           (result (hookey-match "\\(b\\)\0\\(C\\)" pos)))
      (should result)
      (hookey-insert "[\\1-\\2]" pos result)
      (should (equal (buffer-string) "ab[b-C]CD")))))

(ert-deftest hookey-test-mode-registers-buffer-local-hooks ()
  (with-temp-buffer
    (hookey-mode 1)
    (should (memq #'hookey--post-self-insert-handler post-self-insert-hook))
    (hookey-mode 0)
    (should-not (memq #'hookey--post-self-insert-handler post-self-insert-hook))))

(ert-deftest hookey-test-self-insert-dispatch ()
  (with-temp-buffer
    (let (called-pos)
      (add-hook 'hookey-after-insert-functions
                (lambda (pos) (setq called-pos pos))
                nil t)
      (let ((last-command-event ?x)
            (last-input-event ?x))
        (insert "x")
        (hookey--post-self-insert-handler))
      (should (= called-pos (point))))))

(ert-deftest hookey-test-self-insert-non-character-does-not-dispatch ()
  (with-temp-buffer
    (let (called-pos)
      (add-hook 'hookey-after-insert-functions
                (lambda (pos) (setq called-pos pos))
                nil t)
      (let ((last-command-event 'mouse-1)
            (last-input-event 'mouse-1))
        (insert "x")
        (hookey--post-self-insert-handler))
      (should-not called-pos))))

(ert-deftest hookey-test-self-insert-non-keyboard-input-does-not-dispatch ()
  (with-temp-buffer
    (let (called-pos)
      (add-hook 'hookey-after-insert-functions
                (lambda (pos) (setq called-pos pos))
                nil t)
      (let ((last-command-event ?x)
            (last-input-event '(mouse-1 nil)))
        (insert "x")
        (hookey--post-self-insert-handler))
      (should-not called-pos))))

(provide 'hookey-test)

;;; hookey-test.el ends here
