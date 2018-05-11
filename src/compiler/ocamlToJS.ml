
type compiled = <
  js_code: string;
> Js.t

type ocaml = <
  compile: (string -> compiled)
> Js.t

type just_forcing_import

external foo: just_forcing_import = "_" [@@bs.module "./exports"]
external ocaml: ocaml = "ocaml" [@@bs.val]

let export_shake_token = foo

let compile_to_js (ocaml_src : string) : string =
  let compile = ocaml##compile in
  (compile ocaml_src)##js_code

