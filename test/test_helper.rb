ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'mocha/mini_test'
require 'sinatra/base'
