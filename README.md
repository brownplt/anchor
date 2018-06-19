Check out the server-dev branch of pyret-lang, and build it and link it:

```
$ git clone https://github.com/brownplt/pyret-lang
$ cd pyret-lang
$ git checkout server-dev
$ npm install
$ make
$ npm link ./
```


This should make the `pyret` command available on your system, after which you
can run setup in this repository:

```
$ npm install
$ ./bin/build-parser
$ make
```

Which will build `build/pyret.jarr`. Then you can run:

```
$ node build/pyret.jarr --builtin-js-dir src/runtime/ <path-to-arr-file>
```

To generate code. The generated code will appear as a subdirectory of
compiled/project. You can run the .arr.js file that's created directly with
`node`.
