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
$ ./bin/build-parser
$ make
```

Which will build `build/pyret.jarr`
