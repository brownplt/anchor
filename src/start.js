let requirejs = require("requirejs");
requirejs.config({
  baseUrl: "./build/",
  paths: {
    "jglr": "../lib/jglr"
  }
});
requirejs(["./compiler/compile"], function(compiler) {

  console.log("hello 1");
  console.log(compiler);

});
