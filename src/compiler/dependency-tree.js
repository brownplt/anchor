({
  requires: [],
  provides: {
    values: {
      "dependency-tree": "tany"
    }
  },
  nativeRequires: [],
  theModule: function(runtime, _, _, dTree) {
    function getDeps(path) {
      var dependencyTree = require('dependency-tree');

      var tree = dependencyTree.toList({
        filter: path => path.indexOf('node_modules') === -1,
        filename: path
      });
      
      return tree;
    }
    return runtime.makeModuleReturn({ "get-dependencies": runtime.makeFunction(getDeps) }, {});
  }
})
