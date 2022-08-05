# frozen_string_literal: true

# require './config/db_connection'
require 'active_record/schema_dumper'

db_config = YAML.load_file('./config/database.yml')[ENV['APP_ENV'] || 'development']
ActiveRecord::Base.establish_connection(db_config)

filename = './db/schema.rb'
File.open(filename, 'w:utf-8') do |file|
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
end
