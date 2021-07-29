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
