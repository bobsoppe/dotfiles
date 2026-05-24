# Prepended (not appended) so bun shadows system node/npm.
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path --global --path $BUN_INSTALL/bin
