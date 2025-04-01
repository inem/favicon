#!/usr/bin/env ruby
# frozen_string_literal: true

# Example of basic usage of FaviconGet

# Add path to local gem if it's not installed
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'favicon_get'
require 'open-uri'

# Test URL
url = ARGV[0] || 'https://www.ruby-lang.org/'

puts "Getting icons for #{url}..."

begin
  # Get all icons
  icons = FaviconGet.get(url)

  if icons.empty?
    puts "No icons found for #{url}"
    exit(1)
  end

  puts "Found #{icons.size} icons:"

  # Display information about each icon
  icons.each_with_index do |icon, i|
    puts "[#{i + 1}] #{icon.url} (#{icon.width}x#{icon.height}, format: #{icon.format})"
  end

  # Download the biggest icon
  biggest_icon = icons.first
  puts "\nDownloading the biggest icon: #{biggest_icon.url}"

  output_path = "/tmp/favicon-example.#{biggest_icon.format}"

  URI.open(biggest_icon.url) do |image|
    File.open(output_path, 'wb') do |file|
      file.write(image.read)
    end
  end

  puts "Icon saved to #{output_path}"
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1)
end
