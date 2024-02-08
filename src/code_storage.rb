require_relative "./require_remote"
module JS
    
  #   # Usage example:
  #   storage = RubyCodeStorage.new
  #   storage.save_file('example.rb', "puts 'Hello, World!'")
  #   puts storage.retrieve_file('example.rb') # => "puts 'Hello, World!'"
  #   puts storage.list_files # => ["example.rb"]
  #   storage.delete_file('example.rb')
  #   puts storage.list_files # => []
  class CodeStorage < RequireRemote
      ORIGINAL_PREFIX = "#original"
      LOCATION_URL_PREFIX = "#LOCATION_URL_PREFIX"


      def initialize
        @storage = JS.global.localStorage
        super
      end

      def save_file(name, content)
        @storage.setItem(name, content)
      end

      def save_original_file(name, content)
        save_file(ORIGINAL_PREFIX + name, content)
      end

      def has_file?(name)
        @storage.getItem(name).nil? === false
      end
    
      def retrieve_file(name)
        @storage.getItem(name).to_s
      end

      def run_file(location_path, location_url=nil)
        if location_url == nil
          location_url = @storage.getItem(LOCATION_URL_PREFIX + location_path)
        else
          @storage.setItem(LOCATION_URL_PREFIX + location_path, location_url)
        end
        
        code = retrieve_file(location_path)
        @evaluator.evaluate(code, location_path, location_url)
      end

      def retrieve_original_file(name)
        retrieve_file(ORIGINAL_PREFIX + name)
      end
    
      def delete_file(name)
        @storage.removeItem(name)
      end
    
      def list_files
        files = []
        (0...@storage.length).each do |i|
          key = @storage.key(i)
          files << key if key.start_with?(LOCATION_URL_PREFIX) == false and key.start_with?(ORIGINAL_PREFIX) == false and key.to_s.end_with?('.rb') # Assuming we only want to list Ruby files
        end
        files
      end

      def load(relative_feature, no_cache = false)
        return super(relative_feature) if no_cache

        location = @resolver.get_location(relative_feature)
        location_url = location.url[:href].to_s
        location_path = location.path.to_s
        # Do not load the same URL twice.
        return false if @evaluator.evaluated?(location_path)

        if has_file?(location_path)
          run_file(location_path, location_url)
        else
          puts "cache now #{location_url}"
          code = super(relative_feature)[:code]
          save_file(location_path, code)
          save_original_file(location_path, code)
        end
      end
    end

end