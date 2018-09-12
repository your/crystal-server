module CrystalServer
  module Store
    class File
      getter content : Nil | Slice(UInt8)

      def initialize(@full_path : String)
      end

      def size
        content.size
      end
      
      def type
        if !!extension.match(/html|js|css/)
          extension
        else
          "bin"
        end
      end

      def content
        @content ||= begin
          size = ::File.size(@full_path) rescue 0
          slice = Slice(UInt8).new(size)
          ::File.open(@full_path) do |file|
            file.read_fully(slice)
          end rescue slice

          slice
        end
      end

      private def extension
        @full_path.split(".")[-1]
      end
    end
  end
end
