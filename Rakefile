require 'bundler/gem_tasks'
require 'rake/testtask'

Bundler::GemHelper.install_tasks(name: 'favicon_get')

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/test_*.rb']
end

task default: :test
