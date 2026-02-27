Hookey.el
=========

**hookey** is a lightweight Emacs Lisp framework designed to
trigger actions by matching regex patterns against the context
surrounding the cursor immediately after text insertion.

The Core Idea: `\0` Matching
----------------------------

Usually, writing regex to handle post-insertion logic is cumbersome.
Hookey simplifies this by creating a temporary string where
the current cursor position is represented by a virtual null character (`\0`).

This allows you to write a single,
intuitive regex that spans **across the insertion point**,
matching both "left-of-cursor" and "right-of-cursor" contexts simultaneously.

- https://github.com/cohama/lexima.vim
- https://github.com/hrsh7th/nvim-insx

Features
--------

- **Simple Pattern Matching**: Represent the cursor position as `\0` in your regex.
- **Back-references**: Since it preserves `match-data`,
  you can easily use `\1`, `\2`, etc., for smart expansions.
- **Lightweight**: Zero external dependencies (only requires `subr-x`).

Installation
------------

Place `hookey.el` in your `load-path` and add the following to your `init.el`:

```elisp
(use-package :hookey
  :vc (:url "https://github.com/tani/hookey")
  :config
  (global-hookey-mode 1))
```

Usage
-----

Add a function that accepts a position `pos` to `hookey-after-insert-functions`.

### Example: Smart Brace Expansion

For instance, you can easily implement a rule: "If the user presses `>` to complete the open tag, insert the corresponding close tag."

```elisp
(defun hookey-html-tag (pos)
   (when-let* ((_ (not (nth 3 (syntax-ppss))))
               (m (hookey-match "<\\(\\w+\\)>\0" pos)))
     (hookey-insert "</\\1>" pos m)))

(add-hook 'hookey-after-insert-functions #'hookey-html-tag)
```

License
-------

The Unlicense

Copyright 2025 Taniguchi Masaya. All Rights Reserved.
