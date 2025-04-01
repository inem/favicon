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

## Requirements

* [nokogiri](https://github.com/sparklemotion/nokogiri) - for HTML parsing
* [faraday](https://github.com/lostisland/faraday) - for HTTP requests

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
