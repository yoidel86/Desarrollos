require_relative './mv_threads/network_engine'

#require 'optparse'
require_relative './mv_threads/data_storage_type'
require_relative './mv_threads/db/db_create'
require_relative './mv_threads/db/db_migrate'
require_relative './mv_threads/db/models/json_sequence'

#require "#{File.dirname(__FILE__)}/mv_threads/db/db_create"
#require "#{File.dirname(__FILE__)}/mv_threads/db/db_migrate"
#require "#{File.dirname(__FILE__)}/mv_threads/db/models/json_sequence"

# -------------------------------------------------------

# the front end class of the gem
class MvThreads
  # host where the network engine will run
  @@host = Socket::getaddrinfo(Socket.gethostname, 'echo', Socket::AF_INET)[0][3]

  # port where the network engine will run
  @@port = 4304

  # path of the file used to have an instance running
  @@mv_pid_path = "#{File.dirname(__FILE__)}/mv_threads.pid"

  # index of the 'pid' data
  @@pid_data_idx = 0

  # index of the 'time' data
  @@time_data_idx = 1

  # start method
  def self.start(data_storage_type=DataStorageType::HDD)
    begin
      # writing this process 'pid' and 'start time' to file
      File.write(@@mv_pid_path, "#{Process.pid}\n#{DateTime.now}")

      # creating a network engine
      network_engine = NetworkEngine.new(@@host, @@port, data_storage_type)

      # starting the network engine
      network_thread = network_engine.start()

      # waiting for the network thread
      network_thread.join()
    rescue Exception => e
      # building the error message
      msg = "Unknown error during execution. Original error message:\r\n"+e.message+"\r\n Cause:\r\n"+e.cause

      unless e.message.strip.size == 0
        # writing message in console
        puts msg
      end

      # if the network engine was created
      if network_engine
        # stopping network engine
        network_engine.stop()
      end
    end
  end

  def self.status()
    # connecting to db
    connect_to_db()

    # getting the process data
    p_data = get_process_data()

    # getting the 'pid' of mv_threads
    mv_pid = get_mv_pid(p_data[@@pid_data_idx])

    # getting the start 'time' of mv_threads
    if p_data.count < 2
      mv_start_time = 'No started'
    else
      mv_start_time = get_mv_start_time(p_data[@@time_data_idx])
    end

    # getting the record count
    rows_count = JsonSequence.count()

    # if the mv_threads 'pid' is valid (meaning it's already running)
    if mv_pid > 0
      puts "MvThreads process status:\tRunning"
      puts "MvThreads process host:\t#{@@host}"
      puts "MvThreads process port:\t#{@@port}"
      puts "MvThreads process pid:\t\t#{mv_pid}"
      puts "MvThreads running since:\t#{mv_start_time}"
      puts "MvThreads db record count:\t#{rows_count}"
    else
      puts "MvThreads process status:\tNot Running"
      puts "MvThreads running since:\t#{mv_start_time}"
      puts "MvThreads db record count:\t#{rows_count}"
    end
  end

  private
  def self.get_process_data()
    # checking if file exists
    unless File.exists?(@@mv_pid_path)
      return nil
    end

    # returning the lines of the file
    File.readlines(@@mv_pid_path)
  end

  def self.get_mv_pid(pid_data)
    begin
      # reading pid from file
      pid = pid_data.to_i()

      # invalid pid number stored in file (eg: "", "hello", etc.)
      if pid <= 0
        return 0
      end

      # checking if pid is alive
      Process.kill(0, pid)

      # returning the pid (at this moment a valid pid)
      return pid
    rescue Errno::ESRCH
      return 0
    end
  end

  def self.get_mv_start_time(time_data)
    return DateTime.strptime(time_data, '%Y-%m-%dT%H:%M:%S%z')
  end

  # sets a connection to the database by means of activerecord
  def self.connect_to_db()
    # setting the db config path
    db_config_path = "#{File.dirname(__FILE__)}/mv_threads/db/database.yml"

    # setting up database configuration
    set_up_db_configuration(db_config_path)

    # connecting to the database
    connect_to_database(db_config_path)
  end
end

# -------------------------------------------------------

## represents a mapper for the possible values of the data loggers
#DATA_LOGGER_MAPPER = {
#  # database data logger
#  'db' => DataStorageType::DB,
#
#  # hard drive data logger
#  'hdd' => DataStorageType::HDD
#}
#
## represents the data_logger selected by the user
#options = {}
#
##create parsers
#opts = OptionParser.new()
#
#opts.banner = "Usage: #{File.basename(__FILE__)} [command] [options]"
#
#opts.on('-l', '--logger-type LOGGER_TYPE', 'Selects the type of data logger to use.') do |v|
#    # storing the selected logger type
#    options[:data_logger_type] = v.downcase()
#end
#
##Define your own --help
#opts.on('-h', '--help [HELP]', 'Displays the help of this product (use --help=full for further information).') do |v|
#  # depending on the value of v
#  case v
#
#    # writing the original help
#    when 'full' # write original help
#      # printing the original and a couple of extra examples
#      puts opts.help
#      puts ''
#      puts "Examples:\r\n#{File.basename(__FILE__)} -logger-type DB\r\n#{File.basename(__FILE__)} -logger-type HDD"
#
#    # if we got nothing as parameter for help (write script specific help)
#    when nil, ''
#      # printing banner
#      puts opts.banner
#      opts.summarize([], opts.summary_width ) { |helpline| puts helpline }
#
#    # otherwise
#    else
#      # printing banner
#      puts opts.banner
#
#      # printing help message
#      puts <<helpmessage
#Undefined --help option. Please use 'full' or no option
#  #{File.basename(__FILE__)} --help
#  #{File.basename(__FILE__)} --help=full
#helpmessage
#  end
#end

# -------------------------------------------------------

#begin
#  # actually performing the parsing process
#  opts.parse!()
#
#  # if the data logger was provided
#  if options.has_key?(:data_logger_type)
#    # validating the data logger
#    unless DATA_LOGGER_MAPPER.has_key?(options[:data_logger_type])
#      raise Exception.new('Invalid data logger.')
#    end
#
#    # getting the data logger
#    data_logger = DATA_LOGGER_MAPPER[options[:data_logger_type]]
#
#    # configuring database if selected by the user
#    if data_logger == DataStorageType::DB
#      puts 'Performing database configurations. Please wait...'
#
#      # setting the db config path
#      db_config_path = './mv_threads/db/database.yml'
#
#      # setting up database configuration
#      set_up_db_configuration(db_config_path)
#
#      # creating the database
#      create_db()
#
#      # connecting to the database
#      connect_to_database(db_config_path)
#
#      # running the migrations
#      run_migrations()
#    end
#
#    # actually running the service
#    MvThreads.start(host='localhost', port=4304, data_storage_type=data_logger)
#  end
#
##in case of an exception
#rescue Exception => e
#  # print the exception message
#  puts "Original error:\r\n#{e.message}"
#
#  puts ''
#
#  # printing the help
#  puts opts.help()
#
#  # exiting
#  exit(1)
#end

# MvThreads.start(data_storage_type=DataStorageType::DB)
# MvThreads.start()