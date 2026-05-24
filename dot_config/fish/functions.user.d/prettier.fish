# Prettier wrapped via npx with pinned plugins — ensures consistent
# formatting across XML, Groovy, Java, ini, sh, sql, and toml files
# regardless of project-local prettier installs.

function prettier
    npx \
        --yes \
        --package prettier@3.5.3 \
        --package prettier-pnp \
        prettier-pnp \
            --quiet \
            --pnp @prettier/plugin-xml \
            --pnp prettier-plugin-groovy  \
            --pnp prettier-plugin-java \
            --pnp prettier-plugin-ini \
            --pnp prettier-plugin-sh \
            --pnp prettier-plugin-sql \
            --pnp prettier-plugin-toml \
            $argv
end
