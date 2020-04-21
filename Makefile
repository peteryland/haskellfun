all:
	@for i in [1-9]*.md; do ./runmd -n "$$i" > "$${i%.md}.hs"; done

clean:
	@rm -f -- [1-9]*.hs README.hs

test:
	@./runmd [1-9]*.md

.PHONY: all clean test
