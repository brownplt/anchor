var runtime = require('src/runtime/runtime.js')
var foo     = require('src/runtime/bar/foo.js')

export function print(v) {
  console.log(runtime);
  process.stdout.write(String(v));
}

