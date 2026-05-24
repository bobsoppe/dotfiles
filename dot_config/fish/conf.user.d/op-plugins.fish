# Wires CLIs (gh, etc.) to fetch credentials from 1Password instead of plaintext config.
# Configured per-tool via `op plugin init <tool>`.
if test -f $HOME/.config/op/plugins.sh
    source $HOME/.config/op/plugins.sh
end
