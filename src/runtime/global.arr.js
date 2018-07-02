var runtime = require('./runtime.js')
var foo     = require('./foo.js')

export function print(v) {
  console.log(runtime);
  process.stdout.write(String(v));
}

