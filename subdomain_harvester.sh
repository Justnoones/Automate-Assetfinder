#!/bin/bash

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: subdomain_harvester.sh <domain>"
    exit 1
fi

domain_name=$(echo "$1" | sed 's/\.com$//')

# Create directories if they don't exist
mkdir -p "$domain_name/recon"

# Harvest subdomains with assetfinder
echo "[+] Harvesting subdomains with assetfinder..."
assetfinder "$1" >> "$domain_name/recon/assets.txt"

# Filter and store unique subdomains
sort -u "$domain_name/recon/assets.txt" | grep "$1" > "$domain_name/recon/${domain_name}-sub-domains.txt"

# Clean up temporary files
rm "$domain_name/recon/assets.txt"

# Filter alive https
echo "[+] Probing for alive domains..."
httprobe < "$domain_name/recon/${domain_name}-sub-domains.txt" | sed 's/https\?:\/\///; s/:443//' > "$domain_name/recon/alive_${domain_name}-sub-domains.txt"

echo "[+] Subdomains saved to $domain_name/recon/${domain_name}-sub-domains.txt"
echo "[+] Active Subdomains saved to $domain_name/recon/alive_${domain_name}-sub-domains.txt"
