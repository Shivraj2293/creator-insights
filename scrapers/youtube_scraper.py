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
