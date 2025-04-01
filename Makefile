.PHONY: setup console build install clean run test example push yank

# Gem name
NAME = favicon_get

# Gem version (read from version.rb file)
VERSION = $(shell grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' lib/favicon_get/version.rb)

# Install dependencies
setup:
	@echo "Installing dependencies..."
	@bundle install
	@echo "Done!"

# Run console with loaded gem
console:
	@echo "Starting console with loaded gem..."
	@bin/console

# Build gem
build:
	@echo "Building gem $(NAME)-$(VERSION).gem..."
	@gem build $(NAME).gemspec
	@echo "Gem built!"

# Install gem locally
install: build
	@echo "Installing gem locally..."
	@gem install ./$(NAME)-$(VERSION).gem
	@echo "Gem installed!"

# Clean temporary files and build artifacts
clean:
	@echo "Cleaning temporary files..."
	@rm -f *.gem
	@rm -rf tmp/
	@echo "Cleaning completed!"

# Run simple example of gem usage
run:
	@echo "Running gem usage example..."
	@ruby -e "require 'favicon_get'; icons = FaviconGet.get('https://www.ruby-lang.org/'); icon = icons.first; puts \"Found icon: #{icon.url} (#{icon.width}x#{icon.height}, format: #{icon.format})\""

# Run example from examples directory
example:
	@echo "Running example from examples directory..."
	@ruby examples/basic_usage.rb

# Run tests
test:
	@echo "Running tests..."
	@bundle exec rake test

# Push gem to RubyGems
push: build
	@echo "Publishing gem to RubyGems..."
	@gem push ./$(NAME)-$(VERSION).gem
	@echo "Gem published!"

# Remove gem from RubyGems
yank:
	@echo "Removing gem $(NAME) version $(VERSION) from RubyGems..."
	@gem yank $(NAME) -v $(VERSION)
	@echo "Gem removed from RubyGems!"

# Show help
help:
	@echo "Available commands:"
	@echo "  make setup    - Install dependencies"
	@echo "  make console  - Run console with loaded gem"
	@echo "  make build    - Build gem"
	@echo "  make install  - Install gem locally"
	@echo "  make clean    - Clean temporary files"
	@echo "  make run      - Run simple example"
	@echo "  make example  - Run full example from examples/"
	@echo "  make test     - Run tests"
	@echo "  make push     - Publish gem to RubyGems"
	@echo "  make yank     - Remove gem from RubyGems"
	@echo "  make help     - Show this help"

# By default show help
default: help
