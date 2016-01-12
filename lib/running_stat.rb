require 'running_stat/version'

require 'redis'

require 'running_stat/redis_backend'
require 'running_stat/lua/push_datum'
require 'running_stat/lua/variance'
require 'running_stat/insufficient_data_error'
require 'running_stat/invalid_data_error'

class RunningStat
  BASE_KEY = 'running_stat:v1'

  # Returns an instance of RunningStat for the given dataset
  def self.instance(data_bucket, opts = {})
    new(data_bucket, opts)
  end

  def initialize(data_bucket, opts = {})
    @data_bucket = data_bucket
    @redis = opts[:redis]
  end

  # Adds a piece of numerical data to the dataset's stats
  def push(datum)
    redis.eval(Lua::PUSH_DATUM, [bucket_key], [Float(datum)])
  rescue ArgumentError => e
    raise InvalidDataError.new(e)  # datum was non-numerical
  end

  # Returns the number of data points seen, or 0 if the stat does not exist
  def cardinality
    redis.hget(bucket_key, RedisBackend::COUNT_FIELD).to_i
  end

  # Returns the arithmetic mean of data points seen, or 0.0 if non-existent
  def mean
    redis.hget(bucket_key, RedisBackend::MEAN_FIELD).to_f
  end

  # Returns the sample variance of the dataset so far, or raises
  # an InsufficientDataError if insufficient data (< 2 datapoints)
  # has been pushed
  def variance
    redis.eval(Lua::VARIANCE, [bucket_key], []).to_f
  rescue Redis::CommandError => e
    raise InsufficientDataError.new(e)  # only CommandError possible
  end

  # Returns the standard deviation of the dataset so far, or raises
  # an InsufficientDataError if insufficient data (< 2 datapoints)
  # has been pushed
  def std_dev
    Math.sqrt(variance)
  end

  # Resets the stat to reflect an empty dataset
  def flush
    redis.del(bucket_key)
  end

  private

  def redis
    @redis || Redis.current
  end

  def bucket_key
    "#{BASE_KEY}:#{@data_bucket}"
  end
end
