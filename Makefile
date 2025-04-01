.PHONY: setup console build install clean run test example

# Имя гема
NAME = favicon_gem

# Версия гема (читаем из файла version.rb)
VERSION = $(shell grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' lib/favicon_gem/version.rb)

# Установка зависимостей
setup:
	@echo "Установка зависимостей..."
	@bundle install
	@echo "Готово!"

# Запуск консоли с загруженным гемом
console:
	@echo "Запуск консоли с загруженным гемом..."
	@bin/console

# Сборка гема
build:
	@echo "Сборка гема $(NAME)-$(VERSION).gem..."
	@gem build $(NAME).gemspec
	@echo "Гем собран!"

# Установка гема локально
install: build
	@echo "Установка гема локально..."
	@gem install ./$(NAME)-$(VERSION).gem
	@echo "Гем установлен!"

# Очистка временных файлов и артефактов сборки
clean:
	@echo "Очистка временных файлов..."
	@rm -f *.gem
	@rm -rf tmp/
	@echo "Чистка завершена!"

# Запуск простого примера использования гема
run:
	@echo "Запуск примера использования гема..."
	@ruby -e "require 'favicon_gem'; icons = FaviconGem.get('https://www.ruby-lang.org/'); icon = icons.first; puts \"Найдена иконка: #{icon.url} (#{icon.width}x#{icon.height}, формат: #{icon.format})\""

# Запуск примера из директории examples
example:
	@echo "Запуск примера из директории examples..."
	@ruby examples/basic_usage.rb

# Запустить тесты
test:
	@echo "Запуск тестов..."
	@bundle exec rake test

# Показать помощь
help:
	@echo "Доступные команды:"
	@echo "  make setup    - Установка зависимостей"
	@echo "  make console  - Запуск консоли с загруженным гемом"
	@echo "  make build    - Сборка гема"
	@echo "  make install  - Установка гема локально"
	@echo "  make clean    - Очистка временных файлов"
	@echo "  make run      - Запуск простого примера"
	@echo "  make example  - Запуск полного примера из examples/"
	@echo "  make test     - Запуск тестов"
	@echo "  make help     - Показать эту справку"

# По умолчанию показываем помощь
default: help
