# FaviconGet

FaviconGet is a Ruby gem for finding and retrieving website favicons (icons). It's a port of the popular [favicon](https://github.com/scottwernervt/favicon) Python library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'favicon_get'
```

And then execute:

```bash
$ bundle install
```

Or install it manually:

```bash
$ gem install favicon_get
```

## Usage

### Get all icons

```ruby
require 'favicon_get'

icons = FaviconGet.get('https://www.ruby-lang.org/')
# => [Icon, Icon, Icon, ...]

# The first icon is usually the largest
icon = icons.first
puts "URL: #{icon.url}"
puts "Size: #{icon.width}x#{icon.height}"
puts "Format: #{icon.format}"
```

### Download an icon

```ruby
require 'favicon_get'
require 'open-uri'

icons = FaviconGet.get('https://www.ruby-lang.org/')
icon = icons.first

URI.open(icon.url) do |image|
  File.open("/tmp/ruby-favicon.#{icon.format}", "wb") do |file|
    file.write(image.read)
  end
end

# => /tmp/ruby-favicon.png
```

### Additional parameters

```ruby
require 'favicon_get'

# Custom headers
headers = {
  'User-Agent' => 'My custom User-Agent'
}

# Timeout and other parameters
FaviconGet.get('https://www.ruby-lang.org/',
                headers: headers,
                timeout: 5)
```

### Icon object

Each icon is represented by the `Icon` struct with the following attributes:

- `url` - Full URL to the icon file
- `width` - Icon width in pixels (0 if unknown)
- `height` - Icon height in pixels (0 if unknown)
- `format` - File format/extension (e.g., 'ico', 'png')

Icons are sorted by size (larger first) and format priority.

## Development

After checking out the repo, run `make setup` to install dependencies.

You can use the following Makefile commands for development:

- `make test` - Run tests
- `make console` - Get an interactive prompt with the gem loaded
- `make example` - Run the example script
- `make build` - Build the gem
- `make install` - Install the gem locally
- `make up` - Increment patch version (e.g., 0.1.0 → 0.1.1)
- `make up!` - Increment minor version (e.g., 0.1.1 → 0.2.0)
- `make push` - Push gem to RubyGems.org (requires permissions)

## Requirements

* [nokogiri](https://github.com/sparklemotion/nokogiri) - for HTML parsing
* [faraday](https://github.com/lostisland/faraday) - for HTTP requests
* [faraday-follow_redirects](https://github.com/tisba/faraday-follow-redirects) - for following HTTP redirects

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/inem/favicon.
