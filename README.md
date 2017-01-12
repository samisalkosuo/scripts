# Various and miscellaneous scripts

Collection of scripts that are or have been useful.

Download or clone this repository and, optionally, add it to PATH.

Some scripts use [clpargs.bash](https://github.com/samisalkosuo/clpargs) for command line arguments.
It's included as submodule and to get it, please clone this repository using:

- git clone --recursive https://github.com/samisalkosuo/scripts

Directory 'functions' includes bash-functions. If you want to use them in your shell/scripts, go to functions-directory and execute:

- for f in *; do [[ -f "$f" ]] && source "$f"; done

# License

MIT

