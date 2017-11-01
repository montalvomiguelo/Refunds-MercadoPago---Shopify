ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require

Dotenv.load

DB = Sequel.connect(ENV['DATABASE_URL'])

require './app'

run App
