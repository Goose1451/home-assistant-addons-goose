#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: ledfx
# Configures NGINX
# ==============================================================================
declare admin_port

admin_port=$(bashio::addon.port 80)

# Generate Ingress configuration
bashio::var.json \
    interface "$(bashio::addon.ip_address)" \
    port "^$(bashio::addon.ingress_port)" \
    | tempio \
        -template /etc/nginx/templates/ingress.gtpl \
        -out /etc/nginx/servers/ingress.conf

# Generate direct access configuration, if enabled.
# if bashio::var.has_value "$(bashio::addon.port 80)"; then
if bashio::var.has_value "${admin_port}"; then
    bashio::config.require.ssl
    bashio::var.json \
        certfile "$(bashio::config 'certfile')" \
        keyfile "$(bashio::config 'keyfile')" \
        leave_front_door_open "^$(bashio::config 'leave_front_door_open')" \
        # port "^$(bashio::addon.port 80)" \
        ssl "^$(bashio::config 'ssl')" \
        | tempio \
            -template /etc/nginx/templates/direct.gtpl \
            -out /etc/nginx/servers/direct.conf
fi