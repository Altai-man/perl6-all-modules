test:
	PERL6LIB=lib prove -e perl6

authortest:
	AUTHOR_TESTING=1 $(MAKE) test

README.md: lib/Text/Markdown/Discount.pm6
	echo '[![Build Status](https://travis-ci.org/hartenfels/Text-Markdown-Discount.svg?branch=master)](https://travis-ci.org/hartenfels/Text-Markdown-Discount)'\
	                         > $@
	echo                    >> $@
	perl6 --doc=Markdown $< >> $@

.PHONY: test authortest
