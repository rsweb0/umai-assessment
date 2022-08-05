# frozen_string_literal: true

# rubocop:disable Naming/HeredocDelimiterNaming
name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
timestamp = Time.now.strftime('%Y%m%d%H%M%S')
path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
migration_class = name.split('_').map(&:capitalize).join

File.write(path, <<-EOF)
    class #{migration_class} < ActiveRecord::Migration[5.2]
      def self.up
      end
      def self.down
      end
    end
EOF

puts "Migration #{path} created"
abort # needed stop other tasks

# rubocop:enable Naming/HeredocDelimiterNaming
