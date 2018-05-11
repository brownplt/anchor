open Ast
open Printf

let rec stupid_direct_compile (e : expr) =
  match e with
    | EBinop(Plus, lhs, rhs) ->
      sprintf "(%s + %s)" (stupid_direct_compile lhs) (stupid_direct_compile rhs)
    | ENum(n) -> n
    | EId(x) -> x
    | EBlock(stmts) ->
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

