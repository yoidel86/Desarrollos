require_relative '../mv/db/db_create'
require_relative '../mv/db/db_migrate'

# setting the db config path
db_config_path = '../mv_threads/db/database.yml'

# setting up database configuration
set_up_db_configuration(db_config_path)

# creating the database
create_db()

# connecting to the database
connect_to_database(db_config_path)

# running the migrations
run_migrations()