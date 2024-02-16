require 'js'
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative
  def require_relative(path)
    JS::RequireRemote.instance.load(path)
  end
end

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
    dont_cache = file_required_from.start_with?("/koans") == false || path == "neo"

    JS::CodeStorage.instance.load(path, dont_cache)
  end
end

app_path = __FILE__
$0 = File::basename(app_path, ".rb") if app_path


# TODO: make sure require_relative knows where the basefolder is, so this file does not need to be in the topfolder.

 # Wait for the DOM to be fully loaded
  #JS.global.document.addEventListener('DOMContentLoaded') do
    # Access the code area and set up the CodeMirror editor
    code_area = JS.global.document.getElementById("ruby-code")
    @window = JS.global
    @window.editor = @window[:CodeMirror].fromTextArea(code_area, {
      lineNumbers: true,
      mode: "text/x-ruby",
      matchBrackets: true,
      indentUnit: 4
    })
    
    define_method :click_run_button do
      code_area = JS.global.document.getElementById("ruby-code")
      @window.editor.save
      output_div = JS.global.document.getElementById("output")
      code = <<-RUBY
        pressButton {
          #{code_area.value}
        }
      RUBY

      begin
        output_div.innerHTML = Kernel.eval(code.strip)
      rescue => e
        output_div.innerHTML = e.to_s
      end
    end

    # check_interval = JS.global.setInterval(lambda {
    #   if @window.rubyVM != undefined
    #     JS.global.clearInterval(check_interval)
    #     click_run_button
    #   end
    # }, 500)

    # Set up the event listener for the run code button
    JS.global.document.getElementById("run-code").addEventListener("click") do |e|
      click_run_button
    end
 # end

require_relative "src/buttonPress"
firstTimeRun
#click_run_button()