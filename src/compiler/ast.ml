type name =
  | Name of string

type op =
  | Plus

type expr =
  | EBlock of stmt list
  | EBinop of op * expr * expr
  | ENum of string
  | EStr of string
  | EApp of expr * expr list
  | EId of string

and stmt =
  | SExpr of expr
  | SFun of string * (string * string) list * string * expr

type header =
  | Header

type program =
  | Program of header * stmt list

