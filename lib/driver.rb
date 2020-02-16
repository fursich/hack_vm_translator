# usage
# load 'lib/driver.rb'
# translator = VMTranslator::Driver.new('add/Add.vm')
# translator.run

require 'forwardable'

require_relative 'utils/fileio'
require_relative 'utils/inflector'
require_relative 'errors'
require_relative 'core'

module VMTranslator
  class Driver
    attr_reader :sources

    def initialize(path, debug: false)
      @debug        = debug
      @line_counter = 1

      expand_filenames!(path)
      raw_sources   = retrive_sources
      @sources      = format_sources(raw_sources)

      append_init_caller! if @compilation_mode == :integrated
    end

    def run
      @assembly = @sources.map { |basename, source|
        VMTranslator::Core.new(source, basename: basename, debug: @debug).process
      }
      append_bootstrap_code! if @compilation_mode == :integrated

      write_file(@assembly.join("\n"), filename: @output_filename)
    end

    private

    def retrive_sources
      @input_filenames.map do |filename|
        [filename.basename, read_from_file(filename)]
      end
    end

    def format_sources(raw_sources)
      raw_sources.map { |basename, raw_source|
        numbered_source = raw_source.split(/\r?\n/).map.with_index(2){ |code, lineno| [lineno, code] }
        [basename, numbered_source]
      }
    end

    def append_init_caller!
      @sources.unshift(
        ['__bootstrap_codes__',
          [
            [1, 'call Sys.init 0']
          ]
        ]
      )
    end

    INITIAL_SP = 0x100
    def append_bootstrap_code!
      @assembly.unshift(<<~BOOTSTRAP.chomp)
        @#{INITIAL_SP}
        D = A
        @SP
        M = D
      BOOTSTRAP
    end

    def read_from_file(filename)
      FileIO.new(filename).read
    end

    def write_file(assembly, filename:)
      FileIO.new(filename).write(assembly)
    end

    def expand_filenames!(path)
      unless path && File.exist?(path)
        raise FileError, 'please specify valid path of a *.vm file, or a directory including *.vm file(s))'
      end

      pathname = Pathname.new(path)
      @output_filename = Pathname.pwd.join pathname.basename.sub_ext('.asm')

      if pathname.directory?
        @compilation_mode = :integrated
        @input_filenames = pathname.glob('*.vm')

        validate_file_structure_with_integrated_mode!
      else
        @compilation_mode = :single_file
        raise FileError, 'illegal file type' if pathname.extname != '.vm'
        @input_filenames = [pathname]
      end
    end

    def validate_file_structure_with_integrated_mode!
      return unless @compilation_mode == :integrated

      raise FileError, 'no vm file(s) found in the directory' if @input_filenames.empty?
      raise FileError, 'cannot find Sys.vm in the directory' unless @input_filenames.map{ |file| file.basename.to_s }.one?('Sys.vm')
    end
  end
end
