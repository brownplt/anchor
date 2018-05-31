open OcamlToJS

type buffer
external readFileSync : string -> buffer = "readFileSync" [@@bs.module "fs"]
external js_String : buffer -> string = "String" [@@bs.val]

let () = 
  Js.log (compile_to_js (js_String (readFileSync Sys.argv.(2))))
