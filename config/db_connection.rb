# frozen_string_literal: true

require 'yaml'
require 'active_record'
require 'pg'

# DbConnection
class DbConnection
  def initialize
    env = ENV['APP_ENV'] || 'development'
    db_config = YAML.load_file('./config/database.yml')[env]
    puts db_config

    ActiveRecord::Base.establish_connection(db_config)

    # Set up STDOUT or provide a filename like 'log.txt'
    # ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

    # To disable the ANSI color output:
    ActiveSupport::LogSubscriber.colorize_logging = true
  end
end

DbConnection.new
