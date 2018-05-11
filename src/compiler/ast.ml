
type atom =
  | Surface of string
  | Synth of string * string
  | Local of string * string
  | Nonlocal of string * string

type name =
  | Name of atom ref

type op =
  | Plus

type expr =
  | EBlock of stmt list
  | EBinop of op * expr * expr
  | ENum of string
  | EStr of string
  | EApp of expr * expr list

and stmt =
  | SExpr of expr
  | SFun of name * (name * name) list * name * expr

type header =
  | Header

type program =
  | Program of header * expr

