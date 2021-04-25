# My Simple Web Server in OCaml

It uses [Dream](https://aantron.github.io/dream/) for the backend and [Melange](https://github.com/melange-re/melange) for the frontend.

## Requirements 

* Linux. You should be able to build it on Windows or MacOS, but there is some shell scripts for convenience in [esy.json](esy.json) that you will have to translate.

* [npm](https://www.npmjs.com/get-npm) installed somewhere.

* The [esy](https://esy.sh/) package manager. Install it by running `npm install -g esy`.

* You must install `sqlite3` via your package manager, the website uses it to store messages and accounts.

## Building Steps

* First run `npm init && npm install` it is required for now to grab some dependencies Melange can't find when installed with `esy`.

* Then run `esy`. If it's the first time you use it, it will take some time to compile Melange, Dream and the OCaml compiler.

* Run `esy generate_database` to create an empty database

* Finally you can build and run the website using `esy start`. You can also use `esy watch` to rebuild the website each time a file is modified (it uses `inotifywait`, only available on Linux).

