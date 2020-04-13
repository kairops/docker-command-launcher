# DEPRECATED

Please visit https://github.com/tpbtools/docker-command-launcher

# Kairops Docker Command Launcher

Simply Bash script to run dockerized commands.

## Usage

1. Copy the `kd.sh` script to /usr/local/bin with `cp kd.sh /usr/local/bin/kd`
2. Make it executable with `chmod 777 /usr/local/bin/kd`
3. Execute any Docker Command with `kd command [file_or_folder] [parameter] [parameter] [...]`

Command help:

```console
Usage:  kd command [file_or_folder] [parameter] [parameter] [...]

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

* commit-validator v0.1.1
* get-next-release-number v1.0.2
* git-changelog-generator v0.7.4
* hello-world v0.2.1
* md2html v1.1.1
* mdline v0.1.0

Other options:
- KD_DEBUG=1    to enable verbose debug info (export KD_DEBUG=1)
- KD_EDGE=1     to use the latest release of the commands (export KD_EDGE=1)
- KD_SENTINEL=1 to enable a 24h image cache sentinel (export KD_SENTINEL=1)
```

## Available commands

- Commit Validator ([commit-validator](https://github.com/kairops/dc-commit-validator))
- Get Next Release Number ([get-next-release-number](https://github.com/kairops/dc-get-next-release-number))
- Git Changelog Generator ([git-changelog-generator](https://github.com/kairops/dc-git-changelog-generator))
- Hello World! ([hello-world](https://github.com/kairops/dc-hello-world))
- Markdown to HTML file conversion ([md2html](https://github.com/kairops/dc-md2html))
- Markdown to Timeline HTML ([mdline](https://github.com/kairops/dc-mdline))
