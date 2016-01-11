# simple ruby implementation of various statistical methods
module Statistics
  class << self
    def sum(data)
      data.inject(:+)
    end

    def mean(data)
      sum(data).to_f / data.count
    end

    def variance(data)
      m = mean(data)
      sum_sq_diffs = data.inject(0) { |acc, datum| acc + (datum - m) ** 2 }
      sum_sq_diffs.to_f / (data.count - 1)
    end

    def standard_deviation(data)
      Math.sqrt(variance(data))
    end
  end
end
