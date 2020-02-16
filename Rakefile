require "rake/testtask"
require 'pry'
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
  sources = VMTranslator::Driver.new(args.filename).sources

  sources.each do |basename, source|
    parsed = Parser::Processor.new(source, basename: basename).parse!

    puts "<<file: #{basename}>>"
    parsed.each do |node|
      puts "  NODE: #{node.class}:#{node.object_id}"
      node.operands.each do |operand|
        puts "    - #{operand.inspect}"
      end
    end
    puts
  end
end

task :compile, [:filename, :debug] do |_task, args|
  sources = VMTranslator::Driver.new(args.filename).sources

  sources.each do |basename, source|
    compiled = VMTranslator::Core.new(source, basename: basename, debug: args.debug).process

    puts "<<file: #{basename}>>"
    puts
    puts compiled
    puts
  end
end
