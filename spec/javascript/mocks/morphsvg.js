// The real plugin is a gitignored, license-injected build absent under jest;
// the animations already no-op when it's missing (`if (MorphSVGPlugin)`).
module.exports = { MorphSVGPlugin: null }
