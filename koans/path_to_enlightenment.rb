# The path to Ruby Enlightenment starts with the following:

#$LOAD_PATH << File.dirname(__FILE__)
require_relative("neo")

$koans = [
  'about_asserts',
  'about_true_and_false',
  'about_strings',
  'about_symbols',
  'about_arrays',
  'about_array_assignment',
  'about_objects',
  'about_nil',
  'about_hashes',
  'about_methods',
  'about_keyword_arguments',
  'about_constants',
  'about_regular_expressions',
  'about_control_statements',
 # 'about_triangle_project',
  'about_exceptions',
 # 'about_triangle_project_2',
  'about_iteration',
  'about_blocks',
 # 'about_sandwich_code',
  'about_scoring_project',
  'about_classes',
  'about_open_classes',
  'about_dice_project',
  'about_inheritance',
  'about_modules',
  'about_scope',
  'about_class_methods',
  'about_message_passing',
  'about_proxy_object_project',
  'about_to_str',
  'about_pattern_matching', # test
  'about_extra_credit'
]

$koans.each { |koan| require_relative koan }

