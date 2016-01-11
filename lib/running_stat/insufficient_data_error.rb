class RunningStat
  # Raised when < 2 data points are provided
  class InsufficientDataError < RuntimeError
    ERROR_STRING = 'Insufficient Data'.freeze
  end
end
