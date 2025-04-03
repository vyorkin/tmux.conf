# tmux.conf

My tmux config

## Requirements

```
brew install dark-notify
```

## Setup

* Clone this repo with submodules

  ```sh
  git clone https://github.com/vyorkin/tmux.conf.git --recurse-submodules --depth 1
  ```

* Symlink `tmux.conf` to `~/.tmux.conf`:

```sh
ln -sf $(pwd)/tmux.conf ~/.tmux.conf
```

* Symlink [tmux plugin manager](https://github.com/tmux-plugins/tpm)

```sh
mkdir -p ~/.tmux/plugins
ln -sf $(pwd)/tmux/plugins/tpm ~/.tmux/plugins/tpm
```

Install plugins via CLI:
```sh
~/.tmux/plugins/tpm/bin/install_plugins
```

## Extra

To setup tmux 1password plugin install the
[1Password CLI](https://app-updates.agilebits.com/product_history/CLI) first,
then read [this](https://github.com/yardnsm/tmux-1password#usage).
