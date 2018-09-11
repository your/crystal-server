require "http/server"
require "./store"

HOST = "0.0.0.0"
PORT = 8081
CONTENT_TYPES = {
  "html" => "text/html",
  "js" => "text/javascript",
  "css" => "text/css",
  "bin" => "octet/stream"
}

class Server
  def self.run
    new.init
  end

  def initialize(@host = HOST, @port = PORT, @store = Store.new)
    Signal::HUP.trap do
      print "Cleaning cache.. "
      @store.clean!
      puts "done."
    end
  end

  def init
    server = HTTP::Server.new do |context|
      path = translate_path(context.request.path)

      if valid_path?(path)
        reply_with_resource(raw_file(path), context, path)
      else
        reply_with_nothing(context)
      end
    end

    address = server.bind_tcp(@host, @port)
    puts "Crystal server listening on http://#{@host}:#{@port}"
    server.listen
  end

  # Conversion matrix:
  #
  # GET /compiled-html-filename-without-extension -> /raw/html/filename-without-extension
  # GET /filename.js -> /raw/js/filename-without-extension
  # GET /filename.css -> /raw/css/filename-without-extension
  #
  def translate_path(path)
    return path unless !!/^\/[0-9a-zA-Z-]+(.js|.css|.[0-9a-zA-Z]+)?$/.match(path)

    case path
    when /.js$/
      "/raw/js" + path.gsub(/.js$/, "")
    when /.css$/
      "/raw/css" + path.gsub(/.css$/, "")
    else
      if path.includes?(".")
        "/raw/bin" + path
      else
        "/raw/html" + path
      end
    end
  end

  # Allowing smth like:
  #
  # GET /raw/html/filename-without-extension
  # GET /raw/js/filename-without-extension
  # GET /raw/css/filename-without-extension
  # GET /raw/bin/filename-with-extension
  #
  def valid_path?(path)
    !!/^\/raw\/(html|js|css|bin)\/[0-9a-zA-Z-]+$/.match(path) ||
      !!/^\/raw\/bin\/[0-9a-zA-Z-]+.[0-9a-zA-Z-]+$/.match(path)
  end

  def raw_file(path)
    @store.resource(path)
  end

  def reply_with_nothing(context)
    context.response.status_code = 403
    context.response.content_type = "text/plain"
    context.response.print("Forbidden")
  end

  def reply_with_resource(resource, context, path)
    if resource && resource.size > 0
      context.response.status_code = 200
      context.response.content_type = CONTENT_TYPES[extension(path)]
      context.response.write(resource)
    else
      context.response.status_code = 404
      context.response.content_type = "text/plain"
      context.response.print("Not found")
    end
  end

  def extension(path)
    path.split("/")[-2]
  end
end

Server.run
