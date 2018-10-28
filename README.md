# Data2ruby

Convert an heterogeneous tree structure in nested `ActiveModel::Model` objects.

For instance, if you have a JSON object describing a train journey:

```json
{
  "id": 987,
  "connections": [
    {
      "start": "London",
      "finish": "Paris",
      "departure_time": "2015-07-11T09:23:00+01:00",
      "arrival_time": "2015-07-11T12:41:00+02:00",
      "fare": {
        "currency": "GBP",
        "value": 159.0
      }
    },
    {
      "start": "Paris",
      "finish": "Barcelona",
      "departure_time": "2015-07-11T13:56:00+02:00",
      "arrival_time": "2015-07-11T20:17:00+02:00",
      "fare": {
        "currency": "GBP",
        "value": 50.0
      }
    }
  ]
}
```

You can define a Ruby class describing it as

```ruby
class TravelOption
  include Data2ruby

  has_one :journey do
    attr_accessor :id
    validates_numericality_of :id, only_integer: true

    has_many :connections do
      attr_accessor :start, :finish, :departure_time, :arrival_time
      validates_presence_of :start, :finish, :departure_time, :arrival_time

      has_one :fare do
        attr_accessor :currency, :value
        validates_presence_of :currency
        validates_numericality_of :value
      end
    end
  end
end
```

Then instantiate and validate:

```ruby
travel_option = TravelOption.new(JSON.parse(json_string))

# run ActiveModel validations
travel_option.valid_structure? # => true
travel_option.invalid_items # => []

# navigate the associations
travel_option.journey.id # => 987
travel_option.connections[0].start # => "London"
travel_option.connections[0].fare.currency # => "GBP"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rmaestroni/data2ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
