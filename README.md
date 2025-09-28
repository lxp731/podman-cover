### Introduction

A plugin for zsh. Modify the `podman images` print format like `docker images`.


### Installation

1. For oh-my-zsh:

```bash
git clone https://github.com/lxp731/podman-cover.git" $ZSH_CUSTOM/plugins/podman-cover"
```

Then add this line to your `.zshrc`. Make sure it is before the line source `$ZSH/oh-my-zsh.sh`.

```bash
plugins=(
    ...
    podman-cover
)
```
