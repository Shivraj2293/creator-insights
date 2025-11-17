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
