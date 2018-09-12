require "http/server"
require "./router"
require "./store"

module CrystalServer
  class Server
    HOST = "0.0.0.0"
    PORT = 8081
    CONTENT_TYPES = {
      "html" => "text/html",
      "js" => "text/javascript",
      "css" => "text/css",
      "bin" => "octet/stream"
    }
    
    def self.run
      new.run
    end

    def initialize(@host = HOST, @port = PORT)
      @vault = Store::Vault.new

      Signal::HUP.trap do
        print "Cleaning cache.. "
        @vault.clear!
        puts "done."
      end
    end

    def run
      server = HTTP::Server.new do |context|
        router = Router.new(context.request.path)
        relative_path = router.translate_path
        resource = @vault.get(relative_path)

        if resource
          puts "Serving #{relative_path}"
          reply_with_resource(resource, context)
        else
          puts "Error: #{relative_path} could not be served"
        end
      end

      address = server.bind_tcp(@host, @port)
      puts "Crystal server listening on http://#{address}"
      server.listen
    end

    def reply_with_resource(resource, context)
      if resource && resource.size > 0
        context.response.status_code = 200
        context.response.content_type = CONTENT_TYPES[resource.type]
        context.response.write(resource.content)
      else
        context.response.status_code = 404
        context.response.content_type = "text/plain"
        context.response.print("Not found")
      end
    end
  end
end
