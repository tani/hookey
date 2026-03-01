EMACS ?= emacs
EMACS_BATCH = $(EMACS) --batch -Q -L .

.PHONY: all test byte-compile clean

all: test

test:
	$(EMACS_BATCH) -l hookey-test.el -f ert-run-tests-batch-and-exit

byte-compile:
	$(EMACS_BATCH) -f batch-byte-compile hookey.el hookey-test.el

clean:
	rm -f *.elc
