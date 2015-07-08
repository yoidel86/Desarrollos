require 'yaml'
require 'active_record'
require_relative './parsing_error_type'
require_relative './db/models/received_sequence'
require_relative './db/models/failed_sequence'
require_relative './db/models/parsed_sequence'
require_relative './db/models/json_sequence'

# ----------------------------------------------------------------------------

# represents a generic data logger
class AbstractDataLogger < Object
  # the constructor or initializer
  def initialize()
    # do nothing for now
  end

  # saves a sequence (it's raw data)
  def store_sequence(parsing_error, sequence_id, hour, sequence_bytes)
    # empty --> this is like an abstract class method
  end

  # saves the processed sequence data
  def store_processed_sequence(sequence_id, hour, processed_sequence)
    # empty --> this is like an abstract class method
  end

  # gets the storage related information
  def print_storage_info()
    # empty --> this is like an abstract class method
  end
end

# ----------------------------------------------------------------------------

# represents a database data logger
class DatabaseDataLogger < AbstractDataLogger
  private
  # represents the connection to database by active record
  @db_conn = nil

  # represents the database configuration information
  @db_config = nil

  # type of db to create (creating production from now)
  DB_TYPE = 'development'

  public
  # the constructor or initializer
  def initialize()
    # calling base constructor
    super()

    # trying to connect to database
    begin
      # setting the db configuration file path
      db_config_file_path = "#{File.dirname(__FILE__)}/db/database.yml"

      # creating a pointer to the file content
      f_db_config = File.open(db_config_file_path, 'r')

      # loading the db configuration from the YAML file
      @db_config = YAML.load(f_db_config)

      ## setting a global path for the database (only for the sqlite3 database)
      #@db_config[DB_TYPE]['database'] = "#{File.dirname(__FILE__)}/db/#{@db_config[DB_TYPE]['database']}"

      # actually establishing connection to database through active_record
      @db_conn = ActiveRecord::Base.establish_connection(@db_config[DB_TYPE])
    rescue Exception => e
      # building the error message
      msg = "Failed to connect to database. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # saves a sequence (it's raw data)
  def store_sequence(parsing_error, sequence_id, hour, sequence_bytes)
    # remark: i don't use the 'hour' parameter because 'activerecord' has it's own

    # attempt to store the sequence data
    begin
      # encoding the sequence of bytes
      data_str = Base64.encode64(sequence_bytes)

      if parsing_error == ParsingErrorType::NO_ERROR
        # creating a record in database
        ReceivedSequence.create(:sequence_id => sequence_id, :data_bytes => data_str)
      else
        # creating a record in database
        FailedSequence.create(:sequence_id => sequence_id, :data_bytes => data_str, :error_type => parsing_error)
      end
    rescue Exception => e
      # building the error message
      msg = "Unexpected error while interacting with the database. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # saves the processed sequence data
  def store_processed_sequence(sequence_id, hour, processed_sequence)
    # remark: here i don't use the parameters 'sequence_id' and 'hour' because
    # i still don't know the final db design and right now there are no fields
    # for that information

    begin
      ## getting the string representation of the processed sequence
      #str_data = processed_sequence.to_s()
      #
      ## creating a record in the table parsed_sequences
      #ParsedSequence.create(
      #    :message_type => processed_sequence['TIPO_REG'],
      #    :emitter => processed_sequence['EMISORA'],
      #    :parsed_sequence => str_data
      #)

      received_stamp_str = hour.insert(6, '.').insert(4, ':').insert(2, ':')
      received_stamp = DateTime.parse(received_stamp_str)

      # creating a record in the table json_sequences
      JsonSequence.create(
          :sequence_id => sequence_id,
          :generated_timestamp => received_stamp,
          :message_type => processed_sequence['TIPO_REG'],
          :emitter => processed_sequence['EMISORA'],
          :json_data => build_json_data(processed_sequence)
      )
    rescue Exception => e
      # building the error message
      msg = "Unexpected error while interacting with the database. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # gets the storage related information
  def print_storage_info()
    # cloning the database configuration
    storage_info = @db_config.clone()

    # hiding database password
    storage_info['password'] = 'PRIVATE'

    # printing information
    storage_info.each{ |key| puts("#{key}#{storage_info[key] }") }
  end

  # builds the json data from a hash
  def build_json_data(h)
    # building each item of the json data
    json_items = h.keys().map { |k| "\"#{k}\": \"#{h[k]}\"" }

    # actually returning the json data
    return "{#{json_items.join(', ')}}"
  end
end

# ----------------------------------------------------------------------------

# represents a hard drive data logger
class HardDriveDataLogger < AbstractDataLogger
  private
  # represents the file path where the received sequences will be stored
  @received_file_path = nil

  # represents the file path where the failed sequences will be stored
  @failed_file_path = nil

  # represents the file path where the processed sequences will be stored
  @processed_file_path = nil

  # represents a handle to the correctly received sequences
  @received_handle = nil

  # represents a handle to failed processed sequences
  @failed_handle = nil

  # represents a handle to the processed sequences
  @processed_handle = nil

  public
  # the constructor or initializer
  def initialize()
    # calling base constructor
    super()

    # assigning the received sequences path
    @received_file_path = "#{File.dirname(__FILE__)}/hdd/received-sequences.dat"

    # assigning the failed sequences path
    @failed_file_path = "#{File.dirname(__FILE__)}/hdd/failed-sequences.dat"

    # assigning the processed sequences path
    @processed_file_path = "#{File.dirname(__FILE__)}/hdd/processed-sequences.dat"

    # creating the handles to the files
    begin
      # creating the handle to the received sequences file
      @received_handle = File.open(@received_file_path, 'a')

      # creating the handle to the failed sequences file
      @failed_handle = File.open(@failed_file_path, 'a')

      # creating the handle to the processed sequences file
      @processed_handle = File.open(@processed_file_path, 'a')
    rescue Exception => e
      # building the error message
      msg = "Hard drive error. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # saves a sequence (it's raw data)
  def store_sequence(parsing_error, sequence_id, hour, sequence_bytes)
    begin
      # getting the current date and time
      now = Time.now()

      if parsing_error == ParsingErrorType::NO_ERROR
        # adding a line to the received sequences file
        @received_handle.write("#{now}\t\t\t#{sequence_id}\t\t\t#{hour}\t\t\t#{sequence_bytes}\n")
        @received_handle.flush()
      else
        # adding a line to the failed sequences file
        @failed_handle.write("#{now}\t\t\t#{sequence_id}\t\t\t#{hour}\t\t\t#{parsing_error}\t\t\t#{sequence_bytes}\n")
        @failed_handle.flush()
      end
    rescue Exception => e
      # building the error message
      msg = "Hard drive error. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # saves the processed sequence data
  def store_processed_sequence(sequence_id, hour, processed_sequence)
    begin
      # getting the current date and time
      now = Time.now()

      # getting the string representation of the processed sequence
      str_data = processed_sequence.to_s()

      # writing information to file
      @processed_handle.write("#{now}\t\t\t#{sequence_id}\t\t\t#{hour}\t\t\t#{str_data}\n")
      @processed_handle.flush()
    rescue Exception => e
      # building the error message
      msg = "Hard drive error. Original error message:\r\n'#{e.message}'"

      # writing message in console
      puts msg

      # raising the exception again
      raise e
    end
  end

  # gets the storage related information
  def print_storage_info()
    puts("Correctly received sequences file:\t#{@received_file_path}")
    puts("Wrongly received sequences file:\t#{@failed_file_path}")
    puts("Processed received sequences file:\t#{@processed_file_path}")
  end
end

# ----------------------------------------------------------------------------

# represents a ram data logger
class RamDataLogger < AbstractDataLogger
  # the constructor or initializer
  def initialize()
    # calling base constructor
    super()

    # indicating that this feature isn't implemented yet
    raise Exception.new('Feature not implemented yet.')
  end
end

# ----------------------------------------------------------------------------