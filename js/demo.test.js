// js/demo.test.js for streakvillageweb
const { JSDOM } = require('jsdom');
describe('Streak Village Demo', () => {
  let window, document, section;
  beforeEach(() => {
    jest.resetModules();
    const dom = new JSDOM(`<!DOCTYPE html><div id="try"></div>`);
    window = dom.window;
    document = window.document;
    global.document = document;
    section = document.getElementById('try');
  });
  it('renders initial grid', () => {
    require('./demo.js');
    const grid = document.getElementById('demo-grid');
    expect(grid.children.length).toBe(35);
    expect([...grid.children].filter(c => c.className.includes('empty')).length).toBe(21);
  });
  it('checkin adds tile and triggers animation', () => {
    jest.useFakeTimers();
    require('./demo.js');
    const grid = document.getElementById('demo-grid');
    const btn = document.getElementById('checkin-btn');
    btn.click();
    jest.advanceTimersByTime(1100);
    expect(grid.children.length).toBe(35);
    expect([...grid.children].filter(c => c.className.includes('empty')).length).toBe(20);
    jest.useRealTimers();
  });
  it('shows milestone toast at 15', () => {
    require('./demo.js');
    const btn = document.getElementById('checkin-btn');
    const toast = document.getElementById('demo-toast');
    btn.click();
    expect(toast.textContent).toMatch(/One week of focus!/);
  });
  it('disables button at 35', () => {
    jest.useFakeTimers();
    require('./demo.js');
    const btn = document.getElementById('checkin-btn');
    for (let i = 0; i < 21; i++) {
      btn.click();
      jest.advanceTimersByTime(1100);
    }
    expect(btn.disabled).toBe(true);
    expect(btn.textContent).toMatch(/Village Complete!/);
    jest.useRealTimers();
  });
});
