/* =============================================
   Streak Village — Interactive Demo
   ============================================= */
(function () {
  'use strict';

  const TILES = [
    '🏠','🌳','🏪','🌻','🏡','🌲','🛖',
    '🌺','🏘️','🌼','🏗️','⛲','🌾','🎪',
    '🏫','🌷','🏬','🌿','🏰','🌸','🏯',
    '🌴','🏟️','🍀','🏛️','🌵','🏗️','🌱',
    '🏠','🌳','🏪','🌻','🏡','🌲','🏆',
  ];

  const MILESTONES = {
    15: '🎉 One week of focus!',
    21: 'Three weeks strong! 🌟',
    35: 'Village complete! 🏆',
  };

  const COLS = 7;
  const PREFILL = 14;

  let tileCount = PREFILL;
  let busy = false;

  /* ── Build DOM ── */
  const section = document.getElementById('try');
  if (!section) return;

  section.innerHTML = `
    <style>
      #try {
        background: var(--highlight-soft, #f0fdf4);
        border-top: 1px solid var(--border);
        border-bottom: 1px solid var(--border);
      }
      #try .try-inner {
        max-width: 600px;
        margin: 0 auto;
        padding: 0 24px;
        text-align: center;
      }
      #try .try-eyebrow {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: var(--accent);
        color: #fff;
        font-size: .75rem;
        font-weight: 700;
        letter-spacing: .08em;
        text-transform: uppercase;
        padding: 4px 11px;
        border-radius: 100px;
        margin-bottom: 14px;
      }
      #try h2 { margin-bottom: 6px; }
      #try .try-sub {
        color: var(--text-secondary);
        font-size: .95rem;
        margin-bottom: 32px;
      }

      /* Grid */
      #demo-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 6px;
        margin-bottom: 28px;
        max-width: 420px;
        margin-left: auto;
        margin-right: auto;
      }
      .demo-cell {
        aspect-ratio: 1;
        background: var(--bg-card);
        border: 1.5px solid var(--border);
        border-radius: var(--radius-sm, 8px);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: clamp(1rem, 3.5vw, 1.6rem);
        transition: background .2s;
      }
      .demo-cell.empty {
        background: rgba(0,0,0,.03);
      }
      .demo-cell.drop-in {
        animation: dropIn .35s cubic-bezier(.34,1.56,.64,1) both;
      }
      @keyframes dropIn {
        from { transform: scale(0) rotate(-10deg); opacity: 0; }
        to   { transform: scale(1) rotate(0deg);   opacity: 1; }
      }

      /* Check-in button */
      #checkin-btn {
        font-size: 1.1rem;
        padding: 14px 32px;
        background: var(--accent);
        color: #fff;
        border: none;
        border-radius: var(--radius-sm, 8px);
        cursor: pointer;
        font-weight: 700;
        transition: opacity .15s, transform .1s, background .15s;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        box-shadow: 0 2px 8px rgba(22,163,74,.35);
      }
      #checkin-btn:hover:not(:disabled) { opacity: .88; transform: translateY(-1px); }
      #checkin-btn:active:not(:disabled) { transform: translateY(0); }
      #checkin-btn:disabled {
        opacity: .5;
        cursor: default;
        transform: none;
      }

      /* Villager */
      #demo-villager {
        display: block;
        margin: 20px auto 0;
        width: 40px;
        height: 40px;
      }
      #demo-villager.wiggle {
        animation: villagerWiggle .6s ease both;
      }
      @keyframes villagerWiggle {
        0%   { transform: translateY(0) rotate(0); }
        20%  { transform: translateY(-6px) rotate(-8deg); }
        40%  { transform: translateY(-4px) rotate(8deg); }
        60%  { transform: translateY(-6px) rotate(-5deg); }
        80%  { transform: translateY(-2px) rotate(3deg); }
        100% { transform: translateY(0) rotate(0); }
      }

      /* Toast */
      #demo-toast {
        position: fixed;
        bottom: 28px;
        left: 50%;
        transform: translateX(-50%) translateY(20px);
        background: var(--stone-900, #1c1917);
        color: #fff;
        padding: 10px 20px;
        border-radius: 100px;
        font-size: .9rem;
        font-weight: 600;
        opacity: 0;
        pointer-events: none;
        transition: opacity .25s, transform .25s;
        z-index: 999;
        white-space: nowrap;
      }
      #demo-toast.show {
        opacity: 1;
        transform: translateX(-50%) translateY(0);
      }
    </style>

    <div class="try-inner">
      <span class="try-eyebrow">▶ Try It</span>
      <h2>Experience a bit of the village</h2>
      <p class="try-sub">Each check-in places a new tile. Watch your village grow.</p>

      <div id="demo-grid" role="grid" aria-label="Village tile grid"></div>

      <button id="checkin-btn" aria-label="Check in today">
        ✅ Check In Today
      </button>

      <svg id="demo-villager" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg"
           aria-hidden="true" focusable="false">
        <!-- head -->
        <circle cx="20" cy="8" r="5" fill="#16a34a"/>
        <!-- body -->
        <line x1="20" y1="13" x2="20" y2="27" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round"/>
        <!-- arms -->
        <line x1="20" y1="18" x2="11" y2="23" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round"/>
        <line x1="20" y1="18" x2="29" y2="23" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round"/>
        <!-- legs -->
        <line x1="20" y1="27" x2="14" y2="36" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round"/>
        <line x1="20" y1="27" x2="26" y2="36" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round"/>
      </svg>
    </div>

    <div id="demo-toast" role="status" aria-live="polite"></div>
  `;

  /* ── Render grid ── */
  const grid = document.getElementById('demo-grid');

  function renderGrid() {
    grid.innerHTML = '';
    for (let i = 0; i < 35; i++) {
      const cell = document.createElement('div');
      cell.className = 'demo-cell' + (i >= tileCount ? ' empty' : '');
      cell.setAttribute('role', 'gridcell');
      if (i < tileCount) {
        cell.textContent = TILES[i] || '🏠';
      }
      grid.appendChild(cell);
    }
  }

  /* ── Toast ── */
  const toast = document.getElementById('demo-toast');
  let toastTimer;

  function showToast(msg) {
    clearTimeout(toastTimer);
    toast.textContent = msg;
    toast.classList.add('show');
    toastTimer = setTimeout(() => toast.classList.remove('show'), 2800);
  }

  /* ── Villager wiggle ── */
  const villager = document.getElementById('demo-villager');

  function wiggleVillager() {
    villager.classList.remove('wiggle');
    void villager.offsetWidth; // reflow to restart animation
    villager.classList.add('wiggle');
    villager.addEventListener('animationend', () => villager.classList.remove('wiggle'), { once: true });
  }

  /* ── Check-in ── */
  const btn = document.getElementById('checkin-btn');

  function checkin() {
    if (busy || tileCount >= 35) return;
    busy = true;
    btn.disabled = true;

    tileCount++;
    renderGrid();

    // animate the newly placed cell
    const cells = grid.querySelectorAll('.demo-cell');
    const newCell = cells[tileCount - 1];
    if (newCell) {
      newCell.classList.add('drop-in');
      newCell.addEventListener('animationend', () => newCell.classList.remove('drop-in'), { once: true });
    }

    wiggleVillager();

    const milestone = MILESTONES[tileCount];
    if (milestone) {
      showToast(milestone);
    } else {
      showToast('Village growing! ' + tileCount + ' tiles');
    }

    if (tileCount >= 35) {
      btn.textContent = '🏆 Village Complete!';
      btn.disabled = true;
      busy = false;
      return;
    }

    setTimeout(() => {
      busy = false;
      btn.disabled = false;
    }, 1000);
  }

  btn.addEventListener('click', checkin);

  /* ── Init ── */
  renderGrid();
})();
