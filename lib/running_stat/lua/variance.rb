require 'digest/sha1'
require 'running_stat/insufficient_data_error'

class RunningStat
  module Lua
    # Keys:
    #   count - the dataset cardinality
    #   m2 - the running sum of the squares of the differences of the dataset
    # Arguments:
    #   nothing
    # Effects:
    #   nothing
    # Returns:
    #   the sample variance of the dataset, as a stringified float
    VARIANCE = <<-EOLUA
      local count_key = KEYS[1]
      local m2_key = KEYS[2]

      local count = tonumber(redis.call("GET", count_key)) or 0
      if count < 2 then
        return redis.error_reply("#{InsufficientDataError::ERROR_STRING}")
      else
        local m2 = tonumber(redis.call("GET", m2_key)) or 0.0
        return tostring(m2 / (count - 1))
      end
    EOLUA

    VARIANCE_SHA1 = Digest::SHA1.hexdigest(VARIANCE).freeze
  end
end
