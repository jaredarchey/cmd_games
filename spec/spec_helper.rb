require "colorize"
require "rspec"
require_relative "../lib/formatter"
require_relative "../lib/coordinate"
require_relative "../src/space"

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end