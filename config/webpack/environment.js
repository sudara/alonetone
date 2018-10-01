const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')

environment.config.set('output.library', 'alonetone')
module.exports = environment
