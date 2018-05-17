import file("ast.arr") as A
import js-file("./parse-pyret") as Parse

print(A.s-id)

print(Parse.surface-parse("x", "y"))


