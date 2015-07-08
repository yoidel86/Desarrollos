require_relative './data_storage_type'
require_relative './parsing_engine'
require_relative './data_loggers'
require_relative './db/models/received_sequence'
require_relative './db/models/failed_sequence'

# represents a processing engine
class ProcessingEngine < Object
  # represents the jobs (taks) queue
  @jobs_queue = nil

  # represents the queue of jobs (taks) to retry by any possible error in the processing
  @retry_jobs_queue = nil

  # represents the type of data storage to use
  @data_storage_type = nil

  # represents the parsing engine for the message bytes
  @parsing_engine = nil

  # represents a data logger for information storing
  @data_logger = nil

  # represents the main worker thread
  @worker_thread = nil

  # the constructor or initializer
  def initialize(data_storage_type=DataStorageType::HDD)
    # creating a new queue (it's thread safe)
    @jobs_queue = Queue.new()

    # creating a new retry queue of jobs
    @retry_jobs_queue = Queue.new()

    # storing the selected data storage type
    @data_storage_type = data_storage_type

    # creating a parsing engine
    @parsing_engine = ParsingEngine.new()

    # creating the data logger
    @data_logger = create_logger_from_type(data_storage_type)
  end

  # processes the jobs in the @job_queue
  def start()
    # creating a processing thread
    # @worker_thread = Thread.new do
    Thread.new do
      # looping indefinitely (til the end of time or the application is killed)
      loop do
        # if the @jobs_queue has jobs, then do them
        if amount_of_unprocessed_jobs <= 0
          # continue to the loop
          next
        end

        # getting the job to process (performing dequeue)
        sequence_bytes = @jobs_queue.deq()

        # parsing the sequence raw data (it's bytes)
        parsing_error, parsed_sequence = parse_sequence_bytes(sequence_bytes)

        # if it makes sense to retry
        if error_deserves_retry(parsing_error)
          # adding to '@retry_jobs_queue'
          @retry_jobs_queue.enq(sequence_bytes)
        else
          # storing the sequence information
          store_sequence_bytes(parsing_error, sequence_bytes)
        end

        # if there was no error while parsing
        if parsing_error == ParsingErrorType::NO_ERROR
          # storing the parsed sequence
          store_sequence_info(sequence_bytes, parsed_sequence)
        end

      end
    end
  end

  # stops the processing engine
  def stop()
    # stopping all the working threads
    stop_working_threads()
  end

  # adds a new job to the jobs queue
  def add_job_to_process(job_data)
    # pushing the needed data to perform the job (sequence bytes in this case)
    @jobs_queue.enq(job_data)
  end

  # gets the amount of unprocessed jobs
  def amount_of_unprocessed_jobs()
    # returning the amount of elements in '@jobs_queue'
    return @jobs_queue.size()
  end

  # gets the amount of failed jobs
  def amount_of_failed_jobs()
    # returning the amount of elements in '@retry_jobs_queue'
    return @retry_jobs_queue.size()
  end

  # gets the first failed job
  def get_first_failed_job()
    # the first failed job if any, nil otherwise
    return (@retry_jobs_queue.size() > 0)?  @retry_jobs_queue.deq() : nil
  end

  # private members
  private
  # creates a data logger from depending on the 'data_storage_type'
  def create_logger_from_type(data_storage_type)
    case data_storage_type
      # if DB storage chosen
      when DataStorageType::DB then
        return DatabaseDataLogger.new()

      # if HDD storage chosen
      when DataStorageType::HDD then
        return HardDriveDataLogger.new()

      # if RAM storage chosen
      when DataStorageType::RAM then
        return RamDataLogger.new()

      # otherwise
      else
        raise Exception.new('Unknown data storage type.')
    end
  end

  # parses the given sequence bytes
  def parse_sequence_bytes(sequence_bytes)
    # parsing the sequence bytes (information) with the parsing engine
    return @parsing_engine.parse_sequence(sequence_bytes)
  end

  # indicates wether an error deserves a retry
  def error_deserves_retry(parsing_error)
    # depending on the parsing error
    case parsing_error
      # if we are in presence of a checksum error
      when ParsingErrorType::CHECKSUM_ERROR
        return true
      # otherwise
      else
        return false
    end
  end

  # stores the sequence raw data (it's bytes) and some other basic information
  def store_sequence_bytes(error_type, sequence_bytes)
    # getting the sequence id from the 'sequence_bytes'
    sequence_id = @parsing_engine.get_sequence_id(sequence_bytes)

    # getting the hour (timestamp) from the data transmission
    hour = @parsing_engine.get_sequence_hour(sequence_bytes)

    # simply storing the sequence raw data using the 'data_logger'
    @data_logger.store_sequence(error_type, sequence_id, hour, sequence_bytes)
  end

  # stores the sequence parsed information
  def store_sequence_info(sequence_bytes, parsed_sequence)
    # getting the sequence id from the 'sequence_bytes'
    sequence_id = @parsing_engine.get_sequence_id(sequence_bytes)

    # getting the hour (timestamp) from the data transmission
    hour = @parsing_engine.get_sequence_hour(sequence_bytes)

    # simply storing the parsed sequence
    @data_logger.store_processed_sequence(sequence_id, hour, parsed_sequence)
  end

  # stops working threads
  def stop_working_threads()
    # killing each one of the created threads
    #[@worker_thread].each { |t| Thread.kill(t) }
  end
end