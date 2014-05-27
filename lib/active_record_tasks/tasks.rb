
config = ActiveRecordTasks.config
config.db_dir ||= 'db'
config.db_config_path ||= File.join(config.db_dir, 'config.yml')
config.env ||= 'development'

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
  require 'erb'
  # yaml = YAML.load(ERB.new(IO.read(@config[:db_yml])))
  db_config = YAML.load ERB.new(File.read config.db_config_path).result
  ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_config
  ActiveRecord::Tasks::DatabaseTasks.db_dir = config.db_dir
  ActiveRecord::Tasks::DatabaseTasks.env = config.env
  ActiveRecord::Tasks::DatabaseTasks.root = config.root || File.join(config.db_dir, '..')
  ActiveRecord::Tasks::DatabaseTasks.seed_loader = config.seed_loader
end

# Migrations need an environment with an already established database connection
task :environment => ["db:load_config"] do
  ActiveRecord::Base.establish_connection ActiveRecord::Tasks::DatabaseTasks.database_configuration[ActiveRecord::Tasks::DatabaseTasks.env]
end

# Simple migration generator
namespace :generate do
  require 'rainbow/ext/string'
  def puts_exists(subject)
    print "\texists\t".color(:cyan)
    puts subject
  end
  def puts_create(subject)
    print "\tcreate\t".color(:green)
    puts subject
  end

  desc "Generates a new db directory"
  task :init do
    # Create (configured) db and db/migrate directory
    if File.directory?(config.db_dir)
      puts_exists config.db_dir
    else
      puts_create config.db_dir
      Dir.mkdir(config.db_dir)
    end

    migrate_dir = "#{config.db_dir}/migrate"
    if File.directory?(migrate_dir)
      puts_exists migrate_dir
    else
      puts_create migrate_dir
      Dir.mkdir(migrate_dir)
    end

    # Create basic config.yml file
    db_config_path = config.db_config_path
    if File.exist?(db_config_path)
      puts_exists db_config_path
    else
      puts_create db_config_path
      project_dir = File.basename(Dir.pwd)
      template = File.read File.join(File.dirname(__FILE__), 'templates/config.erb')
      result = ERB.new(template).result(binding)

      File.write(db_config_path, result)
    end

  end


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

    # Ensure migrate directory exists
    migrate_dir = "#{config.db_dir}/migrate"
    unless File.directory?(migrate_dir)
      Dir.mkdir(migrate_dir)
    end

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    migration_path = File.join(migrate_dir, "#{timestamp}_#{name.underscore}.rb")
    File.write(migration_path, result)
    puts_create migration_path
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
