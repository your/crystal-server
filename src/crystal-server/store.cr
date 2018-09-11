BASE_DIR = "."

class Store
  def initialize(@base_dir = "#{BASE_DIR}/store")
    @resources = {} of String => Slice(UInt8)
  end

  def resource(path)
    filename = filename_from_path(path)

    if @resources[path]? # Lazy read =)
      puts "[cache] Serving #{filename}"
    else
      puts "Serving #{filename}"

      size = File.size(filename) rescue 0
      slice = Slice(UInt8).new(size)
      File.open(filename) do |file|
        file.read_fully(slice)
      end rescue nil # (meh.)

      @resources[path] = slice
    end

    @resources[path]
  rescue
    puts "Error: #{filename} could not be served"
    nil
  end

  def filename_from_path(path)
    filename = @base_dir + path

    if is_binary?(path)
      filename
    else
      filename + "." + extension(path)
    end
  end

  def is_binary?(path)
    !!/^\/raw\/bin\/[0-9a-zA-Z-]+.[0-9a-zA-Z-]+$/.match(path)
  end

  def clean!
    @resources.clear
  end

  def extension(path)
    path.split("/")[-2]
  end
end
