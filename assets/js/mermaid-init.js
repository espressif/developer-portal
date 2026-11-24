/*
  Loads Mermaid from CDN, renders every `.mermaid` block, and makes each
  diagram click-to-enlarge. The live SVG is moved into a lightbox so labels
  drawn with foreignObject stay intact. Opening and closing scale and slide
  the diagram the way figure zoom does.
*/

import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.esm.min.mjs';

mermaid.initialize({ startOnLoad: false });

try {
  await mermaid.run({ querySelector: '.mermaid', suppressErrors: true });
} catch (error) {
  console.error('Mermaid failed to render', error);
}

const ZOOM_MS = 300;
const ZOOM_EASE = 'cubic-bezier(0.2, 0, 0.2, 1)';
// Same inset figures use. The open diagram stays inside this margin.
const ZOOM_MARGIN = 24;

let phase = 'closed';
let generation = 0;
let session = null;

function prefersStill() {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function pose(centerX, centerY, scale, layoutW, layoutH) {
  const tx = centerX - layoutW / 2;
  const ty = centerY - layoutH / 2;
  return `translate(${tx}px, ${ty}px) scale(${scale})`;
}

// Natural size, or smaller so the whole diagram fits in the window.
function fitTransform(layoutW, layoutH) {
  const maxW = Math.max(0, window.innerWidth - ZOOM_MARGIN * 2);
  const maxH = Math.max(0, window.innerHeight - ZOOM_MARGIN * 2);
  const scale = Math.min(1, maxW / layoutW, maxH / layoutH);
  return pose(window.innerWidth / 2, window.innerHeight / 2, scale, layoutW, layoutH);
}

function intrinsicWidth(svg) {
  const box = svg.viewBox && svg.viewBox.baseVal;
  if (box && box.width) return box.width;
  const maxWidth = parseFloat(svg.style.maxWidth);
  if (maxWidth) return maxWidth;
  return svg.getBoundingClientRect().width;
}

function enlargeSvg(svg) {
  svg.dataset.lightboxStyle = svg.getAttribute('style') || '';
  svg.dataset.lightboxWidth = svg.getAttribute('width') || '';
  svg.dataset.lightboxHeight = svg.getAttribute('height') || '';
  svg.style.width = intrinsicWidth(svg) + 'px';
  svg.style.maxWidth = 'none';
  svg.style.height = 'auto';
}

function restoreSvg(svg) {
  if (svg.dataset.lightboxStyle === undefined) return;
  if (svg.dataset.lightboxStyle) svg.setAttribute('style', svg.dataset.lightboxStyle);
  else svg.removeAttribute('style');
  if (svg.dataset.lightboxWidth) svg.setAttribute('width', svg.dataset.lightboxWidth);
  else svg.removeAttribute('width');
  if (svg.dataset.lightboxHeight) svg.setAttribute('height', svg.dataset.lightboxHeight);
  else svg.removeAttribute('height');
  delete svg.dataset.lightboxStyle;
  delete svg.dataset.lightboxWidth;
  delete svg.dataset.lightboxHeight;
}

function lockScroll() {
  const gap = window.innerWidth - document.documentElement.clientWidth;
  document.documentElement.style.paddingRight = gap ? gap + 'px' : '';
  document.documentElement.classList.add('mermaid-lightbox-open');
}

function unlockScroll() {
  document.documentElement.classList.remove('mermaid-lightbox-open');
  document.documentElement.style.paddingRight = '';
}

function pinSvg(svg) {
  svg.style.position = 'fixed';
  svg.style.left = '0px';
  svg.style.top = '0px';
  svg.style.margin = '0px';
  svg.style.transformOrigin = 'center center';
}

function finishClose() {
  const current = session;
  if (!current) return;
  const { pre, svg } = current;
  if (current.animation) current.animation.cancel();
  restoreSvg(svg);
  pre.classList.remove('mermaid-lightbox', 'is-zoomed');
  pre.removeAttribute('role');
  pre.removeAttribute('aria-modal');
  pre.removeAttribute('aria-label');
  const placeholder = pre._lightboxPlaceholder;
  if (placeholder && placeholder.isConnected) placeholder.replaceWith(pre);
  pre._lightboxPlaceholder = null;
  unlockScroll();
  session = null;
  phase = 'closed';
  pre.focus({ preventScroll: true });
}

function playZoom(svg, from, to, gen, done) {
  const animation = svg.animate(
    [{ transform: from }, { transform: to }],
    { duration: ZOOM_MS, easing: ZOOM_EASE, fill: 'forwards' }
  );
  session.animation = animation;
  animation.finished.then(() => {
    if (gen !== generation) return;
    done();
  }).catch(() => {});
}

// Reduced motion skips the slide and applies the end pose immediately.
function animateZoom(svg, from, to, gen, done) {
  svg.style.transform = from;
  if (prefersStill()) {
    done();
    return;
  }
  playZoom(svg, from, to, gen, done);
}

function closeDiagram() {
  if (!session || (phase !== 'opening' && phase !== 'open')) return;
  const { pre, svg, origin, layoutW, layoutH } = session;
  const gen = ++generation;
  phase = 'closing';

  const visual = svg.getBoundingClientRect();
  if (session.animation) session.animation.cancel();
  pre.classList.remove('is-zoomed');

  // Hold the diagram where it is, including mid-zoom and after scrolling.
  pinSvg(svg);
  const from = pose(
    visual.left + visual.width / 2,
    visual.top + visual.height / 2,
    visual.width / layoutW,
    layoutW,
    layoutH
  );
  const to = pose(
    origin.left + origin.width / 2,
    origin.top + origin.height / 2,
    origin.width / layoutW,
    layoutW,
    layoutH
  );
  animateZoom(svg, from, to, gen, finishClose);
}

function openLightbox(pre) {
  const svg = pre.querySelector('svg');
  if (!svg || phase !== 'closed') return;
  const gen = ++generation;
  phase = 'opening';

  lockScroll();
  const origin = svg.getBoundingClientRect();
  const style = getComputedStyle(pre);
  const placeholder = document.createElement('div');
  placeholder.className = 'mermaid-lightbox-placeholder';
  placeholder.setAttribute('aria-hidden', 'true');
  placeholder.style.height = pre.getBoundingClientRect().height + 'px';
  placeholder.style.marginTop = style.marginTop;
  placeholder.style.marginBottom = style.marginBottom;
  pre.before(placeholder);
  pre._lightboxPlaceholder = placeholder;

  enlargeSvg(svg);
  document.body.append(pre);
  pre.classList.add('mermaid-lightbox');
  pre.setAttribute('role', 'dialog');
  pre.setAttribute('aria-modal', 'true');
  pre.setAttribute('aria-label', 'Enlarged diagram');

  // Park the full-size diagram at the viewport origin and move it with
  // transform, so the zoom can start on top of the article placement.
  pinSvg(svg);
  const layout = svg.getBoundingClientRect();
  const layoutW = layout.width;
  const layoutH = layout.height;
  session = { pre, svg, origin, layoutW, layoutH, animation: null };

  const from = pose(origin.left + origin.width / 2, origin.top + origin.height / 2, origin.width / layoutW, layoutW, layoutH);
  const to = fitTransform(layoutW, layoutH);
  session.to = to;
  // First frame must already be the article placement, before the backdrop fades in.
  svg.style.transform = from;
  void pre.offsetWidth;
  pre.classList.add('is-zoomed');
  pre.focus({ preventScroll: true });

  const settle = () => {
    if (gen !== generation || phase !== 'opening') return;
    if (session.animation) session.animation.cancel();
    // Keep the fitted pose. Dropping it would show the natural size and overflow the window.
    svg.style.transform = session.to;
    phase = 'open';
  };
  animateZoom(svg, from, to, gen, settle);
}

document.querySelectorAll('.mermaid[data-processed]').forEach((pre) => {
  pre.tabIndex = 0;
  pre.title = 'Click to enlarge';

  // A tap on the drawing often never becomes a click: iOS does not synthesize
  // one for SVG (or for HTML inside a foreignObject). touchend still arrives.
  // The following click is ignored so the diagram does not open and close again.
  let suppressClickUntil = 0;
  let touchStart = null;

  const activate = (event) => {
    if (event.target.closest && event.target.closest('a')) return;
    if (session && pre === session.pre && (phase === 'opening' || phase === 'open')) closeDiagram();
    else if (phase === 'closed') openLightbox(pre);
  };

  pre.addEventListener('touchstart', (event) => {
    if (event.touches.length !== 1) {
      touchStart = null;
      return;
    }
    const touch = event.touches[0];
    touchStart = { x: touch.clientX, y: touch.clientY };
  }, { passive: true });

  pre.addEventListener('touchend', (event) => {
    if (!touchStart || event.changedTouches.length !== 1) return;
    const touch = event.changedTouches[0];
    const moved = Math.hypot(touch.clientX - touchStart.x, touch.clientY - touchStart.y);
    touchStart = null;
    if (moved > 10) return;
    event.preventDefault();
    suppressClickUntil = Date.now() + 700;
    activate(event);
  }, { passive: false });

  pre.addEventListener('click', (event) => {
    if (Date.now() < suppressClickUntil) return;
    activate(event);
  });

  pre.addEventListener('keydown', (event) => {
    if (phase !== 'closed') return;
    if (event.key !== 'Enter' && event.key !== ' ') return;
    event.preventDefault();
    openLightbox(pre);
  });
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && (phase === 'opening' || phase === 'open')) {
    event.preventDefault();
    closeDiagram();
  }
});

window.addEventListener('resize', () => {
  if (phase !== 'open' || !session) return;
  session.to = fitTransform(session.layoutW, session.layoutH);
  session.svg.style.transform = session.to;
});
