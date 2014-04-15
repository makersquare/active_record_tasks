
config = ActiveRecordTasks.config
config.db_dir ||= 'db'
config.db_config_path ||= File.join(config.db_dir, 'config.yml')
config.env ||= 'test'

# This is needed to overwrite the already-existing Rake task "load_config"
class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

# Load the ActiveRecord tasks
spec = Gem::Specification.find_by_name("activerecord")
load File.join(spec.gem_dir, "lib/active_record/railties/databases.rake")

# Overwrite the load config to your needs
Rake::Task["db:load_config"].overwrite do
  ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration = YAML.load File.read(config.db_config_path)
  ActiveRecord::Tasks::DatabaseTasks.db_dir = config.db_dir
  ActiveRecord::Tasks::DatabaseTasks.env = config.env
end

# Migrations need an environment with an already established database connection
task :environment => ["db:load_config"] do
  ActiveRecord::Base.establish_connection ActiveRecord::Tasks::DatabaseTasks.database_configuration[ActiveRecord::Tasks::DatabaseTasks.env]
end

# Simple migration generator
namespace :generate do
  desc "Creates a new migration file with the specified name"
  task :migration => :environment do |t, args|
    name = args[:name] || ENV['name']

    unless name
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      abort
    end

    # Require helper for `camelize` and `underscore`
    require 'active_support/core_ext/string/inflections.rb'

    # Generate file name based on time
    # Anything more complicated that this would warrant its own file
    template = File.read File.join(File.dirname(__FILE__), 'templates/migrate.erb')
    result = ERB.new(template).result(binding)

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    migration_path = File.join("#{config.db_dir}/migrate/#{timestamp}_#{name.underscore}.rb")
    File.write(migration_path, result)
    puts "      create    #{migration_path}"
  end
end

# Alias `generate` namespace with `g`
rule "" do |tsk|
  aliastask = tsk.name.sub(/g:/, 'generate:')
  if Rake.application.tasks.map{|tsk| tsk.name }.include?( aliastask )
    Rake.application[aliastask].invoke
  else
    raise RuntimeError, "Don't know how to build task '#{tsk.name}'"
  end
end
