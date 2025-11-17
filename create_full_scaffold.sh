#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
echo "Creating project scaffold in: $ROOT_DIR"

# FRONTEND (Next.js + Tailwind)
mkdir -p frontend/public frontend/src/app/{login,signup,dashboard,trending-audio,trending-hashtags,niche,alerts,settings} frontend/src/{components/ui,components/charts,components/cards,components/navbar,hooks,lib,styles}
cat > frontend/package.json <<'EOF'
{
  "name": "creator-insights-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "15.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "tailwindcss": "^3.5.0",
    "clsx": "^1.2.1",
    "swr": "^2.2.0",
    "recharts": "^2.5.0"
  },
  "devDependencies": {
    "eslint": "8.43.0",
    "eslint-config-next": "13.4.10",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24"
  }
}
EOF

cat > frontend/next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: true },
}
module.exports = nextConfig
EOF

cat > frontend/tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
EOF

cat > frontend/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["DOM", "ES2020"],
    "jsx": "preserve",
    "strict": true,
    "moduleResolution": "Node",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"]
}
EOF

cat > frontend/src/styles/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

html, body, #__next { height: 100%; }
body { @apply bg-slate-50 text-slate-800; }
EOF

# Next.js App files (basic)
cat > frontend/src/app/layout.tsx <<'EOF'
import './globals.css'
import React from "react";

export const metadata = {
  title: "Creator Insights",
  description: "Trending audio & hashtag insights",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <main className="min-h-screen">
          {children}
        </main>
      </body>
    </html>
  );
}
EOF

cat > frontend/src/app/page.tsx <<'EOF'
import React from "react";
import Link from "next/link";

export default function Home() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-4">Creator Insights — Frontend</h1>
      <p className="mb-4">Open <Link href="/login" className="text-blue-600">Login</Link> or <Link href="/dashboard" className="text-blue-600">Dashboard</Link>.</p>
    </div>
  );
}
EOF

cat > frontend/src/app/login/page.tsx <<'EOF'
"use client"
import React, { useState } from "react";
import useAuth from "../../hooks/useAuth";

export default function LoginPage() {
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    await login(email, password);
  }

  return (
    <div className="max-w-md mx-auto p-6 mt-20 bg-white rounded shadow">
      <h2 className="text-xl font-semibold mb-4">Login</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="Email" className="w-full border p-2 rounded"/>
        <input value={password} onChange={e=>setPassword(e.target.value)} type="password" placeholder="Password" className="w-full border p-2 rounded"/>
        <button className="w-full bg-blue-600 text-white p-2 rounded">Login</button>
      </form>
    </div>
  );
}
EOF

cat > frontend/src/app/dashboard/page.tsx <<'EOF'
import React from "react";
import Link from "next/link";

export default function Dashboard() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <div className="grid grid-cols-2 gap-4">
        <div className="p-4 bg-white rounded shadow">Trending Audio</div>
        <div className="p-4 bg-white rounded shadow">Trending Hashtags</div>
      </div>
      <div className="mt-6">
        <Link href="/trending-audio" className="text-blue-600">Open Trending Audio</Link>
      </div>
    </div>
  );
}
EOF

cat > frontend/src/hooks/useAuth.ts <<'EOF'
"use client"
import { useRouter } from "next/navigation";

export default function useAuth() {
  const router = useRouter();

  async function login(email: string, password: string) {
    // call backend /auth/login
    try {
      await fetch(process.env.NEXT_PUBLIC_API_BASE + "/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ email, password }),
      });
      router.push("/dashboard");
    } catch (e) {
      console.error(e);
      alert("Login failed");
    }
  }

  function logout() {
    document.cookie = "access=; Max-Age=0; path=/;"; // backend must clear
    router.push("/login");
  }

  return { login, logout };
}
EOF

cat > frontend/src/lib/api.ts <<'EOF'
export async function getTrendingAudio(niche?: string) {
  const base = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";
  const url = new URL(base + "/v1/trends/audio");
  if (niche) url.searchParams.set("niche", niche);
  const res = await fetch(url.toString(), { credentials: "include" });
  if (!res.ok) throw new Error("Failed to fetch audio");
  return res.json();
}
EOF

# Basic UI component
cat > frontend/src/components/ui/Card.tsx <<'EOF'
import React from "react";
export default function Card({ children }: { children: React.ReactNode }) {
  return <div className="bg-white p-4 rounded shadow">{children}</div>;
}
EOF

# FRONTEND README
cat > frontend/README.md <<'EOF'
# Frontend (Next.js 15 + Tailwind)
Commands:
- Install deps: npm install
- Dev: npm run dev
Environment:
- NEXT_PUBLIC_API_BASE (e.g. http://localhost:8000)
EOF

# SCRAPERS (Playwright)
mkdir -p scrapers/extractors scrapers/utils
cat > scrapers/requirements.txt <<'EOF'
playwright>=1.40
httpx
pydantic
python-dotenv
tenacity
EOF

cat > scrapers/base_scraper.py <<'EOF'
from playwright.async_api import async_playwright
import asyncio
from typing import AsyncGenerator
from pydantic import BaseModel

class ScrapedPost(BaseModel):
    platform: str
    post_id: str
    url: str
    caption: str | None = None
    hashtags: list[str] = []
    audio: str | None = None
    views: int | None = None
    likes: int | None = None
    comments: int | None = None
    upload_date: str | None = None

class BaseScraper:
    def __init__(self, headless: bool = True):
        self._headless = headless

    async def _launch(self):
        self._pw = await async_playwright().__aenter__()
        self._browser = await self._pw.chromium.launch(headless=self._headless)
        self._context = await self._browser.new_context()
        self._page = await self._context.new_page()

    async def close(self):
        await self._page.close()
        await self._context.close()
        await self._browser.close()
        await self._pw.__aexit__(None, None, None)

    async def scrape_recent(self, niche: str, limit: int = 20) -> list[ScrapedPost]:
        raise NotImplementedError("Implement in platform scraper")
EOF

cat > scrapers/youtube_scraper.py <<'EOF'
from .base_scraper import BaseScraper, ScrapedPost
from typing import List
import asyncio
import re

class YouTubeShortsScraper(BaseScraper):
    async def scrape_recent(self, niche: str, limit: int = 20) -> List[ScrapedPost]:
        await self._launch()
        posts = []
        # placeholder: implement search by niche / hashtag
        search_url = f"https://www.youtube.com/results?search_query={niche}+shorts"
        await self._page.goto(search_url)
        # naive collect: this is scaffold — replace selectors in production
        anchors = await self._page.query_selector_all("a#thumbnail")
        for a in anchors[:limit]:
            href = await a.get_attribute("href") or ""
            match = re.search(r"v=([^&]+)", href)
            post_id = match.group(1) if match else href
            url = "https://www.youtube.com" + href
            posts.append(ScrapedPost(platform="youtube", post_id=post_id, url=url))
        await self.close()
        return posts
EOF

cat > scrapers/instagram_scraper.py <<'EOF'
from .base_scraper import BaseScraper, ScrapedPost
from typing import List
import asyncio

class InstagramReelsScraper(BaseScraper):
    async def scrape_recent(self, niche: str, limit: int = 20) -> List[ScrapedPost]:
        await self._launch()
        posts = []
        # NOTE: Instagram heavily rate-limits and requires auth/proxies.
        search_url = f"https://www.instagram.com/explore/tags/{niche}/"
        await self._page.goto(search_url, timeout=60000)
        # This is scaffold; implement selectors with real CSS paths
        reels = await self._page.query_selector_all("article a")
        for r in reels[:limit]:
            href = await r.get_attribute("href")
            posts.append(ScrapedPost(platform="instagram", post_id=href or "", url="https://instagram.com" + (href or "")))
        await self.close()
        return posts
EOF

cat > scrapers/facebook_scraper.py <<'EOF'
from .base_scraper import BaseScraper, ScrapedPost
from typing import List
import asyncio

class FacebookReelsScraper(BaseScraper):
    async def scrape_recent(self, niche: str, limit: int = 20) -> List[ScrapedPost]:
        await self._launch()
        posts = []
        # scaffold: Facebook requires login & careful handling
        # For now just return empty list
        await self.close()
        return posts
EOF

cat > scrapers/extractors/hashtag_extractor.py <<'EOF'
import re
from typing import List

def extract_hashtags(text: str) -> List[str]:
    if not text:
        return []
    tags = re.findall(r"#([\\w\\-]+)", text)
    return [t.lower() for t in tags]
EOF

cat > scrapers/utils/retry.py <<'EOF'
from tenacity import retry, wait_exponential, stop_after_attempt

def retry_decorator():
    return retry(wait=wait_exponential(multiplier=1, min=2, max=10), stop=stop_after_attempt(3))
EOF

cat > scrapers/README.md <<'EOF'
# Scrapers (Playwright)
- Use Python virtualenv and install scrapers/requirements.txt
- To install Playwright browsers: python -m playwright install
- These are scaffold files. Implement real selectors, proxies, and login flows.
EOF

# ML (embedding + niche classifier + tag ranker + audio trend)
mkdir -p ml/embeddings ml/niche ml/audio ml/hashtags ml/analytics ml/models
cat > ml/requirements.txt <<'EOF'
sentence-transformers>=2.2.2
numpy
scipy
scikit-learn
pandas
tslearn
EOF

cat > ml/embeddings/embedder.py <<'EOF'
from sentence_transformers import SentenceTransformer
import numpy as np

class Embedder:
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        self.model = SentenceTransformer(model_name)

    def embed(self, texts):
        if isinstance(texts, str):
            texts = [texts]
        embeddings = self.model.encode(texts, convert_to_numpy=True)
        return embeddings
EOF

cat > ml/niche/classifier.py <<'EOF'
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from ..embeddings.embedder import Embedder
import json
from pathlib import Path

LABELS_PATH = Path(__file__).resolve().parent / "labels.json"

class NicheClassifier:
    def __init__(self, label_file: str | None = None):
        self.embedder = Embedder()
        self.labels = self._load_labels(label_file)

    def _load_labels(self, label_file):
        p = Path(label_file) if label_file else LABELS_PATH
        if p.exists():
            return json.loads(p.read_text())
        return ["music", "dance", "comedy", "fitness", "beauty", "gaming", "food"]

    def predict(self, text: str):
        text_emb = self.embedder.embed(text)
        label_embs = self.embedder.embed(self.labels)
        sims = cosine_similarity(text_emb.reshape(1, -1), label_embs)
        idx = int(np.argmax(sims))
        return {"label": self.labels[idx], "confidence": float(sims[0, idx])}
EOF

cat > ml/niche/labels.json <<'EOF'
["music","dance","comedy","fitness","beauty","gaming","food","tech","finance"]
EOF

cat > ml/hashtags/tag_ranker.py <<'EOF'
from collections import Counter
import math
from typing import List, Dict

def score_hashtags(history: List[Dict]) -> Dict[str, float]:
    """
    history: list of { 'tag': 'x', 'count': int, 'engagement': float, 'timestamp': 'ISO' }
    returns tag -> score
    """
    agg = {}
    for item in history:
        t = item['tag']
        agg.setdefault(t, {'count':0, 'eng':0.0})
        agg[t]['count'] += item.get('count', 1)
        agg[t]['eng'] += item.get('engagement', 0.0)

    scores = {}
    for k,v in agg.items():
        # simple scoring: engagement weighted by sqrt(count)
        scores[k] = v['eng'] * math.sqrt(v['count'] + 1)
    return scores
EOF

cat > ml/audio/audio_trend.py <<'EOF'
import numpy as np
from scipy.stats import linregress
from typing import List

def velocity(times: List[float], counts: List[float]) -> float:
    # times: timestamps in seconds
    if len(times) < 2:
        return 0.0
    slope, _, _, _, _ = linregress(times, counts)
    return float(slope)
EOF

cat > ml/README.md <<'EOF'
# ML Scaffold
- Install ml/requirements.txt into a python venv
- Provides:
  - embeddings/embedder.py (sentence-transformers wrapper)
  - niche/classifier.py (label matching)
  - hashtags/tag_ranker.py
  - audio/audio_trend.py
EOF

# NOTIFICATIONS
mkdir -p notifications/email/notifications/templates notifications/sms notifications/whatsapp notifications/utils
cat > notifications/requirements.txt <<'EOF'
jinja2
python-dotenv
requests
twilio
EOF

cat > notifications/email/send_email.py <<'EOF'
import smtplib
from email.message import EmailMessage
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
import os

TEMPLATES_DIR = Path(__file__).resolve().parent / "templates"

def send_email_smtp(to_email: str, subject: str, template_name: str, context: dict, smtp_url=None):
    smtp_host = os.environ.get("SMTP_HOST", "localhost")
    smtp_port = int(os.environ.get("SMTP_PORT", "25"))
    from_email = os.environ.get("SMTP_FROM", "no-reply@creatorinsights.local")

    env = Environment(loader=FileSystemLoader(str(TEMPLATES_DIR)))
    template = env.get_template(template_name)
    html = template.render(**context)

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email
    msg.set_content(html, subtype="html")

    with smtplib.SMTP(smtp_host, smtp_port) as s:
        s.send_message(msg)
EOF

cat > notifications/email/templates/weekly_report.html <<'EOF'
<html><body><h1>Weekly Trends</h1><p>Hey — here are your weekly trends.</p></body></html>
EOF

cat > notifications/sms/send_sms.py <<'EOF'
import os
from twilio.rest import Client

def send_sms(to_number: str, body: str):
    acc = os.environ.get("TWILIO_ACCOUNT_SID")
    token = os.environ.get("TWILIO_AUTH_TOKEN")
    from_num = os.environ.get("TWILIO_FROM")
    if not acc or not token:
        raise RuntimeError("Twilio creds missing")
    client = Client(acc, token)
    msg = client.messages.create(body=body, from_=from_num, to=to_number)
    return msg.sid
EOF

cat > notifications/whatsapp/send_whatsapp.py <<'EOF'
import os
from twilio.rest import Client

def send_whatsapp(to_number: str, body: str):
    acc = os.environ.get("TWILIO_ACCOUNT_SID")
    token = os.environ.get("TWILIO_AUTH_TOKEN")
    from_num = os.environ.get("TWILIO_WHATSAPP_FROM")  # e.g. 'whatsapp:+1415...'
    client = Client(acc, token)
    msg = client.messages.create(body=body, from_=from_num, to=f"whatsapp:{to_number}")
    return msg.sid
EOF

cat > notifications/README.md <<'EOF'
# Notifications
- Email via SMTP (send_email.send_email_smtp)
- SMS & WhatsApp via Twilio (send_sms, send_whatsapp)
- Configure environment variables: SMTP_HOST, SMTP_PORT, SMTP_FROM, TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM, TWILIO_WHATSAPP_FROM
EOF

# INFRA (nginx, systemd, docker)
mkdir -p infra/nginx infra/systemd infra/docker infra/github-actions infra/monitoring
cat > infra/nginx/creator.conf <<'EOF'
server {
    listen 80;
    server_name creatorinsights.example.com;

    location / {
        proxy_pass http://127.0.0.1:3000; # frontend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/; # backend
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /static/ {
        alias /var/www/creator-insights/frontend/.next/static/;
    }
}
EOF

cat > infra/systemd/creator-frontend.service <<'EOF'
[Unit]
Description=Creator Insights Frontend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/creator-insights/frontend
ExecStart=/usr/bin/npm run start
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

cat > infra/systemd/creator-scraper.service <<'EOF'
[Unit]
Description=Creator Insights Scraper Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/creator-insights
ExecStart=/usr/bin/python3 scrapers/run_worker.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat > infra/docker/frontend.Dockerfile <<'EOF'
FROM node:18-alpine
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install
COPY frontend/ ./
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "start"]
EOF

cat > infra/docker/scraper.Dockerfile <<'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY scrapers/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
COPY scrapers/ /app/scrapers
CMD ["python3", "-c", "print('Use run_scrapers.py in scripts to run scrapers')"]
EOF

cat > infra/github-actions/frontend-ci.yml <<'EOF'
name: Frontend CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v5
        with:
          node-version: 18
      - name: Install and build
        run: |
          cd frontend
          npm ci
          npm run build
EOF

# SCRIPTS
mkdir -p scripts
cat > scripts/init_dev.sh <<'EOF'
#!/usr/bin/env bash
set -e
echo "Starting development helper..."
echo "1) Start backend (assumes backend venv activated & running on 8000)"
echo "2) Start frontend: cd frontend && npm install && npm run dev"
echo "3) Start scrapers (see README)"
EOF
chmod +x scripts/init_dev.sh

cat > scripts/run_scrapers.py <<'EOF'
#!/usr/bin/env python3
import asyncio
from scrapers.youtube_scraper import YouTubeShortsScraper
from scrapers.instagram_scraper import InstagramReelsScraper

async def main():
    y = YouTubeShortsScraper(headless=True)
    posts = await y.scrape_recent("music", limit=5)
    print("YouTube posts:", posts)
    i = InstagramReelsScraper(headless=True)
    ip = await i.scrape_recent("dance", limit=3)
    print("Instagram posts:", ip)

if __name__ == "__main__":
    asyncio.run(main())
EOF
chmod +x scripts/run_scrapers.py

cat > scripts/deploy.sh <<'EOF'
#!/usr/bin/env bash
set -e
# This is a deploy helper: expand per your infra
echo "Deploy steps (placeholder). Customize this script for your server."
EOF
chmod +x scripts/deploy.sh

# DOCS
mkdir -p docs
cat > docs/FRONTEND.md <<'EOF'
# Frontend docs
- Tech: Next.js 15 (App router), TailwindCSS
- Env: NEXT_PUBLIC_API_BASE
- Run locally:
  - cd frontend
  - npm install
  - npm run dev
EOF

cat > docs/SCRAPERS.md <<'EOF'
# Scrapers
- Implement selectors in scrapers/*.py
- Use proxies (proxy_manager) and playwight browsers
- Install Playwright browsers: python -m playwright install
EOF

cat > docs/ML.md <<'EOF'
# ML
- Embedder: sentence-transformers
- Use ml/embeddings/embedder.py and ml/niche/classifier.py
EOF

cat > docs/DEPLOYMENT.md <<'EOF'
# Deployment
- Use infra/nginx/creator.conf as Nginx site
- Example systemd units under infra/systemd
- Use Dockerfiles in infra/docker for container builds
EOF

# TOP-LEVEL README
cat > README.md <<'EOF'
# Creator Insights — Monorepo (frontend + scrapers + ml + infra)
This repo contains scaffold for the Creator Insights SaaS project, excluding backend (already present).

Run the scaffolding script to create:
- frontend/ (Next.js)
- scrapers/ (Playwright)
- ml/ (python modules)
- notifications/
- infra/
- scripts/
- docs/

Follow per-component README's for setup.
EOF

echo "Scaffold created successfully."

cat <<'EOF'

=== NEXT STEPS / QUICK START ===

# Frontend
cd frontend
npm install
# DEV
npm run dev
# Build
npm run build

# Python parts (scrapers, ml, notifications)
python3 -m venv .venv
source .venv/bin/activate
pip install -r scrapers/requirements.txt
pip install -r ml/requirements.txt
pip install -r notifications/requirements.txt
# Install Playwright browsers
python -m playwright install

# Run a simple scraper (scaffold)
python3 scripts/run_scrapers.py

EOF
