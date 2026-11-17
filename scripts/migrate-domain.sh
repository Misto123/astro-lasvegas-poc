#!/bin/bash

# Astro Blog Migration Automation Script
# Migrates AI blog domains from React SPA to Astro SSG

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="/Users/northsea/ClaudeProjects"
SUPABASE_URL="https://ppiumdjsoymgaodrkgga.supabase.co"

source "$HOME/.config/opencode/supabase/.env.keys"
SUPABASE_KEY="$SUPABASE_KEY_ppiumdjsoymgaodrkgga"

echo "==================================="
echo "Astro Blog Migration Script"
echo "==================================="
echo ""

# Function to get domain info
get_domain_info() {
  local domain=$1
  curl -sS --max-time 30 \
    "$SUPABASE_URL/rest/v1/domainblog_domains?select=id,url,name&url=eq.$domain" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY"
}

# Function to create Astro project for a domain
create_astro_project() {
  local domain=$1
  local domain_id=$2
  local project_name=$(echo "$domain" | sed 's/\./-/g')
  local project_dir="$BASE_DIR/astro-$project_name"
  
  echo "Creating Astro project for $domain..."
  
  # Copy template
  cp -r "$BASE_DIR/astro-blog-poc" "$project_dir"
  cd "$project_dir"
  
  # Update .env
  cat > .env << EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_KEY=$SUPABASE_KEY
DOMAIN_ID=$domain_id
EOF
  
  # Update astro.config.mjs
  sed -i '' "s|site: 'https://lasvegas.com.ru'|site: 'https://$domain'|g" astro.config.mjs
  
  # Update sitemap.xml.ts
  sed -i '' "s|lasvegas.com.ru|$domain|g" src/pages/sitemap.xml.ts
  
  # Update robots.txt
  sed -i '' "s|lasvegas.com.ru|$domain|g" public/robots.txt
  
  echo "✅ Project created at: $project_dir"
}

# Function to build site
build_site() {
  local project_dir=$1
  
  echo "Building site..."
  cd "$project_dir"
  npm run build 2>&1 | tail -10
  
  if [ -d "dist" ]; then
    echo "✅ Build successful"
    ls -lh dist/ | head -5
  else
    echo "❌ Build failed"
    exit 1
  fi
}

# Function to deploy to Netlify via GitHub
deploy_to_netlify() {
  local project_dir=$1
  local domain=$2
  local project_name=$(echo "$domain" | sed 's/\./-/g')
  
  echo "Deploying to GitHub + Netlify..."
  cd "$project_dir"
  
  # Initialize git
  git init
  git add .
  git commit -m "Astro migration for $domain"
  
  # Create GitHub repo
  gh repo create "astro-$project_name" --public --source=. --remote=origin --push
  
  echo "✅ Pushed to GitHub: https://github.com/Misto123/astro-$project_name"
  echo ""
  echo "📋 Next steps:"
  echo "1. Go to: https://app.netlify.com/"
  echo "2. Import: Misto123/astro-$project_name"
  echo "3. Set env vars (SUPABASE_URL, SUPABASE_KEY, DOMAIN_ID)"
  echo "4. Deploy!"
}

# Main function
migrate_domain() {
  local domain=$1
  
  echo "=========================================="
  echo "Migrating: $domain"
  echo "=========================================="
  echo ""
  
  # Get domain info
  echo "Fetching domain info..."
  DOMAIN_DATA=$(get_domain_info "$domain")
  DOMAIN_ID=$(echo "$DOMAIN_DATA" | jq -r '.[0].id')
  
  if [ "$DOMAIN_ID" == "null" ] || [ -z "$DOMAIN_ID" ]; then
    echo "❌ Domain not found: $domain"
    exit 1
  fi
  
  echo "Domain ID: $DOMAIN_ID"
  echo ""
  
  # Create project
  create_astro_project "$domain" "$DOMAIN_ID"
  
  # Build
  local project_name=$(echo "$domain" | sed 's/\./-/g')
  local project_dir="$BASE_DIR/astro-$project_name"
  build_site "$project_dir"
  
  # Deploy
  deploy_to_netlify "$project_dir" "$domain"
  
  echo ""
  echo "✅ Migration complete for $domain"
}

# Batch migration function
migrate_batch() {
  local domains_file=$1
  
  if [ ! -f "$domains_file" ]; then
    echo "❌ File not found: $domains_file"
    exit 1
  fi
  
  while IFS= read -r domain; do
    # Skip empty lines and comments
    [[ -z "$domain" ]] && continue
    [[ "$domain" =~ ^#.* ]] && continue
    
    migrate_domain "$domain"
    echo ""
    echo "Waiting 5 seconds before next migration..."
    sleep 5
  done < "$domains_file"
}

# Usage
show_usage() {
  cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
  single <domain>       Migrate a single domain
  batch <file>          Migrate multiple domains from file
  help                  Show this help

Examples:
  $0 single lasvegas.com.ru
  $0 batch domains.txt

domains.txt format:
  lasvegas.com.ru
  martenspangberg.org
  techblog.nl
  # comments are ignored
EOF
}

# Parse arguments
case "${1:-}" in
  single)
    if [ -z "${2:-}" ]; then
      echo "❌ Domain required"
      show_usage
      exit 1
    fi
    migrate_domain "$2"
    ;;
  batch)
    if [ -z "${2:-}" ]; then
      echo "❌ File required"
      show_usage
      exit 1
    fi
    migrate_batch "$2"
    ;;
  help|--help|-h)
    show_usage
    ;;
  *)
    echo "❌ Invalid command"
    show_usage
    exit 1
    ;;
esac
