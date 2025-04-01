# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class TestFavicon < Minitest::Test
  include WebMockHelpers

  def setup
    WebMock.disable_net_connect!
  end

  def teardown
    WebMock.reset!
  end

  def test_default_icon_urls
    urls = [
      ['http://mock.com/', 'http://mock.com/favicon.ico'],
      ['https://mock.com/', 'https://mock.com/favicon.ico'],
      ['http://mock.com/mock/', 'http://mock.com/favicon.ico'],
      ['http://mock.com/mock/index.html', 'http://mock.com/favicon.ico'],
      ['http://mock.com/mock/index.html?q=mock', 'http://mock.com/favicon.ico'],
      ['http://mock.com:80/mock/index.html?q=mock', 'http://mock.com/favicon.ico']
    ]

    urls.each do |url, expected|
      WebMock.reset!

      # IMPORTANT: First block all requests except specified ones
      WebMock.stub_request(:any, /.*/).to_return(status: 404)

      # Then allow specific requests AFTER the general block
      # (the last mock for a URL takes precedence)

      # Stub the initial page request
      stub_request_get(url, 'body')

      # Explicitly stub the favicon HEAD request to return success
      WebMock.stub_request(:head, expected)
             .to_return(status: 200, headers: { 'Content-Type' => 'image/x-icon' })

      icons = FaviconGem.get(url)
      refute_empty icons, "No icons found for #{url}"

      icon = icons.first
      assert_equal expected, icon.url
    end
  end

  def test_link_tags
    links = [
      '<link rel="icon" href="favicon.ico">',
      '<link rel="ICON" href="favicon.ico">',
      '<link rel="shortcut icon" href="favicon.ico">',
      '<link rel="apple-touch-icon" href="favicon.ico">',
      '<link rel="apple-touch-icon-precomposed" href="favicon.ico">'
    ]

    links.each do |link|
      WebMock.reset!

      # Block default favicon.ico on first request but allow it after found in link
      favicon_url = 'http://mock.com/favicon.ico'
      stub_default_requests('http://mock.com/', link, favicon_url)

      icons = FaviconGem.get('http://mock.com/')
      refute_empty icons
    end
  end

  def test_link_tag_sizes_attribute
    links_and_sizes = [
      ['<link rel="icon" href="logo.png" sizes="any">', [0, 0]],
      ['<link rel="icon" href="logo.png" sizes="16x16">', [16, 16]],
      ['<link rel="icon" href="logo.png" sizes="24x24+">', [24, 24]],
      ['<link rel="icon" href="logo.png" sizes="32x32 64x64">', [64, 64]],
      ['<link rel="icon" href="logo.png" sizes="64x64 32x32">', [64, 64]],
      ['<link rel="icon" href="logo-128x128.png" sizes="any">', [128, 128]],
      ['<link rel="icon" href="logo.png" sizes="16×16">', [16, 16]]
    ]

    links_and_sizes.each do |link, size|
      WebMock.reset!

      # Stub main page with link tag
      stub_request_get('http://mock.com/', link)

      # Block default favicon.ico
      WebMock.stub_request(:head, 'http://mock.com/favicon.ico')
             .to_return(status: 404)

      # Allow PNG favicon
      WebMock.stub_request(:head, %r{http://mock\.com/logo.*\.png})
             .to_return(status: 200, headers: { 'Content-Type' => 'image/png' })

      icons = FaviconGem.get('http://mock.com/')
      refute_empty icons, "No icons found for link: #{link}"

      icon = icons.first
      assert_equal size[0], icon.width
      assert_equal size[1], icon.height
    end
  end

  def test_link_tag_href_attribute
    links_and_urls = [
      ['<link rel="icon" href="logo.png">', 'http://mock.com/logo.png'],
      # Fix: Remove literal tab character since it causes URI errors
      ['<link rel="icon" href="logo.png ">', 'http://mock.com/logo.png'],
      ['<link rel="icon" href="/static/logo.png">', 'http://mock.com/static/logo.png'],
      ['<link rel="icon" href="https://cdn.mock.com/logo.png">', 'https://cdn.mock.com/logo.png'],
      ['<link rel="icon" href="//cdn.mock.com/logo.png">', 'http://cdn.mock.com/logo.png'],
      ['<link rel="icon" href="http://mock.com/logo.png?v2">', 'http://mock.com/logo.png?v2']
    ]

    links_and_urls.each do |link, url|
      WebMock.reset!

      # Stub the main page
      stub_request_get('http://mock.com/', link)

      # Block default favicon
      WebMock.stub_request(:head, 'http://mock.com/favicon.ico')
             .to_return(status: 404)

      # Allow specific URLs
      WebMock.stub_request(:head, url)
             .to_return(status: 200, headers: { 'Content-Type' => 'image/png' })

      icons = FaviconGem.get('http://mock.com/')
      refute_empty icons, "No icons found for URL: #{url} from link: #{link}"

      icon = icons.first
      assert_equal url, icon.url
    end
  end

  def test_link_tag_empty_href_attribute
    WebMock.reset!
    stub_request_get('http://mock.com/', '<link rel="icon" href="">')
    # Block default favicon
    WebMock.stub_request(:head, 'http://mock.com/favicon.ico').to_return(status: 404)

    icons = FaviconGem.get('http://mock.com/')
    assert_empty icons
  end

  def test_meta_tags
    meta_tags = [
      '<meta name="msapplication-TileImage" content="favicon.ico">',
      '<meta name="msapplication-tileimage" content="favicon.ico">'
    ]

    meta_tags.each do |meta_tag|
      WebMock.reset!
      # Block default favicon
      WebMock.stub_request(:head, 'http://mock.com/favicon.ico').to_return(status: 404)
      stub_request_get('http://mock.com/', meta_tag)

      # Allow meta tag favicon
      WebMock.stub_request(:head, 'http://mock.com/favicon.ico').to_return(
        status: 200,
        headers: { 'Content-Type' => 'image/x-icon' }
      )

      icons = FaviconGem.get('http://mock.com/')
      refute_empty icons
    end
  end

  def test_invalid_meta_tag
    WebMock.reset!
    stub_request_get(
      'http://mock.com/',
      '<meta content="en-US" data-rh="true" itemprop="inLanguage"/>'
    )

    # Block default favicon
    WebMock.stub_request(:head, 'http://mock.com/favicon.ico').to_return(status: 404)

    icons = FaviconGem.get('http://mock.com/')
    assert_empty icons
  end

  def test_request_with_headers
    WebMock.reset!
    headers = {
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'
    }

    WebMock.stub_request(:get, 'http://mock.com/')
           .with(headers: headers)
           .to_return(body: 'body')

    # Block default favicon
    WebMock.stub_request(:head, 'http://mock.com/favicon.ico').to_return(status: 404)

    icons = FaviconGem.get('http://mock.com/', headers: headers)
    assert_empty icons
  end

  def test_is_absolute_helper
    urls_and_results = [
      ['http://mock.com/favicon.ico', true],
      ['favicon.ico', false],
      ['/favicon.ico', false]
    ]

    urls_and_results.each do |url, expected|
      result = FaviconGem.send(:is_absolute, url)
      assert_equal expected, result
    end
  end

  private

  # Helper method to set up commonly used request stubs
  def stub_default_requests(base_url, html_content, favicon_url)
    # Stub main page
    stub_request_get(base_url, html_content)

    # First block favicon.ico by default
    WebMock.stub_request(:head, favicon_url)
           .to_return(status: 404)

    # Then allow favicon.ico when requested from link tag
    WebMock.stub_request(:head, favicon_url)
           .to_return(status: 200, headers: { 'Content-Type' => 'image/x-icon' })
  end
end
