# Bash script code quality

This repository demonstrates via its commit history the process of improving the
code quality of a Bash script. The commit messages explain the introduced
changes and their motivation while this document lists the used tools and
references.


## Tools

The [ShellSpec] framework is used for testing as it employs a behaviour-driven
development approach with a domain-specific language that helps create easily
readable tests. In addition, it provides many options for mocking and other
useful testing features.

The other essential tool to detect error-prone code or even bugs is the static
code analyser [ShellCheck]. It can be run in the command line or integrated into
editors.

For example, for the presentation of the process, the [ALE] plugin and [Airline]
status line for Vim have been used to show the annotations in the editor.

The [Flog] plugin for Vim has been used to check out the commits one after
another, so tests could be run at the various stages.


## References

### Calling Docker for separate commands

* [Stack Overflow – What is the runtime performance cost of a Docker container?](https://stackoverflow.com/a/26149994)


### Variables

* [Unix & Linux Stack Exchange – Are there naming conventions for variables in shell scripts?](https://unix.stackexchange.com/a/42849)

* [Bash reference manual – Bash builtin commands, `local`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)


### Initialise and run ShellSpec

* [ShellSpec – Project directory](https://github.com/shellspec/shellspec/blob/b2621f7e3f63a5a683a8994bbc916dc794f2dfb8/README.md#project-directory)
* [ShellSpec – runs specfile using `/bin/sh` by default](https://github.com/shellspec/shellspec/blob/b2621f7e3f63a5a683a8994bbc916dc794f2dfb8/README.md#runs-specfile-using-binsh-by-default)
* [ShellSpec – How to use ShellSpec with Docker, Run simple with helper script and extra hooks](https://github.com/shellspec/shellspec/blob/b2621f7e3f63a5a683a8994bbc916dc794f2dfb8/docs/docker.md#2-run-simple-with-helper-script-and-extra-hooks)


### Unit testing single-file scripts

* [ShellSpec – Using `run source`](https://github.com/shellspec/shellspec/blob/b2621f7e3f63a5a683a8994bbc916dc794f2dfb8/README.md#using-run-source)
* [References](https://github.com/shellspec/shellspec/blob/b2621f7e3f63a5a683a8994bbc916dc794f2dfb8/docs/references.md)


### Error handling

* [Stack Overflow – How to exit if a command failed?](https://stackoverflow.com/q/3822621)
* [Bash FAQ – Why doesn't set -e (or set -o errexit, or trap ERR) do what I expected?](https://mywiki.wooledge.org/BashFAQ/105)

* [Bash reference manual – Special parameters, `?`](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
* [Bash reference manual – Bourne Shell builtins, `exit`](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)


### Writing output

* [Stack Overflow – Why use printf '%s\n' “message”?](https://stackoverflow.com/a/66439091)
* [Unix & Linux Stack Exchange – Why is printf better than echo?](https://unix.stackexchange.com/a/65819)

* [Bash reference manual – Bash builtin commands, `printf`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)


[ALE]:
https://github.com/dense-analysis/ale

[Airline]:
https://github.com/vim-airline/vim-airline

[Flog]:
https://github.com/rbong/vim-flog

[ShellCheck]:
https://www.shellcheck.net

[ShellSpec]:
https://shellspec.info
