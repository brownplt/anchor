open Ast
open ExprToOcaml
open OcamlToJS

type buffer

external readFileSync : string -> buffer = "readFileSync" [@@bs.module "fs"]
external js_String : buffer -> string = "String" [@@bs.val]
external trace : unit -> unit = "console.trace" [@@bs.val]

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
  | _ ->
    begin
      Js.log sast;
      failwith ("unmatched node name: " ^ sast##name)
    end

and parse_args args =
  let actual_args = ((args##kids).(1)##kids).(0)##kids in
  List.map expr_to_ast (List.filter (fun x -> x##name != "COMMA") (Array.to_list actual_args))

and header_to_ast header =
  let args = Array.to_list (header##kids).(1)##kids in
  let ret = ann_to_ast (header##kids).(2) in
  let bindings = List.filter (fun x -> x##name = "binding") args in
  let names = List.map (fun x -> (((x##kids).(0)##kids).(0)##value, AName("ignored"))) bindings in
  (names, ret)

and params_to_ast (params : surfaceAst) =
  let comma_names_part = ((params##kids).(1))##kids in
  let rec pluck_names lst =
    match lst with
      | [] -> failwith "Ill-formed params"
      | [n] -> [n##value]
      | n::_::rest -> (n##value) :: (pluck_names rest) in
  pluck_names (Array.to_list comma_names_part)

and ann_to_ast (a : surfaceAst) =
  begin
    Js.log a;
    (* NOTE(joe): this is wrong recursive structure; should happen outside *)
    let ann_first_part = (a##kids).(0) in
    match ann_first_part##name with
      | "name-ann" -> AName(((a##kids).(0)##kids).(0)##value)
      | "app-ann" ->
        begin
          let args = List.filter (fun a -> a##name != "COMMA") (Array.to_list ((ann_first_part##kids).(2))##kids) in
          AApp(ann_to_ast ann_first_part, List.map ann_to_ast args)
        end
      | _ ->
        begin
          trace ();
          failwith ("Annotation type not supported yet: " ^ (ann_first_part##name))
        end
  end

and bind_to_ast (b : surfaceAst) =
  begin
    let b = (b##kids).(0) in
    ((b##kids).(0)##value, ann_to_ast (b##kids).(2))
  end

and member_to_ast (m : surfaceAst) =
  begin
    bind_to_ast (m##kids).(0)
  end

and members_to_ast (sasts : surfaceAst array) =
  let member_parts = Array.to_list sasts in
  let member_parts = List.filter (fun x -> x##name = "variant-member") member_parts in
  begin
  Js.log member_parts;
  List.map member_to_ast member_parts
  end

and variant_to_ast (sast : surfaceAst) =
  let is_constructor = (sast##kids).(1)##name = "variant-constructor" in
  begin if is_constructor then
    let vc = (sast##kids).(1) in
    let name = (vc##kids).(0)##value in
    let members = members_to_ast ((vc##kids).(1)##kids) in
    VConstructor(name, members)
  else
    VSingleton((sast##kids).(1)##value)
  end

and variants_to_ast (sasts : surfaceAst array) =
  let rec get_variants_starting_at i =
    let v = sasts.(i) in
    begin if v##name = "data-variant" then
      (variant_to_ast v)::(get_variants_starting_at (i + 1))
    else
      []
    end in
  get_variants_starting_at 4
  
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
      | "data-expr" ->
        let name = (kid##kids).(1)##value in
        let params = params_to_ast (kid##kids).(2) in
        let variants = variants_to_ast kid##kids in
        SData(name, params, variants, [], EStr("skipping checks"))
      | _ -> SExpr(expr_to_ast kid))
  | _ -> failwith ("Unknown stmt " ^ (sast##name))

let prog_to_ast (sast : surfaceAst) : program =
  match sast##name with
  | "program" -> Program(Header, List.map stmt_to_ast (Array.to_list ((sast##kids).(1)##kids)))

  

let compile (data: string) (filename: string) : string =
  let parsed = parse data filename in
  let _ = Js.log (Js.Json.stringifyAny parsed) in
  match parsed with
    | Some(sast) ->
      let ast = prog_to_ast sast in
      let ocaml_str = (match ast with
        | Program(_, body) -> String.concat "\n" (List.map stupid_direct_compile_toplevel body)) in
      let _ = Js.log ocaml_str in
      compile_to_js ocaml_str
    | None ->
      failwith "Parse error"

let () =
  let prog_string =  (js_String (readFileSync Sys.argv.(2))) in
  begin
    Js.log prog_string;
    Js.log (compile (js_String (readFileSync Sys.argv.(2))) Sys.argv.(2))
  end

