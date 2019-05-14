# Kairops Docker Command Launcher

Simply Bash script to run dockerized commands.

## Usage

1. Copy the `kd.sh` script to /usr/local/bin with `cp kd.sh /usr/local/bin/kd`
2. Make it executable with `chmod 777 /usr/local/bin/kd`
3. Execute any Docker Command with `kd command-name [parameter]`

Command help:

```console
$ kd
Usage:  kd command [file_or_folder] [parameter] [parameter] [...]

  command:            The Docker Command to execute, like 'hello-world' or 'git-changelog-generator'

Options:
  [file_or_folder]:   Optional file or folder to give to the container
  [parameter]:        Optional parameters. Depends on the 'docker-command' that you are running

Examples:

  kd hello-world
  kd git-changelog-generator .

You can also concatenate two or more Docker Commands through a pipe

Examples:

  kd git-changelog-generator . | kd md2html > changelog.html
```

## Available commands

- [Hello World!](https://github.com/kairops/dc-hello-world)
- [Get Next Release Number](https://github.com/kairops/dc-get-next-release-number)
- [Git Changelog Generator](https://github.com/kairops/dc-git-changelog-generator)
- [Markdown to HTML file conversion](https://github.com/kairops/dc-md2html)