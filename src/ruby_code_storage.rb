require_relative "./require_remote/evaluator"
require_relative "./require_remote/url_resolver"

class RubyCodeStorage
    include Singleton

    def initialize
      @storage = JS.global.localStorage
      base_url = JS.global[:URL].new(JS.global[:location][:href])
      @evaluator = JS::RequireRemote::Evaluator.new
      @resolver = JS::RequireRemote::URLResolver.new(base_url)
    end
  
    def save_file(name, content)
      @storage.setItem(name, content)
    end

    def has_file?(name)
      @storage.getItem(name).nil? === false
    end
  
    def retrieve_file(name)
      @storage.getItem(name)
    end

    # def evaluate_file(name)
    #   filename = name
    #   final_url = name
    #   code = retrieve_file(name)
    #   @evaluator.evaluate(code, filename, final_url)
    # end
  
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

    def load(relative_feature)
#   filename = name
    #   final_url = name
    #   code = retrieve_file(name)
    #   @evaluator.evaluate(code, filename, final_url)
      #raise LoadError.new "cannot load such url -- #{response[:status]} #{location.url}"
      location = @resolver.get_location(relative_feature)

      # Do not load the same URL twice.
      return false if @evaluator.evaluated?(location.url[:href].to_s)

      #response = JS.global.fetch(location.url).await
      #unless response[:status].to_i == 200
      #  raise LoadError.new "cannot load such url -- #{response[:status]} #{location.url}"
      #end
      unless has_file?(location.url[:href])
        raise LoadError.new "cannot load such url -- #{location.url}"
      end

      final_url = location.url[:href].to_s

      # Do not evaluate the same URL twice.
      return false if @evaluator.evaluated?(final_url)

      code = retrieve_file(final_url)
      #code = response.text().await.to_s
      # p code.typeof
      # p code === JS::Null
      # p code.nil?
      # puts code
      @evaluator.evaluate(code, location.path, final_url)

    end

    def cache(result)
      # TODO final url
      name = result[:location].filename
      code = result[:code]
      save_file(name, code)
      p result, code

      true
    end

  end
  
#   # Usage example:
#   storage = RubyCodeStorage.new
#   storage.save_file('example.rb', "puts 'Hello, World!'")
#   puts storage.retrieve_file('example.rb') # => "puts 'Hello, World!'"
#   puts storage.list_files # => ["example.rb"]
#   storage.delete_file('example.rb')
#   puts storage.list_files # => []
  