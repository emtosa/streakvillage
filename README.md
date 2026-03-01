# Streak Village: Daily Builder — Website

Marketing website for the Streak Village: Daily Builder iOS app.

**Live:** https://foculoom.com/streakvillage/  
**App Store:** https://apps.apple.com/app/id6759697170

Built with plain HTML/CSS. No build tools required.

### Unit tests

The interactive demo in `js/demo.js` is covered by Jest tests.

```sh
# Install dependencies (jest and jsdom are included in package.json)
npm install

# Run tests
npm test
```

Coverage is written to `coverage/`. Tests use [jsdom](https://github.com/jsdom/jsdom) to simulate the browser DOM in Node.js.
