require_relative './migrations/create_received_sequence_table'
require_relative './migrations/create_failed_sequence_table'
require_relative './migrations/create_parsed_sequence_table'
require_relative './migrations/create_json_sequence_table'

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
## actually establishing connection
#ActiveRecord::Base.establish_connection(db_config[DB_TYPE])

# ------------------------------------------------------------


## running the migration for the table 'received_sequences'
#CreateReceivedSequenceTable.new().migrate(:change)
#
## running the migration for the table 'failed_sequences'
#CreateFailedSequenceTable.new().migrate(:change)
#
## running the migration for the table 'processed_sequences'
#CreateParsedSequenceTable.new().migrate(:change)

# ------------------------------------------------------------


def connect_to_database(db_config_path)
  # type of db to create
  db_type = 'development'

  # setting the db configuration file path
  db_config_file_path = db_config_path

  # creating a pointer to the file content
  f_db_config = File.open(db_config_file_path, 'r')

  # loading the db configuration from the YAML file
  db_config = YAML.load(f_db_config)

  ## setting a global path for the database (only for the sqlite3 database)
  #db_config[db_type]['database'] = "#{File.dirname(__FILE__)}/#{db_config[db_type]['database']}"

  # actually establishing connection
  ActiveRecord::Base.establish_connection(db_config[db_type])
end


def run_migrations()
  # running the migration for the table 'received_sequences'
  CreateReceivedSequenceTable.new().migrate(:change)

  # running the migration for the table 'failed_sequences'
  CreateFailedSequenceTable.new().migrate(:change)

  ## running the migration for the table 'processed_sequences'
  #CreateParsedSequenceTable.new().migrate(:change)

  # running the migration for the table 'json_sequences'
  CreateJsonSequenceTable.new().migrate(:change)
end