BASE_DIR = "."

class Store
  def initialize(@base_dir = "#{BASE_DIR}/store")
    @resources = {} of String => String
  end

  def resource(path)
    filename = @base_dir + path + "." + extension(path)

    if @resources[path]? # Lazy read =)
      puts "[cache] Serving #{filename}"
    else
      puts "Serving #{filename}"
      @resources[path] = File.read(filename)
    end

    @resources[path]
  rescue
    puts "Error: #{filename} could not be served"
    nil
  end

  def extension(path)
    path.split("/")[-2]
  end
end