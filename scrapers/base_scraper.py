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
