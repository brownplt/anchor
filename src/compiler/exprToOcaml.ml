open Ast
open Printf

let rec stupid_direct_compile (e : expr) =
  match e with
    | EBinop(Plus, lhs, rhs) ->
      sprintf "(%s + %s)" (stupid_direct_compile lhs) (stupid_direct_compile rhs)
    | ENum(n) -> n
    | EId(x) -> x
    | EApp(f, args) ->
      sprintf "(%s %s)" (stupid_direct_compile f) (String.concat " " (List.map stupid_direct_compile args))
    | EBlock(stmts) ->
      match stmts with
        | [e] -> stupid_direct_compile_stmt e
        | _ ->
          "begin\n" ^
          String.concat ";\n" (List.map stupid_direct_compile_stmt stmts) ^
          "\nend"

and stupid_direct_compile_stmt (s : stmt) =
  match s with
    | SExpr(e) -> stupid_direct_compile e
    | SFun(name, args, _, body) ->
      sprintf "let rec %s %s =\n%s\n\n"
        name (String.concat " " (List.map fst args)) (stupid_direct_compile body)
    | _ -> failwith "not handled yet (non-expr-stmt)"

and stupid_direct_compile_toplevel (s : stmt) =
  match s with
    | SExpr(e) -> sprintf "Js.log %s;;" (stupid_direct_compile e)
    | SFun(name, args, _, body) ->
      sprintf "let rec %s %s =\n%s;;\n\n"
        name (String.concat " " (List.map fst args)) (stupid_direct_compile body)
    | _ -> failwith "not handled yet (non-expr-stmt)"

