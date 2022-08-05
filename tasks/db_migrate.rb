# frozen_string_literal: true

require './config/db_connection'

ActiveRecord::MigrationContext.new('./db/migrate/', ActiveRecord::SchemaMigration).migrate
Rake::Task['db:schema'].invoke
puts 'Database migrated.'
