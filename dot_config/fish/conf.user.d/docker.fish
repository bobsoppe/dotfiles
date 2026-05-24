# Avoids "no matching manifest" warnings pulling x86 images on Apple Silicon.
set --export DOCKER_DEFAULT_PLATFORM "linux/amd64"
