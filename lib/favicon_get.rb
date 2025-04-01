# frozen_string_literal: true

require "favicon_get/version"
require "faraday"
require "faraday/follow_redirects"
require "nokogiri"
require "uri"
require "set"

module FaviconGet
  class Error < StandardError; end

  # Website icon representation
  Icon = Struct.new(:url, :width, :height, :format)

  # Gem metadata
  TITLE = "favicon_get"
  AUTHOR = "Ported from Python favicon by Scott Werner"
  LICENSE = "MIT"

  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) " \
                   "AppleWebKit/537.36 (KHTML, like Gecko) " \
                   "Chrome/33.0.1750.152 Safari/537.36"
  }

  LINK_RELS = [
    "icon",
    "shortcut icon",
    "apple-touch-icon",
    "apple-touch-icon-precomposed"
  ]

  META_NAMES = ["msapplication-TileImage"]  # Removed og:image from metatags as it's usually not a favicon

  # Format priorities (higher = better)
  FORMAT_PRIORITY = {
    "ico" => 10,
    "png" => 9,
    "jpg" => 8,
    "jpeg" => 7,
    "svg" => 6,
    "gif" => 5,
    "" => 0  # Unknown format has the lowest priority
  }

  SIZE_RE = /(?<width>\d{2,4})x(?<height>\d{2,4})/i

  class << self
    # Get all icons for a URL
    #
    # @param url [String] Page URL
    # @param headers [Hash] Request headers
    # @return [Array<Icon>] List of found icons, sorted by size
    def get(url, headers: HEADERS, **request_options)
      request_options[:headers] ||= headers

      conn = Faraday.new(url: url) do |faraday|
        faraday.request :url_encoded
        faraday.headers = request_options[:headers]
        faraday.options.timeout = request_options[:timeout] if request_options[:timeout]
        faraday.use Faraday::FollowRedirects::Middleware
        faraday.adapter Faraday.default_adapter
      end

      response = conn.get
      raise Error, "Failed to fetch URL: #{response.status}" unless response.success?

      icons = Set.new

      default_icon = default(response.env.url.to_s, **request_options)
      icons.add(default_icon) if default_icon

      link_icons = tags(response.env.url.to_s, response.body)
      icons.merge(link_icons) if link_icons.any?

      # Improve sorting:
      # 1. By size (larger first)
      # 2. If sizes are equal, sort by format (ico/png have higher priority)
      # 3. All icons with zero sizes go to the end
      icons.to_a.sort_by do |icon|
        format_priority = FORMAT_PRIORITY[icon.format] || 0
        size = icon.width + icon.height

        if size > 0
          [1, size, format_priority]  # Icons with non-zero size first
        else
          [0, format_priority]        # Zero sizes - second priority
        end
      end.reverse
    end

    private

    # Get icon using default filename favicon.ico
    #
    # @param url [String] Site URL
    # @param request_options [Hash] Request parameters
    # @return [Icon, nil] Icon or nil
    def default(url, **request_options)
      uri = URI.parse(url)
      # Preserve port if explicitly specified
      port_part = uri.port == uri.default_port ? "" : ":#{uri.port}"
      favicon_url = "#{uri.scheme}://#{uri.host}#{port_part}/favicon.ico"

      conn = Faraday.new(url: favicon_url) do |faraday|
        faraday.headers = request_options[:headers] if request_options[:headers]
        faraday.options.timeout = request_options[:timeout] if request_options[:timeout]
        faraday.use Faraday::FollowRedirects::Middleware
        faraday.adapter Faraday.default_adapter
      end

      response = conn.head
      return Icon.new(response.env.url.to_s, 0, 0, "ico") if response.success?
      nil
    rescue Faraday::Error
      nil
    end

    # Get icons from link and meta tags
    #
    # @param url [String] Site URL
    # @param html [String] Page HTML code
    # @return [Set<Icon>] Found icons
    def tags(url, html)
      doc = Nokogiri::HTML(html)
      icons = Set.new

      # Search in <link> tags
      link_tags = Set.new
      LINK_RELS.each do |rel|
        doc.css("link[rel='#{rel}'][href]").each do |link_tag|
          link_tags.add(link_tag)
        end
      end

      # Search in <meta> tags
      meta_tags = Set.new
      META_NAMES.each do |name|
        doc.css("meta[name='#{name}'][content], meta[property='#{name}'][content]").each do |meta_tag|
          meta_tags.add(meta_tag)
        end
      end

      (link_tags | meta_tags).each do |tag|
        href = tag["href"] || tag["content"] || ""
        href = href.strip.gsub(/\s+/, "") # Remove all whitespace, including tabs

        next if href.empty? || href.start_with?("data:image/")

        begin
          # Fix URLs like '//cdn.network.com/favicon.png'
          if href.start_with?("//")
            uri = URI.parse(url)
            href = "#{uri.scheme}:#{href}"
          end

          url_parsed = if is_absolute(href)
                        href
                      else
                        URI.join(url, href).to_s
                      end

          width, height = dimensions(tag)
          ext = File.extname(URI.parse(url_parsed).path)[1..]&.downcase || ""

          icons.add(Icon.new(url_parsed, width, height, ext))
        rescue URI::InvalidURIError
          # Skip invalid URIs
          next
        end
      end

      icons
    end

    # Check if URL is absolute
    #
    # @param url [String] URL
    # @return [Boolean] true if absolute
    def is_absolute(url)
      uri = URI.parse(url)
      !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end

    # Get icon dimensions from size attribute or filename
    #
    # @param tag [Nokogiri::XML::Element] Link or meta tag
    # @return [Array<Integer>] Width and height, or [0,0]
    def dimensions(tag)
      sizes = tag["sizes"]
      if sizes && sizes != "any"
        size = sizes.split(" ").max_by { |s| s.scan(/\d+/).map(&:to_i).sum }
        width, height = size.split(/[x×]/)
      else
        filename = tag["href"] || tag["content"] || ""
        size = SIZE_RE.match(filename)
        if size
          width, height = size[:width], size[:height]
        else
          width, height = "0", "0"
        end
      end

      # Clean non-digit characters
      width = width.to_s.scan(/\d+/).join
      height = height.to_s.scan(/\d+/).join
      [width.to_i, height.to_i]
    end
  end
end
