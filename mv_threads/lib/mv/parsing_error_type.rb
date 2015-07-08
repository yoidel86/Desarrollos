# represents an enum (classic C# enum) for the error types
module ParsingErrorType
  # represents a 'no error' while parsing (all good)
  NO_ERROR = 1

  # represents an error while verifying the 'checksum'
  CHECKSUM_ERROR  = 2

  # represents an error in the message type
  UNSUPPORTED_MSG_TYPE_ERROR = 4

  # represents an error when the message size does not match with the size established by BMV
  MSG_SIZE_MISMATCH = 8

  # represents an unknown error (used when we couldn't classify the error)
  UNKNOWN_ERROR = 16
end