Anchor
======

An experimental compiler for Pyret.

Requirements
------------

1. Follow the [installation instructions](https://github.com/BuckleScript/bucklescript/wiki/Installation#1-using-opam) for configuring the BuckleScript
compiler.

2. Install [nodejs](https://nodejs.org/en/) and [yarn](https://yarnpkg.com/en/).

3. Run `yarn install` to install dependencies.


Building
--------

1. Run `./bin/build-parser` to build the parser.

2. Run `yarn build` to generate JavaScript files.

Then you should be able to run `lib/js/src/compiler/parseExpr.bs.js` with `node`.

Note that BS doesn't allow us to configure the output directory so the `lib/js`
directory is the actual build directory.
