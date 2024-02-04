require 'js'
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative

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

require_relative "src/ruby_code_storage"

# TODO: make sure require_relative knows where the basefolder is, so this file does not need to be in the topfolder.

require_relative "src/require_remote"

# module Kernel
#   alias original_require_relative require_relative

#   # The require_relative may be used in the embedded Gem.
#   # First try to load from the built-in filesystem, and if that fails,
#   # load from the URL.
#   def require_relative(path)
#     caller_path = caller_locations(1, 1).first.absolute_path || ''
#     dir = File.dirname(caller_path)
#     file = File.absolute_path(path, dir)

#     original_require_relative(file)
#   rescue LoadError
#     begin 
#      # RubyCodeStorage.instance.load(path)
#     rescue LoadError
#       JS::RequireRemote.instance.load(path)
#     end
#   end
# end


