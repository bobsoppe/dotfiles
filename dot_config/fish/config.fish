for file in $HOME/.config/fish/functions.user.d/*.fish
    source $file
end

if status is-interactive
    for file in $HOME/.config/fish/conf.user.d/*.fish
        source $file
    end
end
