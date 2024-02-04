class RubyCodeStorage
    def initialize
      @storage = JS.global.localStorage
    end
  
    def save_file(name, content)
      @storage.setItem(name, content)
    end
  
    def retrieve_file(name)
      @storage.getItem(name)
    end

    def evaluate_file(name)
      filename = name
      final_url = name
      code = retrieve_file(name)
      JS.RequireRemote.evaluate(code, filename, final_url)
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
  end
  
#   # Usage example:
#   storage = RubyCodeStorage.new
#   storage.save_file('example.rb', "puts 'Hello, World!'")
#   puts storage.retrieve_file('example.rb') # => "puts 'Hello, World!'"
#   puts storage.list_files # => ["example.rb"]
#   storage.delete_file('example.rb')
#   puts storage.list_files # => []
  