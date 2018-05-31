type name =
  | Name of string

type op =
  | Plus

type ann =
  | AName of string
  | AApp of ann * ann list

type expr =
  | EBlock of stmt list
  | EBinop of op * expr * expr
  | ENum of string
  | EStr of string
  | EApp of expr * expr list
  | EId of string

and stmt =
  | SExpr of expr
  | SFun of string * (string * ann) list * ann * expr
  | SData of string       (* name *)
          * string list   (* type params *)
          * variant list  (* variants *)
          * member list   (* shared methods/fields *)
          * expr          (* check block *)

and variant =
  | VSingleton of string
  | VConstructor of string * (string * ann) list

and member =
  | MField of string * expr

type header =
  | Header

type program =
  | Program of header * stmt list

