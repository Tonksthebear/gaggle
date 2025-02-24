# test/tasks/gaggle_tasks_test.rb
require "test_helper"

class GaggleTasksTest < ActiveSupport::TestCase
  teardown do
    ENV["GOOSE_ID"] = nil
  end

  test "get_goose_notifications fails when GOOSE_ID is not provided" do
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:get_goose_notifications"]
    task.reenable # Reset before running
    assert_output("Error: Goose ID is required.\n") do
      task.invoke
    end
  end

  test "get_goose_notifications outputs unread notifications as JSON for goose_one" do
    goose = gaggle_gooses(:goose_one)
    notification = gaggle_notifications(:notification_one)
    message = gaggle_messages(:message_one)

    ENV["GOOSE_ID"] = goose.id.to_s

    expected_notifications = [
      { id: notification.id, message_id: message.id, read_at: nil }
    ]
    expected_output = "#{JSON.generate(expected_notifications)}\n"

    task = Rake::Task["gaggle:get_goose_notifications"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end

  test "get_goose_notifications outputs empty array when no unread notifications" do
    goose = gaggle_gooses(:goose_two)
    notification = gaggle_notifications(:notification_two)
    notification.update!(read_at: Time.now)

    ENV["GOOSE_ID"] = goose.id.to_s

    expected_output = "[]\n"
    task = Rake::Task["gaggle:get_goose_notifications"]
    task.reenable # Reset before running
    assert_output(expected_output) do
      task.invoke
    end
  end

  test "get_goose_notifications fails when GOOSE_ID is invalid" do
    ENV["GOOSE_ID"] = "9999"
    task = Rake::Task["gaggle:get_goose_notifications"]
    task.reenable # Reset before running
    assert_output("Error: Goose with ID 9999 not found.\n") do
      task.invoke
    end
  end
end
