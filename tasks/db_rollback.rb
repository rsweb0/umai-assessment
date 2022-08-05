# frozen_string_literal: true

require './config/db_connection'

ActiveRecord::MigrationContext.new('./db/migrate/', ActiveRecord::SchemaMigration).rollback
Rake::Task['db:schema'].invoke
puts 'Last migration has been reverted.'
