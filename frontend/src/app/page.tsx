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
