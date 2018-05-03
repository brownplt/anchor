import { PyretGrammar } from 'syntax/pyret-parser'
import { Tokenizer } from 'syntax/pyret-tokenizer'

function parse(data, fileName) {
  try {
    const toks = Tokenizer;
    const grammar = PyretGrammar;
    toks.tokenizeFrom(data);
    var parsed = grammar.parse(toks);
    var countParses = grammar.countAllParses(parsed);
    if (countParses == 0) {
      var nextTok = toks.curTok;
      message = "There were " + countParses + " potential parses.\n" +
                  "Parse failed, next token is " + nextTok.toString(true) +
                  " at " + fileName + ", " + nextTok.pos.toString(true);
      console.error(message);
      throw new Error(message);
    }
    if (countParses === 1) {
      var ast = grammar.constructUniqueParse(parsed);
      return ast;
    } else {
      throw "Non-unique parse";
    }
  }
  catch(e) {
    throw e;
  }
}

console.log(parse("x = 5", "foo"));

