#!/usr/bin/env ruby
# frozen_string_literal: true

# Пример базового использования FaviconGem

# Добавляем путь к локальному гему, если он не установлен
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'favicon_gem'
require 'open-uri'

# URL для тестирования
url = ARGV[0] || 'https://www.ruby-lang.org/'

puts "Получение иконок для #{url}..."

begin
  # Получаем все иконки
  icons = FaviconGem.get(url)

  if icons.empty?
    puts "Иконки не найдены для #{url}"
    exit(1)
  end

  puts "Найдено #{icons.size} иконок:"

  # Выводим информацию о каждой иконке
  icons.each_with_index do |icon, i|
    puts "[#{i+1}] #{icon.url} (#{icon.width}x#{icon.height}, формат: #{icon.format})"
  end

  # Скачиваем самую большую иконку
  biggest_icon = icons.first
  puts "\nСкачивание самой большой иконки: #{biggest_icon.url}"

  output_path = "/tmp/favicon-example.#{biggest_icon.format}"

  URI.open(biggest_icon.url) do |image|
    File.open(output_path, "wb") do |file|
      file.write(image.read)
    end
  end

  puts "Иконка сохранена в #{output_path}"

rescue StandardError => e
  puts "Ошибка: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1)
end