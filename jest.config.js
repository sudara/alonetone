module.exports = {
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/spec/javascript'],
  testMatch: ['**/*.test.js'],
  // mirrors Shakapacker's resolved_paths so specs import like the app does
  moduleDirectories: ['node_modules', 'app/javascript'],
  // @swc/jest, not babel-jest: the repo pins @babel/core 7.20 which jest's
  // babel preset rejects, so transpile test sources with swc instead
  transform: {
    '^.+\\.js$': ['@swc/jest', { jsc: { parser: { syntax: 'ecmascript' } } }],
  },
}
