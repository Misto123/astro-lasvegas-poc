# Astro Blog POC - lasvegas.com.ru Migration

## Deployment Instructions

### Automatic Deployment via Netlify

1. **Go to Netlify:** https://app.netlify.com/
2. **Click "Add new site" → "Import an existing project"**
3. **Connect to GitHub:** Select `Misto123/astro-lasvegas-poc`
4. **Build settings:**
   - Build command: `npm run build`
   - Publish directory: `dist`
   - Node version: `22`

5. **Environment variables** (add in Netlify dashboard):
   ```
   SUPABASE_URL=https://ppiumdjsoymgaodrkgga.supabase.co
   SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwaXVtZGpzb3ltZ2FvZHJrZ2dhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjMzNjU5MiwiZXhwIjoyMDc3OTEyNTkyfQ.QSTS4jiLZ2jcpRSEmh6pV-CGmaiPxvylr6jMoViFmB0
   DOMAIN_ID=a2115c98-be51-472d-9be9-2773d2457c7a
   ```

6. **Deploy!** Netlify will auto-build from GitHub

### Manual Deployment (Alternative)

If you prefer CLI:
```bash
npm install -g netlify-cli
netlify login
netlify init
netlify deploy --prod
```

### Custom Domain Setup

Once deployed:
1. Get Netlify URL (e.g., `astro-lasvegas-poc.netlify.app`)
2. Add custom domain: `new.lasvegas.com.ru` in Netlify dashboard
3. Update DNS:
   ```
   CNAME new.lasvegas.com.ru → <netlify-subdomain>.netlify.app
   ```

### Webhook for Auto-Rebuild

After deployment, create a build hook:
1. Netlify dashboard → Site settings → Build & deploy → Build hooks
2. Create hook: "Rebuild on new posts"
3. Copy webhook URL
4. Use this URL to trigger rebuilds when new blog posts are published

---

**Repository:** https://github.com/Misto123/astro-lasvegas-poc
