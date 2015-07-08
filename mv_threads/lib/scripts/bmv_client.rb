require 'socket'

# initializing in nil
sock = nil

# attempting to create the socket until achieved
begin
  # creating the socket
  sock = TCPSocket.new(Socket::getaddrinfo(Socket.gethostname, 'echo', Socket::AF_INET)[0][3], 4304)
rescue Exception
  retry
end

puts('Connected to server...')

# path where the sequences are stored
sequences_path = './sequences.txt'

seq_counter = 1
puts("Seq. id\t\tSeq. length\t\tSeq. data")
File.open(sequences_path, 'rt', encoding: Encoding::ASCII_8BIT).readlines.each do |sequence|
  # removing line break (\n)
  sequence = sequence[0...sequence.length() - 1]

  # writing the sequence
  puts("#{seq_counter}\t\t\t#{sequence.length()}\t\t\t\t#{sequence}")

  # sending data through socket
  sock.write(sequence)

  # counting the sequences
  seq_counter += 1
end

# closing the socket
sock.close()