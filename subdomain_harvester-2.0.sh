#!/bin/bash

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: subdomain_harvester-2.0.sh <domain>"
    exit 1
fi

domain_name=$(echo "$1" | sed 's/\.com$//')

# Create directories if they don't exist
mkdir -p "$domain_name/recon"

# Harvest subdomains with assetfinder
echo "[+] Harvesting subdomains with assetfinder..."
assetfinder "$1" >> "$domain_name/recon/assets.txt"

# Harvest subdomains with Amass
echo "[+] Harvesting subdomains with Amass..."
echo "[+] Amass took too long to complete."
timeout 300 amass enum -d "$1" >> "$domain_name/recon/assets.txt"

# Harvest subdomains with Sublist3r
echo "[+] Harvesting subdomains with Sublist3r..."
sublist3r -d "$1" >> "$domain_name/recon/assets.txt"

# Harvest subdomains with Subfinder
echo "[+] Harvesting subdomains with Subfinder..."
subfinder -d "$1" >> "$domain_name/recon/assets.txt"

# Run MassDNS to resolve discovered subdomains
echo "[+] Resolving discovered subdomains with MassDNS..."
massdns -r ~/tools/massdns/lists/resolvers.txt -t A -o S -w "$domain_name/recon/massdns.txt" "$domain_name/recon/assets.txt"

# Filter and store unique subdomains
sort -u "$domain_name/recon/assets.txt" >> "$domain_name/recon/${domain_name}-sub-domains.txt"

# Check for possible subdomain takeover
echo "[+] Checking for possible subdomain takeover..."
subjack -w "$domain_name/recon/${domain_name}-sub-domains.txt" -t 100 -timeout 30 -ssl -c ~/tools/subjack/fingerprints.json -v -o "$domain_name/recon/subdomain_takeover.txt"

# Scan for open ports
echo "[+] Scanning for open ports..."
nmap -iL "$domain_name/recon/${domain_name}-sub-domains.txt" -T4 -oA "$domain_name/recon/nmap_scan"

# Scraping Wayback Machine data
echo "[+] Scraping Wayback Machine data..."
cat "$domain_name/recon/${domain_name}-sub-domains.txt" | waybackurls >> "$domain_name/recon/wayback_data.txt"

# Pulling and compiling all possible params found in Wayback data
echo "[+] Pulling and compiling all possible params found in Wayback data..."
cat "$domain_name/recon/wayback_data.txt" | grep -Eo '(http|https)://[^/"]+/?' | sort -u | while read line; do parameth -u "$line" -o "$domain_name/recon/wayback_params"; done

# Pulling and compiling js/php/aspx/jsp/json files from Wayback output
echo "[+] Pulling and compiling js/php/aspx/jsp/json files from Wayback output..."
cat "$domain_name/recon/wayback_data.txt" | grep -E "\.js|\.php|\.aspx|\.jsp|\.json" | sort -u >> "$domain_name/recon/wayback_files.txt"

echo "[+] Subdomains saved to $domain_name/recon/${domain_name}-sub-domains.txt"
echo "[+] Possible subdomain takeover saved to $domain_name/recon/subdomain_takeover.txt"
echo "[+] Nmap scan results saved to $domain_name/recon/nmap_scan"
echo "[+] Wayback Machine data saved to $domain_name/recon/wayback_data.txt"
echo "[+] Wayback params saved to $domain_name/recon/wayback_params"
echo "[+] Wayback files saved to $domain_name/recon/wayback_files.txt"
