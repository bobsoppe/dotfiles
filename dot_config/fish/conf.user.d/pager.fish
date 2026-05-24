set --export PAGER "less --quit-if-one-screen --raw-control-chars"

# Catppuccin-tinted termcap colors for less (man pages, git output).
set --export LESS_TERMCAP_mb "$(set_color --bold f2d5cf)"     # blink
set --export LESS_TERMCAP_md "$(set_color --bold f2d5cf)"     # bold
set --export LESS_TERMCAP_me "$(set_color normal)"            # end mb/md
set --export LESS_TERMCAP_se "$(set_color normal)"            # end standout
set --export LESS_TERMCAP_so "$(set_color --bold f2d5cf)"     # standout
set --export LESS_TERMCAP_ue "$(set_color normal)"            # end underline
set --export LESS_TERMCAP_us "$(set_color --underline a5adce)" # underline
set --export LESS_TERMCAP_mr "$(tput rev)"                    # reverse
set --export LESS_TERMCAP_mh "$(tput dim)"                    # half-bright
set --export LESS_TERMCAP_ZN "$(tput ssubm)"                  # double-underline start
set --export LESS_TERMCAP_ZV "$(tput rsubm)"                  # double-underline end
set --export LESS_TERMCAP_ZO "$(tput ssupm)"                  # superscript start
set --export LESS_TERMCAP_ZW "$(tput rsupm)"                  # superscript end
