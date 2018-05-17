all: build/pyret.jarr

build/pyret.jarr: src/compiler/*.arr src/compiler/*.js src/syntax/*.js src/jglr/*.js
	time pyret -c src/compiler/pyret.arr -o build/pyret.jarr \
      --perilous \
      --checks none \
      --require-config src/compiler/config.json
