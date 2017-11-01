ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require
require 'mercadopago'

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

require './models/shop'

require './app'

run App
