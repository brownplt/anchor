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
  | "id-expr" -> EId((sast##kids).(0)##value)
  | "app-expr" ->
    let _ = Js.log sast in
    EApp(
      expr_to_ast (sast##kids).(0),
      parse_args (sast##kids).(1))
  | "binop-expr" ->
    (match Array.length (sast##kids) with
    | 1 -> expr_to_ast (sast##kids).(0)
    | _ -> let op = ((sast##kids).(1)##kids).(0)##name in
      (match op with
        | "PLUS" ->
          let lhs = expr_to_ast (sast##kids).(0) in
          let rhs = expr_to_ast (sast##kids).(2) in
          EBinop(Plus, lhs, rhs)
        | _ -> ENum("9999")))
  | _ -> failwith ("unmatched node name: " ^ sast##name)

and parse_args args =
  let actual_args = ((args##kids).(1)##kids).(0)##kids in
  List.map expr_to_ast (List.filter (fun x -> x##name != "COMMA") (Array.to_list actual_args))

and header_to_ast header =
  let args = Array.to_list (header##kids).(1)##kids in
  let bindings = List.filter (fun x -> x##name = "binding") args in
  let names = List.map (fun x -> (((x##kids).(0)##kids).(0)##value, "anything")) bindings in
  (names, "ignored")
  
and stmt_to_ast (sast : surfaceAst) : stmt =
  match sast##name with
  | "stmt" ->
    let kid = (sast##kids).(0) in
    (match kid##name with
      | "fun-expr" ->
        let (args, ret) = header_to_ast (kid##kids).(2) in
        SFun(
          (kid##kids).(1)##value,
          args,
          ret,
          expr_to_ast (kid##kids).(5))
      | _ -> SExpr(expr_to_ast kid))
  | _ -> failwith ("Unknown stmt " ^ sast##name)

let prog_to_ast (sast : surfaceAst) : program =
  match sast##name with
  | "program" -> Program(Header, List.map stmt_to_ast (Array.to_list ((sast##kids).(1)##kids)))

  

let compile (data: string) (filename: string) : string =
  let parsed = parse data filename in
  match parsed with
    | Some(sast) ->
      let ast = prog_to_ast sast in
      let ocaml_str = (match ast with
        | Program(_, body) -> String.concat "\n" (List.map stupid_direct_compile_toplevel body)) in
      let _ = Js.log ocaml_str in
      compile_to_js ocaml_str
    | None ->
      failwith "Parse error"


let () = Js.log (compile "fun f(x): x + 1 end\nf(4)" "")

