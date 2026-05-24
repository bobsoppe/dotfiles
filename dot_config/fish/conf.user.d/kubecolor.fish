# Transparently swap kubectl with kubecolor while preserving kubectl tab-completion.
function kubecolor --wraps kubectl
    command kubecolor $argv
end

function kubectl --wraps kubectl
    command kubecolor $argv
end

function k --wraps kubectl
    command kubecolor $argv
end
