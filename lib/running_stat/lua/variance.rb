require 'digest/sha1'
require 'running_stat/redis_backend'
require 'running_stat/insufficient_data_error'

class RunningStat
  module Lua
    # Keys:
    #   bucket - the hash corresponding to the dataset metric
    # Arguments:
    #   nothing
    # Effects:
    #   nothing
    # Returns:
    #   the sample variance of the dataset, as a stringified float
    VARIANCE = <<-EOLUA
      local bucket_key = KEYS[1]

      local values = redis.call("HMGET", bucket_key, "#{RedisBackend::COUNT_FIELD}", "#{RedisBackend::M2_FIELD}")
      local count = tonumber(values[1]) or 0
      if count < 2 then
        return redis.error_reply("#{InsufficientDataError::ERROR_STRING}")
      else
        local m2 = tonumber(values[2]) or 0.0
        return tostring(m2 / (count - 1))
      end
    EOLUA

    VARIANCE_SHA1 = Digest::SHA1.hexdigest(VARIANCE).freeze
  end
end
