# RunningStat

[![Build Status](https://travis-ci.org/anujdas/running_stat.png?branch=master)](https://travis-ci.org/anujdas/running_stat)

[![Gem Version](https://badge.fury.io/rb/running_stat.png)](http://badge.fury.io/rb/running_stat)

RunningStat provides distributed redis-backed data buckets on which various statistics are calculated live without storing the datapoints themselves: cardinality, average (arithmetic mean), standard deviation, and variance. Numbers (integer or float) can be pushed into buckets atomically. The space and time overhead for each metric is constant and invariant under data cardinality.

RunningStat is especially useful in applications such as:
- logging unusually large requests, i.e., > 2 standard deviations outside the mean
- tracking metrics about interaction behaviour patterns, like engagement times

In these cases and others, RunningStat provides up-to-date information without the time and storage overhead of saving a growing dataset.

The algorithm used is based on Knuth's TAOCP and is numerically stable; a brief writeup is available on Wikipedia under [Algorithms for calculating online variances](https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm).

RunningStat supports pretty much all versions of ruby, including MRI 1.8.7, 1.9.3, 2.2, and JRuby 1.7/9k.

Disclaimer: Because it uses atomic Lua scripting, RunningStat requires redis 2.6+.


## Quickstart

RunningStat is easy to use. Since it depends on redis, you need to have a configured [Redis](https://github.com/redis/redis-rb) instance ([ConnectionPool](https://github.com/mperham/connection_pool) wrapper highly recommended/practically mandatory if your app is multithreaded). By default, RunningStat will use `Redis.current`, but you can pass a redis instance to the constructor in the `:redis` key, for example if you're using ConnectionPool:

```ruby
stat = RunningStat.instance('my_bucket')  # uses Redis.current
# or
stat = RunningStat.instance('my_bucket', redis: Redis.new(db: 1))  # uses db 1 for stats
# or
stat = $redis_pool.with { |redis| RunningStat.new('my_bucket', redis: redis) }  # checks out from pool
```

Now, for anything you want to measure, pick a bucket name and push your data:

```ruby
stat = RunningStat.instance('my_bucket')
stat.push(1)
stat.push(100.0)
stat.push(-10)
```

At any point, you can obtain stats about the data seen so far in a given bucket:

```ruby
> stat = RunningStat.instance('my_bucket')
 => #<RunningStat instance>
> stat.cardinality
 => 3
> stat.mean
 => 30.333333333333
> stat.std_dev
 => 60.58327602014685
> stat.variance
 => 3670.3333333333
```

Reads and writes are both O(1); stats are calculated on insert, so reads are fast.

Note that by definition, standard deviation and sample variance are undefined for datasets of cardinality < 2; you'll see a RunningStat::InsufficientDataError raised instead.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'running_stat'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install running_stat


## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. RunningStat's specs require a running redis server on localhost:6379 because no Ruby redis mock supports Lua scripting yet. Note that running the specs *WILL MODIFY* some contents on your redis instance; save your data beforehand if it is important.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Contributing

Contributions are welcome. [Fork the project](https://github.com/anujdas/running_stat) and send pull requests.
