class AboutIteration < Neo::Koan
  def test_each_is_a_method_on_arrays
    assert_equal __, [].methods.include?(:each)
  end

  def test_iterating_with_each
    array = [1, 2, 3]
    sum = 0
    array.each do |item|
      sum += item
    end
    assert_equal __, sum
  end

  def test_each_can_use_curly_brace_blocks_too
    array = [1, 2, 3]
    sum = 0
    array.each { |item| sum += item }
    assert_equal __, sum
  end

  def test_break_works_with_each_style_iterations
    array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sum = 0
    array.each do |item|
      break if item > 3
      sum += item
    end
    assert_equal __, sum
  end

  def test_collect_transforms_elements_of_an_array
    array = [1, 2, 3]
    new_array = array.collect { |item| item + 10 }
    assert_equal __, new_array

    # NOTE: 'map' is another name for the 'collect' operation
    another_array = array.map { |item| item + 10 }
    assert_equal __, another_array
  end

  def test_select_selects_certain_items_from_an_array
    array = [1, 2, 3, 4, 5, 6]

    even_numbers = array.select { |item| (item % 2) == 0 }
    assert_equal __, even_numbers

    # NOTE: 'find_all' is another name for the 'select' operation
    more_even_numbers = array.find_all { |item| (item % 2) == 0 }
    assert_equal __, more_even_numbers
  end

  def test_find_locates_the_first_element_matching_a_criteria
    array = ["Jim", "Bill", "Clarence", "Doug", "Eli"]

    assert_equal __, array.find { |item| item.size > 4 }
  end

  def test_inject_will_blow_your_mind
    result = [2, 3, 4].inject(0) { |sum, item| sum + item }
    assert_equal __, result

    result2 = [2, 3, 4].inject(1) { |product, item| product * item }
    assert_equal __, result2

    # Extra Credit:
    # Describe in your own words what inject does.
  end
end
