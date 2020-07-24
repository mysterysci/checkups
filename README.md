# Checkups

## Status: Jul 2020

Ryan Laughlin gave a [great talk at RailsConf
2018](https://www.youtube.com/watch?v=gEAlhKaK2I4) introducing our team to this
concept of production checkups. Robb ran with it and I (chrismo :waves:) helped
a little along the way. We've released what we have out to the internets in case
anyone else wants to help out as well.

As of our initial version here (0.9.0), we've got the core code in place, and
some half-arsed Slack (for notifications) and Sidekiq integration (for custom
worker checks). The goal for a 1.0 release is to figure out the proper way to
handle 3rd party integrations.

We use this gem in production at mysteryscience.com and this code has been live
there for over a year.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'checkups'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install checkups

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mysterysci/checkups.


## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
