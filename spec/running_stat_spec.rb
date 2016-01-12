require 'spec_helper'

describe RunningStat do
  let(:bucket) { 'test_bucket' }
  let(:count_field) { described_class::RedisBackend::COUNT_FIELD }

  subject(:running_stat) { RunningStat.instance(bucket) }

  let(:data) { 1..10 }
  let(:epsilon) { 0.000001 }  # close enough for rounding errors

  describe '.instance' do
    it 'allows operations on a data bucket given only its name' do
      data.each do |datum|
        RunningStat.instance(bucket).push(datum)
      end
      expect(running_stat.cardinality).to eq data.count
    end

    it 'defaults to Redis.current' do
      RunningStat.instance(bucket).push(data.first)
      expect(Redis.current.exists(running_stat.send(:bucket_key))).to be_truthy
    end

    context 'with an explicit redis connection' do
      let(:alt_redis) { Redis.new(:db => 1) }
      before { alt_redis.flushdb }
      after { alt_redis.flushdb }
      it 'uses the alternate redis connection' do
        RunningStat.instance(bucket, :redis => alt_redis).push(data.first)
        expect(Redis.current.exists(running_stat.send(:bucket_key))).to be_falsey
        expect(alt_redis.exists(running_stat.send(:bucket_key))).to be_truthy
      end
    end
  end

  describe '#push' do
    context 'with no data points' do
      before { running_stat.push(data.first) }
      it 'creates the bucket and adds the data point' do
        expect(Redis.current.exists(running_stat.send(:bucket_key))).to be_truthy
        expect(Redis.current.hget(running_stat.send(:bucket_key), count_field)).to eq '1'
      end
    end

    context 'with data points in the bucket' do
      before do
        running_stat.push(data.to_a[0])
        running_stat.push(data.to_a[1])
      end
      it 'adds the data point' do
        expect(Redis.current.hget(running_stat.send(:bucket_key), count_field)).to eq '2'
      end
    end

    it 'rejects non-numerical data' do
      expect { running_stat.push('abc') }.to raise_error(described_class::InvalidDataError)
    end
  end

  describe '#cardinality' do
    context 'with no data points' do
      it 'is zero' do
        expect(running_stat.cardinality).to eq 0
      end
    end

    it 'increments with each insertion' do
      data.each do |datum|
        expect { running_stat.push(datum) }.
          to change { running_stat.cardinality }.by(1)
      end
    end
  end

  describe '#mean' do
    context 'with no data points' do
      it 'is zero' do
        expect(running_stat.mean).to eq 0
      end
    end

    context 'with one data point' do
      before { running_stat.push(data.first) }
      it 'equals the datum' do
        expect(running_stat.mean).to eq data.first
      end
    end

    it 'returns the mean of inserted data as a float' do
      data.each { |datum| running_stat.push(datum) }

      expect(running_stat.mean).to be_a Float
      expect(running_stat.mean).to eq Statistics.mean(data)
    end
  end

  describe '#variance' do
    context 'with no data points' do
      it 'raises an error' do
        expect { running_stat.variance }.to raise_error(described_class::InsufficientDataError)
      end
    end

    context 'with one data point' do
      before { running_stat.push(data.first) }
      it 'raises an error' do
        expect { running_stat.variance }.to raise_error(described_class::InsufficientDataError)
      end
    end

    it 'returns the sample variance of inserted data as a float' do
      data.each { |datum| running_stat.push(datum) }

      expect(running_stat.variance).to be_a Float
      expect(running_stat.variance).to be_within(epsilon).of(Statistics.variance(data))
    end
  end

  describe '#std_dev' do
    context 'with no data points' do
      it 'raises an error' do
        expect { running_stat.std_dev }.to raise_error(described_class::InsufficientDataError)
      end
    end

    context 'with one data point' do
      before { running_stat.push(data.first) }
      it 'raises an error' do
        expect { running_stat.std_dev }.to raise_error(described_class::InsufficientDataError)
      end
    end

    it 'returns the standard deviation of inserted data as a float' do
      data.each { |datum| running_stat.push(datum) }

      expect(running_stat.std_dev).to be_a Float
      expect(running_stat.std_dev).to be_within(epsilon).of(Statistics.standard_deviation(data))
    end
  end

  describe '#flush' do
    before { data.each { |datum| running_stat.push(datum) } }
    it 'resets the stat bucket' do
      expect { running_stat.flush }.
        to change { running_stat.cardinality }.from(data.count).to(0)
      expect(running_stat.mean).to eq 0
    end
  end
end
