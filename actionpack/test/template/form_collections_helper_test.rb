require 'abstract_unit'

class Category < Struct.new(:id, :name)
end

class FormCollectionsHelperTest < ActionView::TestCase
  def assert_no_select(selector, value = nil)
    assert_select(selector, :text => value, :count => 0)
  end

  def with_collection_radio_buttons(*args, &block)
    @output_buffer = collection_radio_buttons(*args, &block)
  end

  def with_collection_check_boxes(*args, &block)
    @output_buffer = collection_check_boxes(*args, &block)
  end

  # COLLECTION RADIO BUTTONS
  test 'collection radio accepts a collection and generate inputs from value method' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select 'input[type=radio][value=true]#user_active_true'
    assert_select 'input[type=radio][value=false]#user_active_false'
  end

  test 'collection radio accepts a collection and generate inputs from label method' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select 'label[for=user_active_true]', 'true'
    assert_select 'label[for=user_active_false]', 'false'
  end

  test 'collection radio handles camelized collection values for labels correctly' do
    with_collection_radio_buttons :user, :active, ['Yes', 'No'], :to_s, :to_s

    assert_select 'label[for=user_active_yes]', 'Yes'
    assert_select 'label[for=user_active_no]', 'No'
  end

  test 'colection radio should sanitize collection values for labels correctly' do
    with_collection_radio_buttons :user, :name, ['$0.99', '$1.99'], :to_s, :to_s
    assert_select 'label[for=user_name_099]', '$0.99'
    assert_select 'label[for=user_name_199]', '$1.99'
  end

  test 'collection radio accepts checked item' do
    with_collection_radio_buttons :user, :active, [[1, true], [0, false]], :last, :first, :checked => true

    assert_select 'input[type=radio][value=true][checked=checked]'
    assert_no_select 'input[type=radio][value=false][checked=checked]'
  end

  test 'collection radio accepts multiple disabled items' do
    collection = [[1, true], [0, false], [2, 'other']]
    with_collection_radio_buttons :user, :active, collection, :last, :first, :disabled => [true, false]

    assert_select 'input[type=radio][value=true][disabled=disabled]'
    assert_select 'input[type=radio][value=false][disabled=disabled]'
    assert_no_select 'input[type=radio][value=other][disabled=disabled]'
  end

  test 'collection radio accepts single disable item' do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, :disabled => true

    assert_select 'input[type=radio][value=true][disabled=disabled]'
    assert_no_select 'input[type=radio][value=false][disabled=disabled]'
  end

  test 'collection radio accepts html options as input' do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, {}, :class => 'special-radio'

    assert_select 'input[type=radio][value=true].special-radio#user_active_true'
    assert_select 'input[type=radio][value=false].special-radio#user_active_false'
  end

  test 'collection radio does not wrap input inside the label' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select 'input[type=radio] + label'
    assert_no_select 'label input'
  end

  test 'collection radio accepts a block to render the label as radio button wrapper' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label { b.radio_button }
    end

    assert_select 'label[for=user_active_true] > input#user_active_true[type=radio]'
    assert_select 'label[for=user_active_false] > input#user_active_false[type=radio]'
  end

  test 'collection radio accepts a block to change the order of label and radio button' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label + b.radio_button
    end

    assert_select 'label[for=user_active_true] + input#user_active_true[type=radio]'
    assert_select 'label[for=user_active_false] + input#user_active_false[type=radio]'
  end

  test 'collection radio with block helpers accept extra html options' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:class => "radio_button") + b.radio_button(:class => "radio_button")
    end

    assert_select 'label.radio_button[for=user_active_true] + input#user_active_true.radio_button[type=radio]'
    assert_select 'label.radio_button[for=user_active_false] + input#user_active_false.radio_button[type=radio]'
  end

  test 'collection radio with block helpers allows access to current text and value' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:"data-value" => b.value) { b.radio_button + b.text }
    end

    assert_select 'label[for=user_active_true][data-value=true]', 'true' do
      assert_select 'input#user_active_true[type=radio]'
    end
    assert_select 'label[for=user_active_false][data-value=false]', 'false' do
      assert_select 'input#user_active_false[type=radio]'
    end
  end

  test 'collection radio with block helpers allows access to the current object item in the collection to access extra properties' do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:class => b.object) { b.radio_button + b.text }
    end

    assert_select 'label.true[for=user_active_true]', 'true' do
      assert_select 'input#user_active_true[type=radio]'
    end
    assert_select 'label.false[for=user_active_false]', 'false' do
      assert_select 'input#user_active_false[type=radio]'
    end
  end

  test 'collection radio buttons with fields for' do
    collection = [Category.new(1, 'Category 1'), Category.new(2, 'Category 2')]
    @output_buffer = fields_for(:post) do |p|
      p.collection_radio_buttons :category_id, collection, :id, :name
    end

    assert_select 'input#post_category_id_1[type=radio][value=1]'
    assert_select 'input#post_category_id_2[type=radio][value=2]'

    assert_select 'label[for=post_category_id_1]', 'Category 1'
    assert_select 'label[for=post_category_id_2]', 'Category 2'
  end

  # COLLECTION CHECK BOXES
  test 'collection check boxes accepts a collection and generate a serie of checkboxes for value method' do
    collection = [Category.new(1, 'Category 1'), Category.new(2, 'Category 2')]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select 'input#user_category_ids_1[type=checkbox][value=1]'
    assert_select 'input#user_category_ids_2[type=checkbox][value=2]'
  end

  test 'collection check boxes generates only one hidden field for the entire collection, to ensure something will be sent back to the server when posting an empty collection' do
    collection = [Category.new(1, 'Category 1'), Category.new(2, 'Category 2')]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select "input[type=hidden][name='user[category_ids][]'][value=]", :count => 1
  end

  test 'collection check boxes accepts a collection and generate a serie of checkboxes with labels for label method' do
    collection = [Category.new(1, 'Category 1'), Category.new(2, 'Category 2')]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select 'label[for=user_category_ids_1]', 'Category 1'
    assert_select 'label[for=user_category_ids_2]', 'Category 2'
  end

  test 'collection check boxes handles camelized collection values for labels correctly' do
    with_collection_check_boxes :user, :active, ['Yes', 'No'], :to_s, :to_s

    assert_select 'label[for=user_active_yes]', 'Yes'
    assert_select 'label[for=user_active_no]', 'No'
  end

  test 'colection check box should sanitize collection values for labels correctly' do
    with_collection_check_boxes :user, :name, ['$0.99', '$1.99'], :to_s, :to_s
    assert_select 'label[for=user_name_099]', '$0.99'
    assert_select 'label[for=user_name_199]', '$1.99'
  end

  test 'collection check boxes accepts selected values as :checked option' do
    collection = (1..3).map{|i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, :checked => [1, 3]

    assert_select 'input[type=checkbox][value=1][checked=checked]'
    assert_select 'input[type=checkbox][value=3][checked=checked]'
    assert_no_select 'input[type=checkbox][value=2][checked=checked]'
  end

  test 'collection check boxes accepts a single checked value' do
    collection = (1..3).map{|i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, :checked => 3

    assert_select 'input[type=checkbox][value=3][checked=checked]'
    assert_no_select 'input[type=checkbox][value=1][checked=checked]'
    assert_no_select 'input[type=checkbox][value=2][checked=checked]'
  end

  test 'collection check boxes accepts selected values as :checked option and override the model values' do
    user = Struct.new(:category_ids).new(2)
    collection = (1..3).map{|i| [i, "Category #{i}"] }

    @output_buffer = fields_for(:user, user) do |p|
      p.collection_check_boxes :category_ids, collection, :first, :last, :checked => [1, 3]
    end

    assert_select 'input[type=checkbox][value=1][checked=checked]'
    assert_select 'input[type=checkbox][value=3][checked=checked]'
    assert_no_select 'input[type=checkbox][value=2][checked=checked]'
  end

  test 'collection check boxes accepts multiple disabled items' do
    collection = (1..3).map{|i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, :disabled => [1, 3]

    assert_select 'input[type=checkbox][value=1][disabled=disabled]'
    assert_select 'input[type=checkbox][value=3][disabled=disabled]'
    assert_no_select 'input[type=checkbox][value=2][disabled=disabled]'
  end

  test 'collection check boxes accepts single disable item' do
    collection = (1..3).map{|i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, :disabled => 1

    assert_select 'input[type=checkbox][value=1][disabled=disabled]'
    assert_no_select 'input[type=checkbox][value=3][disabled=disabled]'
    assert_no_select 'input[type=checkbox][value=2][disabled=disabled]'
  end

  test 'collection check boxes accepts a proc to disabled items' do
    collection = (1..3).map{|i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, :disabled => proc { |i| i.first == 1 }

    assert_select 'input[type=checkbox][value=1][disabled=disabled]'
    assert_no_select 'input[type=checkbox][value=3][disabled=disabled]'
    assert_no_select 'input[type=checkbox][value=2][disabled=disabled]'
  end

  test 'collection check boxes accepts html options' do
    collection = [[1, 'Category 1'], [2, 'Category 2']]
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, {}, :class => 'check'

    assert_select 'input.check[type=checkbox][value=1]'
    assert_select 'input.check[type=checkbox][value=2]'
  end

  test 'collection check boxes with fields for' do
    collection = [Category.new(1, 'Category 1'), Category.new(2, 'Category 2')]
    @output_buffer = fields_for(:post) do |p|
      p.collection_check_boxes :category_ids, collection, :id, :name
    end

    assert_select 'input#post_category_ids_1[type=checkbox][value=1]'
    assert_select 'input#post_category_ids_2[type=checkbox][value=2]'

    assert_select 'label[for=post_category_ids_1]', 'Category 1'
    assert_select 'label[for=post_category_ids_2]', 'Category 2'
  end

  test 'collection check boxes does not wrap input inside the label' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s

    assert_select 'input[type=checkbox] + label'
    assert_no_select 'label input'
  end

  test 'collection check boxes accepts a block to render the label as check box wrapper' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label { b.check_box }
    end

    assert_select 'label[for=user_active_true] > input#user_active_true[type=checkbox]'
    assert_select 'label[for=user_active_false] > input#user_active_false[type=checkbox]'
  end

  test 'collection check boxes accepts a block to change the order of label and check box' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label + b.check_box
    end

    assert_select 'label[for=user_active_true] + input#user_active_true[type=checkbox]'
    assert_select 'label[for=user_active_false] + input#user_active_false[type=checkbox]'
  end

  test 'collection check boxes with block helpers accept extra html options' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:class => "check_box") + b.check_box(:class => "check_box")
    end

    assert_select 'label.check_box[for=user_active_true] + input#user_active_true.check_box[type=checkbox]'
    assert_select 'label.check_box[for=user_active_false] + input#user_active_false.check_box[type=checkbox]'
  end

  test 'collection check boxes with block helpers allows access to current text and value' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:"data-value" => b.value) { b.check_box + b.text }
    end

    assert_select 'label[for=user_active_true][data-value=true]', 'true' do
      assert_select 'input#user_active_true[type=checkbox]'
    end
    assert_select 'label[for=user_active_false][data-value=false]', 'false' do
      assert_select 'input#user_active_false[type=checkbox]'
    end
  end

  test 'collection check boxes with block helpers allows access to the current object item in the collection to access extra properties' do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:class => b.object) { b.check_box + b.text }
    end

    assert_select 'label.true[for=user_active_true]', 'true' do
      assert_select 'input#user_active_true[type=checkbox]'
    end
    assert_select 'label.false[for=user_active_false]', 'false' do
      assert_select 'input#user_active_false[type=checkbox]'
    end
  end
end
