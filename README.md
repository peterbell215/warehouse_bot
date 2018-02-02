# WarehouseBot

Hopefully, you recognise this picture.  You start developing a new Rails app.  You start writing tests in RSpec.  You use FactoryBot to create the test data.  Initially it all goes well and the tests run in no time at all.  However, as the project grows, so does the run time for the tests.

Enter WarehouseBot.  It's a bit of a word play on FactoryBot.  While FactoryBot manufacturers test data, WarehouseBot looks in its warehouse whether the data already exists.  If not, it gets FactoryBot to make the data and stores it in the warehouse (i.e. a caching directory with YAML fixture files).  If the data already exists, then it simply loads the data.

This should help, particularly given the more functional style of RSpecs that seems to be favoured these days:

```Ruby
RSpec.describe SomeModel, type: :model do
  before do
    # .. setup some base test data
  end

  describe 'usage under certain conditions' do
    subject { FactoryBot.create :some_model_example }
    
    before do
      # .. setup some test data specific to this situation
    end
    
    specify { expect(subject.method1).to eq(outcome1)  }
    specify { expect(subject.method2).to eq(outcome2)  }
    specify { expect(subject.method3).to be_nil  }    
  end
end
```

In this simple example the base test data, test specific data and the subject are all generated three
times to execute the individual RSpec tests.  This would get even worse if this was shared examples, for example being tested against different user's permissions.

## Installation

Add this line to your application's Gemfile within the test section:

```ruby
group :test do
  # .. other gems
  gem 'warehouse_bot'
end
```
And then execute:

    $ bundle

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/peterbell215/warehouse_bot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
