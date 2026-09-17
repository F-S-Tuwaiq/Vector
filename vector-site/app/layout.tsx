import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = {
  title: 'Vector — From Vision to Victory',
  description: 'Different strengths. One shared direction. Meet Sham and Fatimah, discover the story behind Vector, and explore the project.',
  icons: { icon: '/assets/vector-mark.png' },
};
export default function RootLayout({children}: {children: React.ReactNode}) {
  return <html lang="en"><body>{children}</body></html>;
}
