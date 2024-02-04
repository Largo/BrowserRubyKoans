require 'js'
require 'js/require_remote'

module Kernel
  #alias original_require_relative require_relative

  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
  end
end


# TODO: make sure require_relative knows where the basefolder is, so this file does not need to be in the topfolder.

require_relative "src/require_remote"

require_relative "src/ruby_code_storage"


# overwrite again. this is a workaround

module Kernel
  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    file_required_from = caller(2..2).first&.split(':')&.first.to_s
    if not file_required_from.start_with?("/koans")
      JS::RequireRemote.instance.load(path)
    else
      begin 
        RubyCodeStorage.instance.load(path)
      rescue LoadError
        RubyCodeStorage.instance.cache(JS::RequireRemote.instance.load(path))
      end
    end
  end
end


