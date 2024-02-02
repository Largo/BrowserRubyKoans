# The path to Ruby Enlightenment starts with the following:

#$LOAD_PATH << File.dirname(__FILE__)

require_relative 'about_asserts'
require_relative 'about_true_and_false'
require_relative 'about_strings'
require_relative 'about_symbols'
require_relative 'about_arrays'
require_relative 'about_array_assignment'
require_relative 'about_objects'
require_relative 'about_nil'
require_relative 'about_hashes'
require_relative 'about_methods'
in_ruby_version("2", "3") do
  require_relative 'about_keyword_arguments'
end
require_relative 'about_constants'
require_relative 'about_regular_expressions'
require_relative 'about_control_statements'
require_relative 'about_triangle_project'
require_relative 'about_exceptions'
require_relative 'about_triangle_project_2'
require_relative 'about_iteration'
require_relative 'about_blocks'
require_relative 'about_sandwich_code'
require_relative 'about_scoring_project'
require_relative 'about_classes'
require_relative 'about_open_classes'
require_relative 'about_dice_project'
require_relative 'about_inheritance'
require_relative 'about_modules'
require_relative 'about_scope'
require_relative 'about_class_methods'
require_relative 'about_message_passing'
require_relative 'about_proxy_object_project'
require_relative 'about_to_str'
in_ruby_version("jruby") do
  require_relative 'about_java_interop'
end
in_ruby_version("2.7") do
  require_relative 'about_pattern_matching'
end
require_relative 'about_extra_credit'
