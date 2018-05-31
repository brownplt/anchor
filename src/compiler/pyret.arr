
import cmdline as C
import file as F
import pathlib as P
import render-error-display as RED
import string-dict as D
import system as SYS
import file("locators/builtin.arr") as B
import file("cli-module-loader.arr") as CLI
import file("compile-structs.arr") as CS

this-pyret-dir = P.dirname(P.resolve(C.file-name))

# this value is the limit of number of steps that could be inlined in case body
DEFAULT-INLINE-CASE-LIMIT = 5

options = [D.string-dict:
  "compiled-dir",
    C.next-val-default(C.String, "compiled", none, C.once, "Directory to save compiled files to; searched first for precompiled modules"),
  "builtin-js-dir",
    C.next-val(C.String, C.many, "Directories to search for runtime files"),
  "compiled-read-only-dir",
    C.next-val(C.String, C.many, "Directories to search for precompiled files")
]

params-parsed = C.parse-args(options, C.args)

cases(C.ParsedArguments) params-parsed block:
  | success(r, rest) =>
  compiled-dir = r.get-value("compiled-dir")
  when r.has-key("builtin-js-dir"):
    B.set-builtin-js-dirs(r.get-value("builtin-js-dir"))
  end
  CLI.build-runnable-standalone(
      rest.first,
      rest.first + ".jarr",
      CS.default-compile-options.{
        this-pyret-dir: this-pyret-dir,
        standalone-file: "not using because we are relying on running with node",
        checks : false,
        type-check : true,
        allow-shadowed : false,
        collect-all: false,
        collect-times: false,
        ignore-unbound: false,
        proper-tail-calls: true,
        compiled-cache: compiled-dir,
        compiled-read-only: r.get("compiled-read-only-dir").or-else([list: P.join(this-pyret-dir, "../src/runtime/")]),
        display-progress: true,
        inline-case-body-limit: DEFAULT-INLINE-CASE-LIMIT,
        user-annotations: true,
        runtime-annotations: true
      })
  | arg-error(message, partial) =>
    block:
      print-error(message + "\n")
      print-error(C.usage-info(options).join-str("\n"))
    end
end
