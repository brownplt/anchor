open Printf
open Ast
open ExprToOcaml
open OcamlToJS

(* Abstract type representing the result of parsing *)
type parsed

type pos = <
  startRow: int;
  startCol: int;
  startChar: int;
  endRow: int;
  endCol: int;
  endChar: int
> Js.t

(* Abstract type representing the surface AST *)
type surfaceAst = <
  name: string;
  kids: surfaceAst array;
  pos: pos;
  value: string
> Js.t

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

let rec expr_to_ast (sast : surfaceAst) : expr =
  match sast##name with
  | "block" -> EBlock(Array.to_list (Js.Array.map stmt_to_ast sast##kids))
  | "check-test" -> expr_to_ast (sast##kids).(0)
  | "expr" -> expr_to_ast (sast##kids).(0)
  | "prim-expr" -> expr_to_ast (sast##kids).(0)
  | "paren-expr" -> expr_to_ast (sast##kids).(1)
  | "num-expr" -> ENum((sast##kids).(0)##value)
  | "binop-expr" ->
    let op = ((sast##kids).(1)##kids).(0)##name in
    (match op with
      | "PLUS" ->
        let lhs = expr_to_ast (sast##kids).(0) in
        let rhs = expr_to_ast (sast##kids).(2) in
        EBinop(Plus, lhs, rhs)
      | _ -> ENum("9999"))
  | _ -> failwith ("unmatched node name: " ^ sast##name)

and stmt_to_ast (sast : surfaceAst) : stmt =
  match sast##name with
  | "stmt" -> SExpr(expr_to_ast (sast##kids).(0))
  | _ -> failwith "Unknown stmt"

let prog_to_ast (sast : surfaceAst) : program =
  match sast##name with
  | "program" -> Program(Header, expr_to_ast (sast##kids).(1))

  

let compile (data: string) (filename: string) : string =
  let parsed = parse data filename in
  match parsed with
    | Some(sast) ->
      let ast = prog_to_ast sast in
      let ocaml_str = (match ast with
        | Program(_, body) -> stupid_direct_compile body) in
      compile_to_js ocaml_str
    | None ->
      failwith "Parse error"


let () = Js.log (compile "5 + (1 + 4)" "")

