NODE = node

all: build/syntax/pyret-parser.js
	./node_modules/.bin/tsc -p ./

build/syntax/%-parser.js: src/syntax/%-grammar.bnf src/syntax/%-tokenizer.js $(wildcard lib/jglr/*.js)
	mkdir -p build/syntax
	$(NODE) lib/jglr/parser-generator.js src/syntax/$*-grammar.bnf build/syntax/$*-grammar.js "../../lib/jglr" "jglr/jglr" "syntax/$*-parser"
	$(NODE) build/syntax/$*-grammar.js build/syntax/$*-parser.js

