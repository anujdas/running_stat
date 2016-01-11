require 'digest/sha1'

class RunningStat
  module Lua
    # Keys:
    #   count - the dataset cardinality
    #   mean - the mean of the dataset so far
    #   m2 - the running sum of the squares of the differences of the dataset
    # Arguments:
    #   datum - the number to be added to the dataset
    # Effects:
    #   calculates running stats (mean, variance, std_dev)
    # Returns:
    #   nothing
    PUSH_DATUM = <<-EOLUA
      local count_key = KEYS[1]
      local mean_key = KEYS[2]
      local m2_key = KEYS[3]
      local datum = ARGV[1]

      local mean = tonumber(redis.call("GET", mean_key)) or 0.0
      local delta = datum - mean

      local count = redis.call("INCR", count_key)
      mean = redis.call("INCRBYFLOAT", mean_key, tostring(delta / count))
      redis.call("INCRBYFLOAT", m2_key, tostring(delta * (datum - mean)))
    EOLUA

    PUSH_DATUM_SHA1 = Digest::SHA1.hexdigest(PUSH_DATUM).freeze
  end
end
