---
title: "How to install Azure CLI on macOS with MacPorts"
categories:
- software
- technology
---

[Azure Command-Line Interface (CLI)](https://docs.microsoft.com/en-gb/cli/azure/) is a great tool. Unfortunately the only [installation instructions they have for macOS](https://docs.microsoft.com/en-gb/cli/azure/install-azure-cli-macos) assumes you're using [Homebrew](https://brew.sh/). I'm not. Luckily there are other - undocumented - ways of installing azure-cli and the az command.

<!--more-->

## It's just a Python package

The basic trick is the fact that [azure-cli is really a Python package](https://github.com/Azure/azure-cli/issues/6360#issuecomment-389917750) and can be installed via [pip](https://pip.pypa.io/en/stable/index.html).

## Assumptions

- macOS Monterey 12.5
- [MacPorts](https://www.macports.org/)
- Python 3.9 installed via MacPorts
- zsh 5.8.1

## Make sure you have pip and Python installed

```bash
$ sudo port install py39-pip

# Make the installed pip the default version when running pip and pip3
$ sudo port select --set pip pip39
$ sudo port select --set pip3 pip39
```

## Install the azure-cli package

```bash
# Now use pip to install azure-cli
$ sudo pip install azure-cli
```

Now, this might not get you the expected behavior default (it didn’t on my machine):

```bash
$ az
zsh: command not found: az
```

😭

This is because pip installs its packages in your user Library folder at `~/Library` (assuming it doens't have write access to your systems `site_packages` folder). It also maintains a `bin` folder there, where it has placed the `az` command:

```bash
$ ls ~/Library/Python/3.9/bin/az
/Users/jakob/Library/Python/3.9/bin/az
```

We can run the command directly from there by specifying the full path:

```bash
$ ~/Library/Python/3.9/bin/az --version
azure-cli                         2.39.0
```

But that gets tedious fast. So we need to add that folder to our `PATH` environment variable to tell our shell to look there for binaries.

## Add az to your PATH

```bash
# In your shell config extend your PATH with something like the following.
# Note that we can't expect ~ to work in $PATH, so we've replaced it with the
# $HOME variable.
export PATH="$HOME/Library/Python/3.9/bin/:$PATH"
```

On my machine I place the above in `~/.zshrc`, but this varies dependent on what shell you use and how your system is set up.

After reloading our shell we can now run `az` directly:

```bash
$ az --version
```

Enjoy!
