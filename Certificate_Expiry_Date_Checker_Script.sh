#!/bin/bash

# Check if the website parameter is passed
if [ -z "$1" ]; then
    echo "Usage: $0 <website>"
    exit 1
fi

# The website to check, passed as an argument
WEBSITE="$1"

# Function to retrieve and display the SSL/TLS certificate expiry date
check_expiry() {
    # Make an HTTPS request to the website to retrieve the SSL/TLS certificate information
    echo | openssl s_client -connect ${WEBSITE}:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d'=' -f2
}

# Main script execution starts here
expiry_date=$(check_expiry)

# If expiry date is retrieved, display it; otherwise, show an error message
if [[ ! -z "$expiry_date" ]]; then
    echo "The SSL/TLS certificate for ${WEBSITE} expires on: $expiry_date"
else
    echo "Error: Could not retrieve or parse the certificate for ${WEBSITE}."
fi
