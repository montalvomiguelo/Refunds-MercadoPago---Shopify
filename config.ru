ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require

Dotenv.load

require './app'

run App
