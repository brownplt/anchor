(* Abstract type representing the result of parsing *)
type parsed

(* Abstract type representing the surface AST *)
type surfaceAst

type tokenizer = < tokenizeFrom: string -> unit [@bs.meth] > Js.t

type grammar = <
  parse: tokenizer -> parsed [@bs.meth];
  countAllParses: parsed -> int [@bs.meth];
  constructUniqueParse: parsed -> surfaceAst [@bs.meth]
> Js.t


external toks: tokenizer = "Tokenizer" [@@bs.module "../syntax/pyret-tokenizer"]
external grammar: grammar = "PyretGrammar" [@@bs.module "../syntax/pyret-parser"]

let parse (data: string) (filename: string) : surfaceAst option =
  let () = toks##tokenizeFrom data in
  let parsed = grammar##parse toks in
  let countParses = grammar##countAllParses parsed in
  if countParses = 1 then
    Some (grammar##constructUniqueParse parsed)
  else
    None


let () = Js.log (parse "x = 5 + 1" "")
