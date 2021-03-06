# Various and miscellaneous scripts

Collection of scripts that are or have been useful.

Download or clone this repository and, optionally, add it to PATH.

Some scripts use [clpargs.bash](https://github.com/samisalkosuo/clpargs) for command line arguments.
It's included as submodule and to get it, please clone this repository using:

- git clone --recursive https://github.com/samisalkosuo/scripts

or clone develop-branch:

- git clone -b develop --recursive https://github.com/samisalkosuo/scripts

Directory 'functions' includes bash-functions. If you want to use them in your shell/scripts, go to functions-directory and execute:

- for f in *; do [[ -f "$f" ]] && source "$f"; done

## Warning

Some or more of these scripts are not, as they say, "production quality". There are hardcoded stuff, stuff related to very specific environments or setup and so on.

Scripts are usually tested with RedHat Linux 7, or CentOS 7. Occasionally also with Mac and Cygwin.

## Scripts

- install_lighttpd.sh - Installs and start lighttpd HTTP server.
- install_ucd.sh - Installs IBM UrbanCode Deploy Server.
- install_ucd_agent.sh - Installs IBM UrbanCode Deploy Agent.
- setup_bluemix_cli.sh - Installs CLI tools for IBM Bluemix.
- username.sh - Username generator.

## Directories

- clpargs - Command line arguments for bash scripts (without getopts).
- functions - Helper functions for scripts
- misc - Uncategorized stuff
- python - Python scripts.
- was - Scripts related to IBM WebSphere Application Server.


## License

MIT

