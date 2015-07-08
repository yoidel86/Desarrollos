require 'yaml'
require 'active_record'

# ------------------------------------------------------------

#DB_TYPE = 'production'
#
## setting the db configuration file path
#db_config_file_path = './database.yml'
#
## creating a pointer to the file content
#f_db_config = File.open(db_config_file_path, 'r')
#
## loading the db configuration from the YAML file
#db_config = YAML.load(f_db_config)
#
## saving the configurations loaded from file './database.yml'
#ActiveRecord::Base.configurations = db_config

# ------------------------------------------------------------

## creating the specified database (in this case 'production' by default)
#ActiveRecord::Tasks::DatabaseTasks.create_current(DB_TYPE)

# ------------------------------------------------------------


def set_up_db_configuration(db_config_path)
  # setting the db configuration file path
  db_config_file_path = db_config_path

  # creating a pointer to the file content
  f_db_config = File.open(db_config_file_path, 'r')

  # loading the db configuration from the YAML file
  db_config = YAML.load(f_db_config)

  ## setting a global path for the database (only for the sqlite3 database)
  #db_config[db_type]['database'] = "#{File.dirname(__FILE__)}/#{db_config[db_type]['database']}"

  # saving the configurations loaded from file './database.yml'
  ActiveRecord::Base.configurations = db_config
end


def create_db()
  # type of db to create
  db_type = 'development'

  # creating the specified database (in this case 'production' by default)
  ActiveRecord::Tasks::DatabaseTasks.create_current(db_type)
end