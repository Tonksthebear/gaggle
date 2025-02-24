require "test_helper"

class GaggleTasksTest < ActiveSupport::TestCase
  teardown do
    ENV["channel_id"] = nil
    ENV["name"] = nil
    ENV["GOOSE_ID"] = nil
  end

  test "get_channels lists all channels" do
    channel_one = gaggle_channels(:channel_one) # id: 667504949
    channel_two = gaggle_channels(:channel_two) # id: 208625059
    expected = [
      { id: channel_two.id, name: "channel_two" }, # Lower ID first (208625059)
      { id: channel_one.id, name: "channel_one" }  # Then 667504949
    ]
    task = Rake::Task["gaggle:get_channels"]
    task.reenable
    assert_output("#{JSON.generate(expected)}\n") do
      task.invoke
    end
  end

  test "create_channel fails when name is blank" do
    ENV["name"] = nil
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_output("Error: Channel name is required.\n") do
      task.invoke
    end
  end

  test "create_channel succeeds with valid name" do
    ENV["name"] = "New Channel"
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+ and name: New Channel"\}\n$/) do
        task.invoke
      end
    end
    assert_equal "New Channel", Gaggle::Channel.last.name
  end

  test "update_channel fails when channel_id is blank" do
    ENV["channel_id"] = nil
    ENV["name"] = "Updated Name"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: Channel ID and name are required.\n") do
      task.invoke
    end
  end

  test "update_channel fails when name is blank" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["name"] = nil
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: Channel ID and name are required.\n") do
      task.invoke
    end
  end

  test "update_channel fails when channel_id is non-numeric" do
    ENV["channel_id"] = "abc"
    ENV["name"] = "Updated Name"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: Channel ID must be numeric.\n") do
      task.invoke
    end
  end

  test "update_channel fails when channel_id is invalid" do
    ENV["channel_id"] = "9999"
    ENV["name"] = "Updated Name"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: Gaggle::Channel with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "update_channel succeeds with valid inputs" do
    channel = gaggle_channels(:channel_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["name"] = "Updated Channel"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("{\"status\":\"success\",\"message\":\"Updated channel with ID: #{channel.id} and name: Updated Channel\"}\n") do
      task.invoke
    end
    assert_equal "Updated Channel", channel.reload.name
  end

  test "delete_channel fails when channel_id is blank" do
    ENV["channel_id"] = nil
    task = Rake::Task["gaggle:delete_channel"]
    task.reenable
    assert_output("Error: Channel ID is required.\n") do
      task.invoke
    end
  end

  test "delete_channel fails when channel_id is non-numeric" do
    ENV["channel_id"] = "abc"
    task = Rake::Task["gaggle:delete_channel"]
    task.reenable
    assert_output("Error: Channel ID must be numeric.\n") do
      task.invoke
    end
  end

  test "delete_channel fails when channel_id is invalid" do
    ENV["channel_id"] = "9999"
    task = Rake::Task["gaggle:delete_channel"]
    task.reenable
    assert_output("Error: Gaggle::Channel with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "delete_channel succeeds with valid channel_id" do
    channel = gaggle_channels(:channel_one)
    ENV["channel_id"] = channel.id.to_s
    task = Rake::Task["gaggle:delete_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", -1 do
      assert_output("{\"status\":\"success\",\"message\":\"Deleted channel with ID: #{channel.id}\"}\n") do
        task.invoke
      end
    end
  end

  test "get_channel_messages fails when channel_id is blank" do
    ENV["channel_id"] = nil
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID are required.\n") do
      task.invoke
    end
  end

  test "get_channel_messages fails when goose_id is blank" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID are required.\n") do
      task.invoke
    end
  end

  test "get_channel_messages fails when channel_id is non-numeric" do
    ENV["channel_id"] = "abc"
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID must be numeric.\n") do
      task.invoke
    end
  end

  test "get_channel_messages fails when goose_id is non-numeric" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = "xyz"
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Channel ID and Goose ID must be numeric.\n") do
      task.invoke
    end
  end

  test "get_channel_messages fails when channel_id is invalid" do
    ENV["channel_id"] = "9999"
    ENV["GOOSE_ID"] = gaggle_gooses(:goose_one).id.to_s
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Gaggle::Channel with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "get_channel_messages fails when goose_id is invalid" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["GOOSE_ID"] = "9999"
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("Error: Gaggle::Goose with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "get_channel_messages succeeds with valid inputs" do
    channel = gaggle_channels(:channel_one)
    goose = gaggle_gooses(:goose_one)
    message = gaggle_messages(:message_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["GOOSE_ID"] = goose.id.to_s
    expected = [ {
      content: message.content,
      user_name: message.user_name,
      user_id: message.goose_id
    } ]
    task = Rake::Task["gaggle:get_channel_messages"]
    task.reenable
    assert_output("#{JSON.generate(expected)}\n") do
      task.invoke
    end
  end

  test "get_unread_channels fails when goose_id is blank" do
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:get_unread_channels"]
    task.reenable
    assert_output("Error: Goose ID is required.\n") do
      task.invoke
    end
  end

  test "get_unread_channels fails when goose_id is non-numeric" do
    ENV["GOOSE_ID"] = "xyz"
    task = Rake::Task["gaggle:get_unread_channels"]
    task.reenable
    assert_output("Error: Goose ID must be numeric.\n") do
      task.invoke
    end
  end

  test "get_unread_channels fails when goose_id is invalid" do
    ENV["GOOSE_ID"] = "9999"
    task = Rake::Task["gaggle:get_unread_channels"]
    task.reenable
    assert_output("Error: Gaggle::Goose with ID 9999 not found.\n") do
      task.invoke
    end
  end

  test "get_unread_channels succeeds with valid goose_id" do
    goose = gaggle_gooses(:goose_one)
    channel = gaggle_channels(:channel_one)
    ENV["GOOSE_ID"] = goose.id.to_s
    expected = [ { type: "Gaggle::Channel", id: channel.id } ]
    task = Rake::Task["gaggle:get_unread_channels"]
    task.reenable
    assert_output("#{JSON.generate(expected)}\n") do
      task.invoke
    end
  end
end
