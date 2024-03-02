#!/bin/bash

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: subdomain_harvester.sh <domain>"
    exit 1
fi

# Remove ".com" from the domain name if present
domain_name=$(echo "$1" | sed 's/\.com$//')

# Create directories if they don't exist
if [ ! -d "$domain_name" ]; then
    mkdir "$domain_name"
fi

if [ ! -d "$domain_name/recon" ]; then
    mkdir "$domain_name/recon"
fi

# Harvest subdomains with assetfinder
echo "[+] Harvesting subdomains with assetfinder..."
assetfinder "$1" >> "$domain_name/recon/assets.txt"

# Filter and store unique subdomains
sort -u "$domain_name/recon/assets.txt" | grep "$1" > "$domain_name/recon/$domain_name-sub-domains.txt"

# Clean up temporary files
rm "$domain_name/recon/assets.txt"

echo "[+] Subdomains saved to $domain_name/recon/$domain_name-sub-domains.txt"