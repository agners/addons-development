#!/usr/bin/with-contenv bash
# ==============================================================================
# Generate Silicon Labs Multiprotocol configurations
# ==============================================================================

echo "Generating cpcd configuration."

echo "{ \"device\": \"${CPCD_DEVICE}\", \"cpcd_trace\": \"${CPCD_TRACE}\" }" \
    | tempio \
        -template /usr/local/share/cpcd.conf \
        -out /usr/local/etc/cpcd.conf
