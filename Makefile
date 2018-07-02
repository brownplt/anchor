all: checks build/pyret.jarr

.PHONY : checks
checks: src/runtime/runtime.js
	./node_modules/.bin/jshint src/runtime/runtime.js

build/pyret.jarr: src/compiler/*.arr src/compiler/locators/*.arr src/compiler/*.js src/syntax/*.js src/jglr/*.js
	mkdir -p build
	time pyret -c src/compiler/pyret.arr -o build/pyret.jarr \
      --perilous \
      --checks none \
      --require-config src/compiler/config.json \

clean:
	rm -rf build/
