export async function getTrendingAudio(niche?: string) {
  const base = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";
  const url = new URL(base + "/v1/trends/audio");
  if (niche) url.searchParams.set("niche", niche);
  const res = await fetch(url.toString(), { credentials: "include" });
  if (!res.ok) throw new Error("Failed to fetch audio");
  return res.json();
}
