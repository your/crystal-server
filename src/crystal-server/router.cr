module CrystalServer
  class Router
    def initialize(@path : String)
    end

    # Conversion matrix:
    #
    # GET /filename      -> /raw/html/filename.html
    # GET /filename.html -> /raw/html/filename.html
    # GET /filename.js   -> /raw/js/filename.js
    # GET /filename.css  -> /raw/css/filename.js
    #
    def translate_path
      case @path
      when /.js$/
        "/raw/js" + @path
      when /.css$/
        "/raw/css" + @path
      when /.html$/
        "/raw/html" + @path
      else
        if @path.includes?(".")
          "/raw/bin" + @path
        else
          "/raw/html" + @path + ".html"
        end
      end
    end
  end
end
