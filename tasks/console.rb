# frozen_string_literal: true

Dir['./models/*.rb'].sort.each { |file| require file }
Dir['./workers/*.rb'].sort.each { |file| require file }
require 'irb'
require 'irb/completion'
require './config/db_connection'

ARGV.clear
IRB.start
