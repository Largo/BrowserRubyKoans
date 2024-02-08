require 'js'
require 'js/require_remote'

# module Kernel
#   #alias original_require_relative require_relative

#   # The require_relative may be used in the embedded Gem.
#   # First try to load from the built-in filesystem, and if that fails,
#   # load from the URL.
#   def require_relative(path)
#     caller_path = caller_locations(1, 1).first.absolute_path || ''
#     dir = File.dirname(caller_path)
#     file = File.absolute_path(path, dir)

#     original_require_relative(file)
#   rescue LoadError
#     JS::RequireRemote.instance.load(path)
#   end
# end
app_path = __FILE__
$0 = File::basename(app_path, ".rb") if app_path
# TODO: make sure require_relative knows where the basefolder is, so this file does not need to be in the topfolder.

require_relative "src/code_storage"


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
      puts "dont cache #{path}"
      JS::CodeStorage.instance.load(path, true)
    else
      JS::CodeStorage.instance.load(path)
    end
  end
end

require_relative "src/buttonPress"
