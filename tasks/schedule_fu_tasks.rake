# Initializer must be run or we get uninitialized class variable @@configuration (introduced w/rails 2.1)
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
Rails::Initializer.run
require 'rails_generator' 
require 'rails_generator/scripts/generate' 

namespace :db do  
  namespace :migrate do  
    desc "Generate the migrations in vendor/plugins/schedule_fu/db/migrate"
    task :schedule_fu => :environment do
      migrations = ['add_schedule_fu_tables']
      migrations.each do |migration|
        puts "Generating migration: #{migration}"
        Rails::Generator::Scripts::Generate.new.run(["migration", migration])
        write_migration_content(migration)
      end
    end
  
    def write_migration_content(migration)
      copy_to_path = File.join(RAILS_ROOT, "db", "migrate")
      migration_filename = Dir.entries(copy_to_path).collect do |file|
        number, *name = file.split("_")
        file if name.join("_") == "#{migration}.rb"
      end.compact.first
      migration_file = File.join(copy_to_path, migration_filename)
      File.open(migration_file, "wb") do |f| 
        f.write(File.read(migration_source_file(migration)))
      end
    end
    
    def migration_source_file(migration)
      File.join(File.dirname(__FILE__), "../db", "migrate", "#{migration}.rb")
    end
  end
end 
