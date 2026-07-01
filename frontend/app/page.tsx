'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function Home() {
  const [gamepadConnected, setGamepadConnected] = useState(false);

  useEffect(() => {
    const handleGamepadConnect = () => setGamepadConnected(true);
    const handleGamepadDisconnect = () => setGamepadConnected(false);

    window.addEventListener('gamepadconnected', handleGamepadConnect);
    window.addEventListener('gamepaddisconnected', handleGamepadDisconnect);

    return () => {
      window.removeEventListener('gamepadconnected', handleGamepadConnect);
      window.removeEventListener('gamepaddisconnected', handleGamepadDisconnect);
    };
  }, []);

  return (
    <main className="min-h-screen bg-render-dark">
      {/* Navigation */}
      <nav className="border-b border-render-gray-light bg-render-gray">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="text-2xl font-bold text-render-red">🔴 RENDER</div>
          <div className="flex gap-4">
            <Link href="/login" className="px-4 py-2 text-white hover:text-render-red transition">
              Login
            </Link>
            <Link href="/signup" className="px-4 py-2 bg-render-red text-white rounded hover:bg-render-red-dark transition">
              Sign Up
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="h-screen flex items-center justify-center bg-gradient-to-br from-render-dark to-render-gray">
        <div className="text-center px-4">
          <div className="mb-8 animate-pulse-glow">
            <div className="text-7xl font-bold text-render-red mb-4">🔴 RENDER</div>
          </div>
          <h1 className="text-5xl md:text-6xl font-bold text-white mb-4">
            The Future of Video Streaming
          </h1>
          <p className="text-xl text-render-gray-light mb-8 max-w-2xl mx-auto">
            Experience gamified streaming with AI-powered content protection, creator rewards, and console gamepad support.
          </p>
          
          {/* Gamepad Status */}
          <div className="mb-8 flex items-center justify-center gap-2">
            <div className={`w-3 h-3 rounded-full ${gamepadConnected ? 'bg-green-500 animate-pulse' : 'bg-gray-600'}`}></div>
            <span className="text-sm">
              {gamepadConnected ? '🎮 Gamepad Connected' : '🎮 Connect a Gamepad'}
            </span>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/watch" className="gamepad-focus px-8 py-3 bg-render-red text-white rounded-lg font-semibold hover:bg-render-red-dark transition">
              Start Watching
            </Link>
            <Link href="/creator" className="gamepad-focus px-8 py-3 border border-render-red text-render-red rounded-lg font-semibold hover:bg-render-red hover:text-white transition">
              Creator Dashboard
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-render-dark">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-4xl font-bold text-center mb-12 text-white">Core Features</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              { title: '📺 Live Streaming', desc: 'Ultra-low latency RTMP live streams' },
              { title: '🔒 Copyright Shield', desc: 'Ash AI pre-upload scanning - Zero-Strike Policy' },
              { title: '💰 Creator Revenue', desc: '90% creator / 10% platform split via Stripe' },
              { title: '🎮 Viewer Leagues', desc: '50-person gamified brackets with rewards' },
              { title: '⭐ Premium Pass', desc: 'Ad-free streaming + arcade games' },
              { title: '🛡️ Admin Tools', desc: 'Moderation dashboard for spam detection' },
            ].map((feature, i) => (
              <div key={i} className="gamepad-focus p-6 bg-render-gray rounded-lg border border-render-gray-light hover:border-render-red transition">
                <h3 className="text-xl font-semibold mb-2 text-render-red">{feature.title}</h3>
                <p className="text-render-gray-light">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-render-gray border-t border-render-gray-light py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-render-gray-light">
          <p>© 2024 RENDER. All rights reserved. | High-performance video streaming platform</p>
        </div>
      </footer>
    </main>
  );
}
