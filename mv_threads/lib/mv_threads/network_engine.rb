require 'socket'
require_relative './processing_engine'

# represents a network engine
class NetworkEngine < Object
  # represents the host (i'm guessing where the petition comes from)
  @host = nil

  # represents the port (i'm guessing where the petition comes from)
  @port = nil

  # represents the TCP server that will listen for connections
  @tcp_server = nil

  # represents the whole server thread
  @network_thread = nil

  # represents a handle to a connection made to this server
  @conn_handle = nil

  # represents the processing engine (the one that does all the hardwork)
  @processing_engine = nil

  # represents the thread that process the message in the Quewe
  @process_thread = nil

  # represents the listener thread of the server (listens data from client)
  @reader_thread = nil

  # represents the writer thread of the server (writes data to client)
  @writer_thread = nil

  # the constructor or initializer
  def initialize(host='localhost', port=4304, data_storage_type=DataStorageType::HDD)
    # storing the chosen host
    @host = host

    # storing the chosen port (4304 by default)
    @port = port

    # creating the TCP server
    @tcp_server = TCPServer.new(@host, @port)

    # creating a processing engine
    @processing_engine = ProcessingEngine.new(data_storage_type)

  end

  # starts the server tasks
  def start()
    # informing that the server has started
    puts "Server running...yoidel's version"

    # waiting for client connections (1 single connection)
    begin
      @network_thread = Thread.start(@tcp_server.accept) do |handle|
        # informing that a connection has been made
        puts 'Connection established with client...'

        # storing the handle to the connection
        @conn_handle = handle

        # starting the processing engine and
       # @process_thread = @processing_engine.start()

        # thread for listening data sent by client
        @reader_thread = listen_data_from_client()

        # sending data to client
        @writer_thread = send_data_to_client()

        # waiting for the ''@reader_thread' and the '@writer_thread'
        [@process_thread, @reader_thread, @writer_thread].each { |t|
          unless t.nil?
            t.join()
          end
        }
      end
    rescue Exception => e
      # building error message
      msg = "Unknown socket error. Original error message:\r\n#{e.message}"

      #print the message if its exist
      unless e.message.strip.size==0
        # printing error message
        puts msg
      end
    end
  end

  # stops the server tasks
  def stop()
    # stopping working threads
    stop_working_threads()

    # if the connection is still open (it isn't nil)
    if @conn_handle
      # actually closing the connection
      @conn_handle.close()

      # informing that the connection has been closed
      puts 'Connection has been closed....'
    end

    # informing that the server has been stopped
    puts 'Server has been stopped....'
  end

  private
  # listens data from a TCP/IP connection
  def listen_data_from_client()
    # creating a reader thread
    Thread.new do
      # looping until the end of time
      loop do
        # reading the sequence length (the 2 initial bytes)
        sequence_header = @conn_handle.recv(2)

        # if we didn't received anything
        if sequence_header == nil or sequence_header.size() == 0
          # continue the loop
          next
        end

        # building the whole sequence
        sequence = get_sequence(sequence_header)
        # puts "--- #{sequence}\t ---"

        # adding the job for processing
        @processing_engine.add_job_to_process(sequence)
      end
    end
  end

  # sends data through a TCP/IP connection
  def send_data_to_client()
    # creating a writer thread
    Thread.new do
      # looping until the end of time

      #loop do

      #sleep(1)
      #puts("Sending data to client at time:\t#{Time.now()}")

      ### 'sending' retry data to client
      ###TODO: get elements from @retry_job_queue and send it to client for retry
      #puts("Sending data to client at time:\t#{Time.now()}")
      #sleep(5)

      #end

    end
  end

  # same code from old server
  def get_sequence(sequence_header)
    # reading the rest of the sequence
    l1 = sequence_header[0].unpack('B*')
    l2 = sequence_header[1].unpack('B*')

    # total data to read from client
    length = l1[0].to_i(2) + l2[0].to_i(2)

    # bytes to read from client
    bytes_to_read = length - 2

    # getting sequence data sent by client
    sequence_data = @conn_handle.recv(bytes_to_read)

    # building the whole sequence
    return sequence_header + sequence_data
  end

  # stops working threads
  def stop_working_threads()
    # killing each one of the created threads
    [@network_thread, @process_thread, @reader_thread, @writer_thread].each do |t|
      unless t.nil?
        Thread.kill(t);
      end
    end
  end
end