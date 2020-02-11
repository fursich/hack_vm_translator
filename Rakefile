require "rake/testtask"
require_relative 'lib/driver'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :run, [:filename] do |_task, args|
  VMTranslator::Driver.new(args.filename).run
end

task :parse, [:filename] do |_task, args|
  source = VMTranslator::Driver.new(args.filename).source
  parsed = Parser::Processor.new(source).parse!
  parsed.each do |tree|
    p tree
  end
end

task :compile, [:filename] do |_task, args|
  compiled = VMTranslator::Driver.new(args.filename).compile
  compiled.each do |tree|
    puts tree
  end
end
