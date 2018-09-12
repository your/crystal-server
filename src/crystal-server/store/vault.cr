require "./file"

module CrystalServer
  module Store
    class Vault
      BASE_DIR = "."

      def initialize(@base_dir = "#{BASE_DIR}/store")
        @files = {} of String => Store::File
      end

      def get(relative_path)
        full_path = @base_dir + relative_path
        file = Store::File.new(full_path)

        if !@files[relative_path]? # Lazy read =)
          @files[relative_path] = file
        end

        @files[relative_path]
      end

      def clear!
        @files.clear
      end
    end
  end
end
