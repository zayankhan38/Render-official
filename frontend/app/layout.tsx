import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'RENDER - Video Streaming Platform',
  description: 'A gamified, AI-powered video streaming platform with console gamepad support',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=1',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="bg-render-dark text-white">
        {children}
      </body>
    </html>
  );
}
