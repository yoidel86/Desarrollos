LOCK_FILE_PATH = "#{File.dirname(__FILE__)}/mv_threads.pid"


def get_mv_pid()
  begin
    # checking if file exists
    unless File.exists?(LOCK_FILE_PATH)
      return 0
    end

    # reading pid from file
    pid = File.open(LOCK_FILE_PATH, 'r').read().to_i()

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


mv_pid = get_mv_pid()
if mv_pid > 0
  puts "MvThreads process status:\tRunning"
  puts "Process Id:\t\t#{mv_pid}"
else
  # writing pid to file
  File.write(LOCK_FILE_PATH, "#{Process.pid()}")
  # File.open(LOCK_FILE_PATH, 'w') { |file| file.write("#{Process.pid()}"); file.flush() }

  # algorithms running... (20 seconds)
  puts 'algorithms running... (20 seconds)'

  # all good and we ca run the code
  sleep(20)

  puts 'algorithm finished'

  # File.delete(LOCK_FILE_PATH)
end