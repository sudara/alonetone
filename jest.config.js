module.exports = {
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/spec/javascript'],
  testMatch: ['**/*.test.js'],
  // mirrors Shakapacker's resolved_paths so specs import like the app does
  moduleDirectories: ['node_modules', 'app/javascript'],
  // stitches v3 is ESM-only and MorphSVGPlugin is a gitignored license build,
  // neither present under jest; mock both since the specs never exercise them
  moduleNameMapper: {
    '^@alonetone/stitches$': '<rootDir>/spec/javascript/mocks/stitches.js',
    'MorphSVGPlugin$': '<rootDir>/spec/javascript/mocks/morphsvg.js',
  },
  // @swc/jest, not babel-jest: the repo pins @babel/core 7.20 which jest's
  // babel preset rejects, so transpile test sources with swc instead
  transform: {
    '^.+\\.js$': ['@swc/jest', { jsc: { parser: { syntax: 'ecmascript' } } }],
  },
}
