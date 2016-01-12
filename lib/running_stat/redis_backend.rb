class RunningStat
  module RedisBackend
    # fields within the metric's redis hash
    COUNT_FIELD = :c  # the dataset cardinality
    MEAN_FIELD = :m  # the arithmetic mean of the dataset
    M2_FIELD = :m2  # the running sum of the squares of the differences of the dataset

    # TODO: implement global redis set/get
  end
end
