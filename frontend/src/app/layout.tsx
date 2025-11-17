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
