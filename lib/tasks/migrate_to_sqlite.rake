require 'sequel'

namespace :db do
  desc "Migrate from PostgreSQL to SQLite"
  task migrate_to_sqlite: :environment do
    # Connect to source (Postgres) and destination (SQLite)
    source_url = ENV['SOURCE_DATABASE_URL'] || raise("Set SOURCE_DATABASE_URL environment variable")
    dest_path = Rails.root.join('storage', 'production.sqlite3')
    
    puts "Connecting to source database..."
    source = Sequel.connect(source_url)
    
    puts "Connecting to destination database..."
    dest = Sequel.connect("sqlite://#{dest_path}")
    
    # Get all tables except schema_migrations and ar_internal_metadata
    tables = source.tables - [:schema_migrations, :ar_internal_metadata]
    
    tables.each do |table_name|
      puts "\n=== Migrating table: #{table_name} ==="
      
      # Get table schema
      schema = source.schema(table_name)
      
      # Drop table if it exists in destination
      dest.drop_table?(table_name)
      
      # Create table with schema
      dest.create_table(table_name) do
        schema.each do |column_name, column_info|
          column_type = column_info[:type]
          
          # Map PostgreSQL types to SQLite
          sqlite_type = case column_type
                        when :integer, :bigint then :integer
                        when :string, :text then :text
                        when :boolean then :boolean
                        when :datetime, :timestamp then :datetime
                        when :date then :date
                        when :decimal, :float then :float
                        when :blob, :bytea then :blob
                        else :text
                        end
          
          column column_name, sqlite_type, 
                 null: column_info[:allow_null],
                 primary_key: column_info[:primary_key]
        end
      end
      
      # Copy data
      count = 0
      source[table_name].each do |row|
        dest[table_name].insert(row)
        count += 1
        print "\rCopied #{count} rows..." if count % 100 == 0
      end
      puts "\rCopied #{count} rows total"
    end
    
    # Copy schema_migrations
    puts "\n=== Copying schema_migrations ==="
    dest.drop_table?(:schema_migrations)
    dest.create_table(:schema_migrations) do
      String :version, primary_key: true
    end
    source[:schema_migrations].each do |row|
      dest[:schema_migrations].insert(row)
    end
    
    # Copy ar_internal_metadata if it exists
    if source.tables.include?(:ar_internal_metadata)
      puts "=== Copying ar_internal_metadata ==="
      dest.drop_table?(:ar_internal_metadata)
      dest.create_table(:ar_internal_metadata) do
        String :key, primary_key: true
        String :value
        DateTime :created_at
        DateTime :updated_at
      end
      source[:ar_internal_metadata].each do |row|
        dest[:ar_internal_metadata].insert(row)
      end
    end
    
    puts "\n✅ Migration complete!"
    puts "Database saved to: #{dest_path}"
  end
end
