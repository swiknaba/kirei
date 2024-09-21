# typed: false

# rubocop:disable Metrics/ClassLength

module Cli
  module Commands
    module NewApp
      module Files
        class DbRake
          def self.call(app_name)
            # set db_name to snake_case version of app_name
            db_name = app_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
            File.write("lib/tasks/db.rake", content(app_name, db_name))
          end

          def self.content(app_name, db_name)
            <<~RUBY
              # typed: false

              # run on the database server once:
              #
              #   CREATE DATABASE #{db_name}_${environment};

              require 'zeitwerk/inflector'
              require_relative "../../app"

              namespace :db do
                # RACK_ENV=development bundle exec rake db:create
                desc "Create the database"
                task :create do
                  envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
                  envs.each do |env|
                    ENV["RACK_ENV"] = env
                    db_name = "#{db_name}_\#{env}"
                    puts("Creating database \#{db_name}...")

                    reset_memoized_class_level_instance_vars(#{app_name})
                    url = #{app_name}.default_db_url.dup # frozen string
                    url.gsub!(db_name, "postgres")
                    puts("Connecting to \#{url.gsub(%r{://.*@}, "_REDACTED_")}")
                    db = Sequel.connect(url)

                    begin
                      db.execute("CREATE DATABASE \#{db_name}")
                      puts("Created database \#{db_name}.")
                    rescue Sequel::DatabaseError, PG::DuplicateDatabase
                      puts("Database \#{db_name} already exists, skipping.")
                    end
                  end
                end

                desc "Drop the database"
                task :drop do
                  envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
                  envs.each do |env|
                    ENV["RACK_ENV"] = env
                    db_name = "#{db_name}_\#{env}"
                    puts("Dropping database \#{db_name}...")

                    reset_memoized_class_level_instance_vars(#{app_name})
                    url = #{app_name}.default_db_url.dup  # frozen string
                    url.gsub!(db_name, "postgres")
                    puts("Connecting to \#{url.gsub(%r{://.*@}, "_REDACTED_")}")
                    db = Sequel.connect(url)

                    begin
                      db.execute("DROP DATABASE \#{db_name} (FORCE)")
                      puts("Dropped database \#{db_name}.")
                    rescue Sequel::DatabaseError, PG::DuplicateDatabase
                      puts("Database \#{db_name} does not exists, nothing to drop.")
                    end
                  end
                end

                desc "Run migrations"
                task :migrate do
                  Sequel.extension(:migration)
                  envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
                  envs.each do |env|
                    ENV["RACK_ENV"] = env
                    db_name = "#{db_name}_\#{env}"
                    reset_memoized_class_level_instance_vars(#{app_name})
                    db = Sequel.connect(#{app_name}.default_db_url)
                    Sequel::Migrator.run(db, File.join(#{app_name}.root, "db/migrate"))
                    current_version = db[:schema_migrations].order(:filename).last[:filename].to_i
                    puts "Migrated \#{db_name} to version \#{current_version}!"
                  end

                  Rake::Task["db:annotate"].invoke
                end

                desc "Rollback the last migration"
                task :rollback do
                  envs = ENV.key?("RACK_ENV") ? [ENV.fetch("RACK_ENV")] : %w[development test]
                  Sequel.extension(:migration)
                  envs.each do |env|
                    ENV["RACK_ENV"] = env
                    db_name = "#{db_name}_\#{env}"
                    reset_memoized_class_level_instance_vars(#{app_name})
                    db = Sequel.connect(#{app_name}.default_db_url)

                    steps = (ENV["STEPS"] || 1).to_i + 1
                    versions = db[:schema_migrations].order(:filename).all

                    if versions[-steps].nil?
                      puts "No more migrations to rollback"
                    else
                      target_version = versions[-steps][:filename].to_i

                      Sequel::Migrator.run(db, File.join(#{app_name}.root, "db/migrate"), target: target_version)
                      puts "Rolled back \#{db_name} \#{steps} steps to version \#{target_version}"
                    end
                  end
                end

                desc "Seed the database"
                task :seed do
                  load File.join(#{app_name}.root, "db/seeds.rb")
                end

                desc "Generate a new migration file"
                task :migration, [:name] do |_t, args|
                  require "fileutils"
                  require "time"

                  # Ensure the migrations directory exists
                  migrations_dir = File.join(#{app_name}.root, "db/migrate")
                  FileUtils.mkdir_p(migrations_dir)

                  # Generate the migration number
                  migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S")

                  # Sanitize and format the migration name
                  formatted_name = args[:name].to_s.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase

                  # Combine them to create the filename
                  filename = "\#{migration_number}_\#{formatted_name}.rb"
                  file_path = File.join(migrations_dir, filename)

                  # Define the content of the migration file
                  content = <<~MIGRATION
                    # typed: false
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
                  File.write(file_path, content)

                  puts "Generated migration: db/migrate/\#{filename}"
                end

                desc "Write the table schema to each model file, or a single file if filename (without extension) is provided"
                task :annotate, [:model_file_name] do |_t, args|
                  require "fileutils"

                  db = #{app_name}.raw_db_connection
                  model_file_name = args[:model_file_name]&.to_s

                  models_dir = #{app_name}.root

                  Dir.glob("app/models/**/*.rb").each do |model_file|
                    next if !model_file_name.nil? && model_file == model_file_name

                    model_path = File.expand_path(model_file, models_dir)
                    modules = model_file.gsub("app/models/", "").gsub(".rb", "").split("/").map { |mod| Zeitwerk::Inflector.new.camelize(mod, model_path) }
                    const_name = modules.join("::")
                    model_klass = Object.const_get(const_name)
                    table_name = model_klass.table_name
                    schema = db.schema(table_name)

                    schema_comments = format_schema_comments(table_name, schema)

                    file_contents = File.read(model_path)

                    # Remove existing schema info comments if present
                    updated_contents = file_contents.sub(/# == Schema Info\\n(.*?)(\\n#\\n)?\\n(?=\\s*class)/m, "")

                    # Insert the new schema comments before the module/class definition
                    first_const = modules.first
                    first_module_or_class = modules.count == 1 ? "class #{first_const}" : "module #{first_const}"
                    modified_contents = updated_contents.sub(/(A|\n)(#{first_module_or_class})/m, "\\1#{schema_comments}\n\n\\2")

                    File.write(model_path, modified_contents)
                  end
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

              def format_schema_comments(table_name, schema)
                lines = ["# == Schema Info", "#", "# Table name: \#{table_name}", "#"]
                schema.each do |column|
                  name, info = column
                  type = "\#{info[:db_type]}(\#{info[:max_length]})" if info[:max_length]
                  type ||= info[:db_type]
                  null = info[:allow_null] ? 'null' : 'not null'
                  primary_key = info[:primary_key] ? ', primary key' : ''
                  lines << "#  \#{name.to_s.ljust(20)}:\#{type}    \#{null}\#{primary_key}"
                end
                lines.join("\\n") + "\\n#"
              end

            RUBY
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
