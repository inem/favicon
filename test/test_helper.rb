# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "favicon_gem"
require "minitest/autorun"
require "webmock/minitest"

# Helper class for creating mock responses
class MockResponse
  attr_reader :url, :body, :status

  def initialize(url, body, status = 200)
    @url = url
    @body = body
    @status = status
  end

  def env
    OpenStruct.new(url: OpenStruct.new(to_s: @url))
  end

  def success?
    @status == 200
  end
end

# Stub HTTP responses for testing
module WebMockHelpers
  def stub_request_get(url, body, status = 200)
    WebMock.stub_request(:get, url).to_return(
      body: body,
      status: status,
      headers: { "Content-Type" => "text/html" }
    )
  end

  def stub_request_head(url, status = 200)
    WebMock.stub_request(:head, url).to_return(
      status: status,
      headers: { "Content-Type" => "image/x-icon" }
    )
  end
end
