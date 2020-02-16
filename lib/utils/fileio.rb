module VMTranslator
  class FileIO
    def initialize(filename)
      @filename = filename
    end

    def read
      source = []
      begin
        File.open(@filename) do |file|
          source = file.read.split(/\r?\n/).map.with_index(1){ |l, i| [i, l] }
        end
      rescue => e
        raise FileError, "#{e.class} #{e.message}\n an error occured while reading the source file.\n"
      end
      source
    end

    def write(str)
      begin
        File.open(@filename, 'w') do |file|
          file.write(str)
        end
      rescue => e
        raise FileError, "#{e.class} #{e.message}\n an error occured while writing the output file.\n"
      end
    end
  end
end

