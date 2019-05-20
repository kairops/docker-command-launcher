# Kairops Docker Command Launcher

Simply Bash script to run dockerized commands.

## Usage

1. Copy the `kd.sh` script to /usr/local/bin with `cp kd.sh /usr/local/bin/kd`
2. Make it executable with `chmod 777 /usr/local/bin/kd`
3. Execute any Docker Command with `kd command-name [parameter]`

Command help:

```console
Usage:  kd command [file_or_folder] [parameter] [parameter] [...] [-v]

command:            The Docker Command to execute, like 'hello-world' or 'git-changelog-generator'

Options:
  [file_or_folder]:   Optional file or folder to give to the container
       [parameter]:   Optional parameters. Depends on the 'docker-command' you are running

Examples:

  kd hello-world
  kd git-changelog-generator .

You can also concatenate two or more Docker Commands through a pipe

Examples:

  kd git-changelog-generator . | kd md2html - > changelog.html

Available commands:

* commit-validator
* get-next-release-number
* git-changelog-generator
* hello-world
* md2html

You can set KD_DEBUG=1 with 'export KD_DEBUG=1' to enable verbose debug info
```

## Available commands

- [Commit Validator](https://github.com/kairops/dc-commit-validator)
- [Get Next Release Number](https://github.com/kairops/dc-get-next-release-number)
- [Git Changelog Generator](https://github.com/kairops/dc-git-changelog-generator)
- [Hello World!](https://github.com/kairops/dc-hello-world)
- [Markdown to HTML file conversion](https://github.com/kairops/dc-md2html)