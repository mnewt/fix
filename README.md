# FIX -- Fish Shell POSIX Interface

> *Knowledge does not keep any better than fish*
--Alfred North Whitehead

# What is it?

Fix allows [bash](https://www.gnu.org/software/bash/) utilities to interact with the [fish](https://fishshell.com/) environment. Specifically, it runs `bash`/`csh`/`ash`/`ksh`/`sh`/`zsh` commands, then binds the resulting variables and aliases into the `fish` environment.

## This is useful for:
- Utilities which modify the environment and expect a bash/POSIX shell:
  - [nvm](https://github.com/creationix/nvm)
  - [rvm](https://rvm.io/)
  - [virtualenv](https://virtualenv.pypa.io/en/stable/)
  - [ssh-add](http://mah.everybody.org/docs/ssh) (Here's an example from my dotfiles: [start-ssh-agent](https://gitlab.com/mnewt/dotfiles/blob/master/bin/start-ssh-agent))
- Using your existing dotfiles (e.g. `.bashrc`, `.zprofile`) to set environment variables and aliases without porting them to `fish` (Another example from my dotfiles: [.aliases](https://gitlab.com/mnewt/dotfiles/blob/master/aliases))

## Why you might consider it instead of:
- [bass](https://github.com/edc/bass)
  - May work better with interactive commands?
  - Implemented in native `fish`
  - Verbose mode can also print changes in `fish` format
  - Test-only mode
  - Exciting bugs
- [fenv](https://github.com/oh-my-fish/plugin-foreign-env)
  - Works with interactive commands
  - Support for aliases
  - Support un-setting variables
  - Verbose modes to print the changes in `sh` or `fish` format
  - Test-only mode
  - Exciting bugs

# Install

## Using [Fisherman](https://fisherman.github.io/):

`fisher mnewt/fix`

## Using [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish):

`omf install mnewt/fix`

## No framework

`curl https://raw.githubusercontent.com/mnewt/fix/master/fix.fish -o ~/.config/fish/functions/fix.fish`

# Usage

Export a variable:

`fix export EDITOR=/bin/ed`

This will have the same effect as typing:

`set -gx EDITOR /bin/ed`

Source a script:

`fix source ~/.bashrc`

Will run the script and then bind the exported variables and aliases into the fish environment

# Command line options

Fish Shell POSIX Interface: Trick bash utilities into working with fish

    usage: fix [-fhpt] [-s <path_to_shell>] [--] <sh command>
       -f:    Fish    - Print bindings in fish syntax
       -h:    Help    - Print this help message
       -p:    Print   - Print bindings in sh syntax
       -s:    Shell   - Specify a shell interpreter executable path
       -t:    Test    - Print the variables and aliases that would be
                                created, but make no changes
       --:    Optional separator between parameters and shell commands

# Requirements

- Fish shell 2.2+
- sed

# Contributing

All contributions and feedback are welcomed

# To Do

There are some more features I would like to add in the [TODO](TODO.md) file.

# License

[MIT](http://opensource.org/licenses/MIT)
