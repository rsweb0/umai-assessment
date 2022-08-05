# frozen_string_literal: true

db_config = YAML.load_file('./config/database.yml')[ENV['APP_ENV'] || 'development']
ActiveRecord::Base.establish_connection(db_config.except('database'))
ActiveRecord::Base.connection.drop_database(db_config['database'])
puts 'Database deleted.'
