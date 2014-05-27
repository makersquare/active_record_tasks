# ActiveRecordTasks

The easiest way to get started with ActiveRecord 4 in a non-rails project.

## Installation

Add this line to your application's Gemfile:

    gem 'active_record_tasks', '~> 1.1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_tasks

## Getting Started

Include the following in your `Rakefile`:

```ruby
require 'active_record_tasks'

ActiveRecordTasks.configure do |config|
  # These are all the default values
  config.db_dir = 'db'
  config.db_config_path = 'db/config.yml'
  config.env = 'test'
end

# Run this AFTER you've configured
ActiveRecordTasks.load_tasks
```

If this is a new project:

```
$ rake generate:init
```

will generate your configured db directory (if it doesn't exist).

## Usage

ActiveRecordTasks gives you access to all the ActiveRecord db tasks:

```
$ rake -T
rake db:create              # Creates the database from DATABASE_URL or config/database.yml for the ...
rake db:drop                # Drops the database from DATABASE_URL or config/database.yml for the cu...
rake db:fixtures:load       # Load fixtures into the current environment's database
rake db:migrate             # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
rake db:migrate:status      # Display status of migrations
rake db:rollback            # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rake db:schema:cache:clear  # Clear a db/schema_cache.dump file
rake db:schema:cache:dump   # Create a db/schema_cache.dump file
rake db:schema:dump         # Create a db/schema.rb file that is portable against any DB supported b...
rake db:schema:load         # Load a schema.rb file into the database
rake db:seed                # Load the seed data from db/seeds.rb
rake db:setup               # Create the database, load the schema, and initialize with the seed dat...
rake db:structure:dump      # Dump the database structure to db/structure.sql
rake db:version             # Retrieves the current schema version number
...
```

### Generating Migrations

This gem provides a bonus `generate:migration` task. It's very basic, but it works:

```
rake generate:migration name=CreateUsers
```

This will create a timestamped file in your configured db directory (`db/migrate/` by default).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
