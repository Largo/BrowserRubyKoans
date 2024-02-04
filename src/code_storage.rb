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
      def initialize
        @storage = JS.global.localStorage
        super
      end

      def save_file(name, content)
        @storage.setItem(name, content)
      end

      def has_file?(name)
        @storage.getItem(name).nil? === false
      end
    
      def retrieve_file(name)
        @storage.getItem(name).to_s
      end
    
      def delete_file(name)
        @storage.removeItem(name)
      end
    
      def list_files
        files = []
        (0...@storage.length).each do |i|
          key = @storage.key(i)
          files << key if key.to_s.end_with?('.rb') # Assuming we only want to list Ruby files
        end
        files
      end

      def load(relative_feature, no_cache = false)
        return super(relative_feature) if no_cache

        location = @resolver.get_location(relative_feature)
        # Do not load the same URL twice.
        return false if @evaluator.evaluated?(location.url[:href].to_s)

        if has_file?(location.url)
          code = retrieve_file(location.url[:href].to_s)
          @evaluator.evaluate(code, location.path.to_s, location.url[:href].to_s)
        else 
          cache(super(relative_feature))
        end
      end

      def cache(result)
        true
      end

    end

end