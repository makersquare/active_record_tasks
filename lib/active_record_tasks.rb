require 'yaml'
require 'erb'

module ActiveRecordTasks
  DatabaseConfig = Struct.new(:db_dir, :db_config_path, :env, :root, :seed_loader)
  @config = DatabaseConfig.new

  def self.configure
    yield @config
  end

  def self.config
    @config
  end

  def self.load_tasks
    require 'active_record_tasks/tasks'
  end
end

require 'active_record_tasks/version'
