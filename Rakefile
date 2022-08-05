# frozen_string_literal: true

# Rakefile
require 'active_record'

# Run with: rake shell
task :console do
  require './tasks/console'
end

namespace :db do
  task :seed do
    require './seed'
  end

  task :create do
    require './tasks/db_create'
  rescue StandardError => e
    puts e
  end

  task :drop do
    require './tasks/db_drop'
  rescue StandardError => e
    puts e
  end

  task :migrate do
    require './tasks/db_migrate'
  end

  task reset: %i[drop create migrate]

  task setup: %i[create migrate seed]

  task :rollback do
    require './tasks/db_rollback'
  end

  task :schema do
    require './tasks/db_schema'
  end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    require './tasks/generate_migration'
  end
end
