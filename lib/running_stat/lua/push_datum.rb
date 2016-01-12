require 'digest/sha1'
require 'running_stat/redis_backend'

class RunningStat
  module Lua
    # Keys:
    #   bucket - the hash corresponding to the dataset metric
    # Arguments:
    #   datum - the number to be added to the dataset
    # Effects:
    #   calculates running stats (mean, variance, std_dev)
    # Returns:
    #   nothing
    PUSH_DATUM = <<-EOLUA
      local bucket_key = KEYS[1]
      local datum = ARGV[1]

      local mean = tonumber(redis.call("HGET", bucket_key, "#{RedisBackend::MEAN_FIELD}")) or 0.0
      local delta = datum - mean

      local count = redis.call("HINCRBY", bucket_key, "#{RedisBackend::COUNT_FIELD}", 1)
      mean = redis.call("HINCRBYFLOAT", bucket_key, "#{RedisBackend::MEAN_FIELD}", tostring(delta / count))
      redis.call("HINCRBYFLOAT", bucket_key, "#{RedisBackend::M2_FIELD}", tostring(delta * (datum - mean)))
    EOLUA

    PUSH_DATUM_SHA1 = Digest::SHA1.hexdigest(PUSH_DATUM).freeze
  end
end
