require 'socket'
ip = Socket::getaddrinfo(Socket.gethostname, 'echo', Socket::AF_INET)[0][3]
puts ip
puts ip.class