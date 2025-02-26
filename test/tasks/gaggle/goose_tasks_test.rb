# test/tasks/gaggle_tasks_test.rb
require "test_helper"

class GaggleTasksTest < ActiveSupport::TestCase
  teardown do
    ENV["goose_id"] = nil # Clean up ENV after each test
  end

  test "goose_list outputs all gooses as JSON when no goose_id is provided" do
    goose_one = gaggle_gooses(:goose_one)
    goose_two = gaggle_gooses(:goose_two)

    expected_output = [
      { id: goose_one.id, name: goose_one.name },
      { id: goose_two.id, name: goose_two.name }
    ].to_json + "\n" # puts adds a newline

    task = Rake::Task["gaggle:goose_list"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end

  test "goose_list excludes the goose with the specified goose_id" do
    goose_one = gaggle_gooses(:goose_one)
    goose_two = gaggle_gooses(:goose_two)

    ENV["goose_id"] = goose_two.id.to_s

    expected_output = [
      { id: goose_one.id, name: goose_one.name }
    ].to_json + "\n"

    task = Rake::Task["gaggle:goose_list"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end

  test "goose_list outputs empty array when no gooses exist" do
    Gaggle::Goose.destroy_all # Clear all gooses

    expected_output = "[]\n"

    task = Rake::Task["gaggle:goose_list"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end

  test "goose_list outputs all gooses when goose_id is invalid" do
    goose_one = gaggle_gooses(:goose_one)
    goose_two = gaggle_gooses(:goose_two)

    ENV["goose_id"] = "9999" # Invalid ID

    expected_output = [
      { id: goose_one.id, name: goose_one.name },
      { id: goose_two.id, name: goose_two.name }
    ].to_json + "\n"

    task = Rake::Task["gaggle:goose_list"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end
end
