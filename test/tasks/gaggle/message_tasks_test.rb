# test/tasks/gaggle_tasks_test.rb
require "test_helper"
require "mocha/minitest"

class GaggleTasksTest < ActiveSupport::TestCase
  teardown do
    ENV["channel_id"] = nil
    ENV["GOOSE_ID"] = nil
    ENV["content"] = nil
  end

  test "send_public_message fails when channel_id is blank" do
    ENV["channel_id"] = nil
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Channel ID, Goose ID, and content are required.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when GOOSE_ID is blank" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = nil
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Channel ID, Goose ID, and content are required.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when content is blank" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    ENV["content"] = nil
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Channel ID, Goose ID, and content are required.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when channel_id is non-numeric" do
    ENV["channel_id"] = "abc"
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID must be numeric.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when GOOSE_ID is non-numeric" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = "xyz"
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID must be numeric.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when channel_id is invalid" do
    ENV["channel_id"] = "9999"
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Gaggle::Channel with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "send_public_message fails when GOOSE_ID is invalid" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = "9999"
    ENV["content"] = "Hello"
    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_output("Error: Gaggle::Goose with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "send_public_message succeeds with valid inputs" do
    channel = gaggle_channels(:channel_one)
    goose = gaggle_gooses(:goose_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["GOOSE_ID"] = goose.id.to_s
    ENV["content"] = "Hello from test"

    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_difference "Gaggle::Message.count", 1 do
      assert_output(/^\{"status":"success","message":"Sent message to channel 'channel_one' from Goose ID: #{goose.id}","message_id":\d+\}\n$/) do
        task.invoke
      end
    end

    message = Gaggle::Message.last
    assert_equal channel, message.messageable
    assert_equal goose, message.goose
    assert_equal "Hello from test", message.content
  end

  test "send_public_message succeeds with STDIN content" do
    channel = gaggle_channels(:channel_one)
    goose = gaggle_gooses(:goose_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["GOOSE_ID"] = goose.id.to_s
    ENV["content"] = nil

    task = Rake::Task["gaggle:send_public_message"]
    task.reenable
    assert_difference "Gaggle::Message.count", 1 do
      assert_output(/^\{"status":"success","message":"Sent message to channel 'channel_one' from Goose ID: #{goose.id}","message_id":\d+\}\n$/) do
        original_stdin = $stdin
        $stdin.stubs(:read).returns("Piped message\n") # Stub $stdin.read directly
        $stdin.stubs(:tty?).returns(false) # Ensure tty? is false
        task.invoke
        $stdin = original_stdin
      end
    end

    message = Gaggle::Message.last
    assert_equal "Piped message", message.content
  end
end
