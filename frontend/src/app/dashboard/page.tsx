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
