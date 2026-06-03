// The persistent player guards on `Stitches.Player` and the controller specs
// drive behavior through dispatched player:* events, so the audio engine is
// never constructed under jest. Stubbing it also keeps the ESM-only real
// package out of jest's CommonJS transform path.
module.exports = {}
