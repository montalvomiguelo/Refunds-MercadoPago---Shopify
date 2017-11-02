ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require
require 'mercadopago'
require 'base64'
require 'openssl'

Dotenv.load

require './app'

run App
