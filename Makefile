NODE = node

build/syntax/%-parser.js: src/syntax/%-grammar.bnf src/syntax/%-tokenizer.js $(wildcard lib/jglr/*.js)
	$(NODE) lib/jglr/parser-generator.js src/syntax/$*-grammar.bnf build/syntax/$*-grammar.js "../../lib/jglr" "jglr/jglr" "syntax/$*-parser"
	$(NODE) build/syntax/$*-grammar.js build/syntax/$*-parser.js

src/compiler/%.js: src/compiler/%.ts
	node_modules/.bin/tsc --module amd $<
