// js/demo.test.js for streakvillageweb
// Tests for demo.js covering all logic for coverage
const { JSDOM } = require('jsdom');
describe('Streak Village Demo', () => {
  let window, document, section, grid, btn, villager, toast;
  beforeEach(() => {
    const dom = new JSDOM(`<!DOCTYPE html><div id="try"></div>`);
    window = dom.window;
    document = window.document;
    global.document = document;
    section = document.getElementById('try');
    section.innerHTML = '';
    // Simulate DOM structure for demo
    section.innerHTML = `<div id="demo-grid"></div><button id="checkin-btn"></button><svg id="demo-villager"></svg><div id="demo-toast"></div>`;
    grid = document.getElementById('demo-grid');
    btn = document.getElementById('checkin-btn');
    villager = document.getElementById('demo-villager');
    toast = document.getElementById('demo-toast');
  });
  it('renders initial grid', () => {
    require('./demo.js');
    expect(grid.children.length).toBe(35);
    expect([...grid.children].filter(c => c.className.includes('empty')).length).toBe(21);
  });
  it('checkin adds tile and triggers animation', () => {
    require('./demo.js');
    btn.click();
    expect(grid.children.length).toBe(35);
    expect([...grid.children].filter(c => c.className.includes('empty')).length).toBe(20);
  });
  it('shows milestone toast at 15', () => {
    require('./demo.js');
    for (let i = 0; i < 1; i++) btn.click();
    expect(toast.textContent).toMatch(/Village growing!/);
    for (let i = 0; i < 14; i++) btn.click();
    expect(toast.textContent).toMatch(/One week of focus!/);
  });
  it('disables button at 35', () => {
    require('./demo.js');
    for (let i = 0; i < 21; i++) btn.click();
    expect(btn.disabled).toBe(true);
    expect(btn.textContent).toMatch(/Village Complete!/);
  });
});
