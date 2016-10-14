require "http/server"
require "./store"

PORT = 8081
CONTENT_TYPES = {
  "html" => "text/html",
  "js" => "text/javascript",
  "css" => "text/css"
}

class Server
  def self.run
    new.init
  end

  def initialize(@port = PORT, @store = Store.new)
    Signal::HUP.trap do
      print "Cleaning cache.. "
      @store.clean!
      puts "done."
    end
  end

  def init
    #
    # https://github.com/crystal-lang/crystal/blob/master/src/http/server.cr#L148
    # (Fibers! :D)
    #
    server = HTTP::Server.new(@port) do |context|
      path = translate_path(context.request.path)

      if valid_path?(path)
        reply_with(raw_file(path), context, path)
      elsif favicon?(path)
        reply_with(:favicon, context, path)
      else
        reply_with(:nothing, context, path)
      end
    end

    puts "Crystal server listening on http://0.0.0.0:#{@port}"
    server.listen
  end

  # Conversion matrix:
  #
  # GET /compiled-html-filename-without-extension -> /raw/html/filename-without-extension
  # GET /filename.js -> /raw/js/filename-without-extension
  # GET /filename.css -> /raw/css/filename-without-extension
  #
  def translate_path(path)
    return path unless !!/^\/[0-9a-zA-Z-]+(.js|.css)?$/.match(path)

    case path
    when /.js/
      "/raw/js" + path.gsub(".js", "")
    when /.css/
      "/raw/css" + path.gsub(".css", "")
    else
      "/raw/html" + path
    end
  end

  # Allowing smth like:
  #
  # GET /raw/html/filename-without-extension
  # GET /raw/js/filename-without-extension
  # GET /raw/css/filename-without-extension
  #
  def valid_path?(path)
    !!/^\/raw\/(html|js|css)\/[0-9a-zA-Z-]+$/.match(path)
  end

  def raw_file(path)
    @store.resource(path)
  end

  def favicon?(path)
    path.ends_with?("favicon.ico")
  end

  def reply_with(resource, context, path)
    case resource
    when :nothing
      context.response.status_code = 403
      context.response.content_type = "text/plain"
      context.response.print("Forbidden")
    when :favicon
      context.response.status_code = 200
      context.response.content_type = "image/x-icon"

      # Slice this!
      size = File.size("./favicon.ico") rescue 0
      slice = Slice(UInt8).new(size)
      File.open("./favicon.ico") do |file|
        file.read_fully(slice)
      end rescue nil # (meh.)

      context.response.write(slice)
    else
      if resource
        context.response.status_code = 200
        context.response.content_type = CONTENT_TYPES[extension(path)]
        context.response.print(resource)
      else
        context.response.status_code = 404
        context.response.content_type = "text/plain"
        context.response.print("Not found")
      end
    end
  end

  def extension(path)
    path.split("/")[-2]
  end
end
