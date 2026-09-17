'use client';

import { ArrowUpRight, Globe2, Play, BookOpen, Code2, ContactRound } from 'lucide-react';
import { Button } from '@/components/ui/button';

// Add the published app and demo URLs here when they are ready.
const links = [
  { title: 'Open the web app', detail: 'Find your people. Build your team.', icon: Globe2, href: '', status: 'Link coming soon', primary: true },
  { title: 'Watch the demo', detail: 'A little look inside Vector.', icon: Play, href: '', status: 'Video coming soon' },
  { title: 'Read our README', detail: 'The idea, the features, the details.', icon: BookOpen, href: 'https://github.com/F-S-Tuwaiq/Vector#readme' },
  { title: 'Explore the GitHub', detail: 'See how we brought it to life.', icon: Code2, href: 'https://github.com/F-S-Tuwaiq/Vector' },
  { title: 'Sham Albinni', detail: 'Connect on LinkedIn', icon: ContactRound, href: 'https://www.linkedin.com/in/sham-albinni-611782371/' },
  { title: 'Fatimah Bin Mohammed', detail: 'Connect on LinkedIn', icon: ContactRound, href: 'https://www.linkedin.com/in/fatimah-bin-mohammed-321552325/' },
];

function Wordmark({ footer = false }: { footer?: boolean }) {
  return <div className={`wordmark${footer ? ' footer-wordmark' : ''}`} role="img" aria-label="Vector">
    <span className="mark"><img src="/assets/vector-mark.png" alt="" /></span>
    <span aria-hidden="true">ector</span>
  </div>;
}

export default function Home() {
  return (
    <main>
      <header className="masthead">
        <div className="masthead-inner">
          <span className="eyebrow">A shared vision. A shared direction.</span>
          <Wordmark />
          <div className="brand-bottom"><p>From Vision to Victory.</p><span className="edition">Made at Tuwaiq Academy</span></div>
        </div>
        <span className="triangle triangle-one" aria-hidden="true" /><span className="triangle triangle-two" aria-hidden="true" />
      </header>

      <div className="content">
        <section className="story" aria-labelledby="story-heading">
          <div className="story-heading"><span className="eyebrow">OUR STORY</span><h1 id="story-heading">Different strengths.<br /><em>One shared direction.</em></h1></div>
          <div className="story-copy">
            <p>We’re Sham and Fatimah. We met at the Tuwaiq Flutter &amp; Dart bootcamp—two students from different universities, bringing computer science and information technology into the same conversation.</p>
            <p>Vector grew from a simple idea: ambition is only the beginning. Finding people whose skills complement yours gives it direction. So we built a place to discover hackathons, find your team, and turn “I’d love to join” into “we’re building this together.”</p>
          </div>
        </section>

        <section className="destinations" aria-labelledby="links-heading">
          <div className="section-heading"><h2 id="links-heading">A little more Vector.</h2><span className="section-rule" /></div>
          <div className="link-grid">
            {links.map(({title, detail, icon: Icon, href, status, primary}, index) => {
              const content = <><span className="link-icon"><Icon strokeWidth={1.5} size={24} /></span><span className="link-copy"><span className="link-title">{title}</span><span className="link-detail">{detail}</span>{status && <span className="status">{status}</span>}</span><span className="link-end">{href ? <ArrowUpRight size={22} strokeWidth={1.5} /> : <span className="link-number">0{index + 1}</span>}</span></>;
              return href ? <a className="link-card" href={href} key={title} target="_blank" rel="noopener noreferrer" aria-label={`${title} (opens in a new tab)`}>{content}</a> : <Button disabled key={title} className={`link-card pending ${primary ? 'primary' : ''}`}>{content}</Button>;
            })}
          </div>
        </section>
        <footer><Wordmark footer /><p>Built together. Made in Saudi Arabia.</p><span className="footer-note">© 2026 Vector</span></footer>
      </div>
    </main>
  );
}
