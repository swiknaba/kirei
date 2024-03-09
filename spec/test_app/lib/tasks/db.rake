# typed: false

# run on the database server once:
#
#   CREATE DATABASE test_app_development;

require_relative "../../app"
require 'byebug'

namespace :db do
  # RACK_ENV=development bundle exec rake db:create
  desc "Create the database"
  task :create do
    envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
    envs.each do |env|
      ENV["RACK_ENV"] = env
      db_name = "test_app_#{env}"
      puts("Creating database '#{db_name}'...")

      reset_memoized_class_level_instance_vars(TestApp)
      url = TestApp.default_db_url.dup # frozen string
      url.gsub!(db_name, "postgres")
      puts("Connecting to #{url.gsub(/:\/\/.*@/, "_REDACTED_")}")
      db = Sequel.connect(url)

      begin
        db.execute("CREATE DATABASE #{db_name}")
        puts("Created database '#{db_name}'.")
      rescue Sequel::DatabaseError, PG::DuplicateDatabase
        puts("Database '#{db_name}' already exists, skipping.")
      end
    end
  end

  desc "Drop the database"
  task :drop do
    envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
    envs.each do |env|
      ENV["RACK_ENV"] = env
      db_name = "test_app_#{env}"
      puts("Dropping database '#{db_name}'...")

      reset_memoized_class_level_instance_vars(TestApp)
      url = TestApp.default_db_url.dup # frozen string
      url.gsub!(db_name, "postgres")
      puts("Connecting to #{url.gsub(/:\/\/.*@/, "_REDACTED_")}")
      db = Sequel.connect(url)

      begin
        db.execute("DROP DATABASE #{db_name} (FORCE)")
        puts("Dropped database '#{db_name}'.")
      rescue Sequel::DatabaseError, PG::DuplicateDatabase
        puts("Database '#{db_name}' does not exists, nothing to drop.")
      end
    end
  end

  desc "Run migrations"
  task :migrate do
    Sequel.extension(:migration)
    envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
    envs.each do |env|
      ENV["RACK_ENV"] = env
      db_name = "test_app_#{env}"
      reset_memoized_class_level_instance_vars(TestApp)
      db = Sequel.connect(TestApp.default_db_url)
      Sequel::Migrator.run(db, File.join(TestApp.root, "db/migrate"))
      current_version = db[:schema_migrations].order(:filename).last[:filename].to_i
      puts "Migrated '#{db_name}' to version #{current_version}!"
    end
  end

  desc "Rollback the last migration"
  task :rollback do
    envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
    Sequel.extension(:migration)
    envs.each do |env|
      ENV["RACK_ENV"] = env
      db_name = "test_app_#{env}"
      reset_memoized_class_level_instance_vars(TestApp)
      db = Sequel.connect(TestApp.default_db_url)

      steps = (ENV["STEPS"] || 1).to_i + 1
      versions = db[:schema_migrations].order(:filename).all

      if versions[-steps].nil?
        puts "No more migrations to rollback"
      else
        target_version = versions[-steps][:filename].to_i

        Sequel::Migrator.run(db, File.join(TestApp.root, "db/migrate"), target: target_version)
        puts "Rolled back '#{db_name}' #{steps} steps to version #{target_version}"
      end
    end
  end

  desc "Seed the database"
  task :seed do
    load File.join(TestApp.root, "db/seeds.rb")
  end

  desc "Generate a new migration file"
  task :migration, [:name] do |t, args|
    require 'fileutils'
    require 'time'

    # Ensure the migrations directory exists
    migrations_dir = File.join(TestApp.root, "db/migrate")
    FileUtils.mkdir_p(migrations_dir)

    # Generate the migration number
    migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S")

    # Sanitize and format the migration name
    formatted_name = args[:name].to_s.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

    # Combine them to create the filename
    filename = "#{migration_number}_#{formatted_name}.rb"
    file_path = File.join(migrations_dir, filename)

    # Define the content of the migration file
    content = <<~MIGRATION
      # typed: strict
      # frozen_string_literal: true

      Sequel.migration do
        up do
          # your code here
        end

        down do
          # your code here
        end
      end
    MIGRATION

    # Write the migration file
    File.open(file_path, "w") { |file| file.write(content) }

    puts "Generated migration: db/migrate/#{filename}"
  end
end

def reset_memoized_class_level_instance_vars(app)
  %i[
    @default_db_name
    @default_db_url
    @raw_db_connection
  ].each do |ivar|
    app.remove_instance_variable(ivar) if app.instance_variable_defined?(ivar)
  end
end
