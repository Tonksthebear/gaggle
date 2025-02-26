require "test_helper"

class GaggleTasksTest < ActiveSupport::TestCase
  teardown do
    ENV["channel_id"] = nil
    ENV["name"] = nil
    ENV["goose_ids"] = nil
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

  test "create_channel succeeds with valid name only" do
    ENV["name"] = "New Channel"
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+, name: New Channel, gooses: "\}\n$/) do
        task.invoke
      end
    end
    channel = Gaggle::Channel.last
    assert_equal "New Channel", channel.name
    assert_empty channel.goose_ids
  end

  test "create_channel succeeds with valid name and goose_id in environment" do
    goose_one = gaggle_gooses(:goose_one)

    ENV["name"] = "New Channel"
    ENV["GOOSE_ID"] = "#{goose_one.id}"
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+, name: New Channel, gooses: #{goose_one.id}"\}\n$/) do
        task.invoke
      end
    end
    channel = Gaggle::Channel.last
    assert_equal "New Channel", channel.name
    assert_equal [ goose_one.id ], channel.goose_ids
  end

  test "create_channel succeeds with valid name and goose_ids" do
    goose_one = gaggle_gooses(:goose_one)
    goose_two = gaggle_gooses(:goose_two)
    ENV["name"] = "New Channel with Gooses"
    ENV["goose_ids"] = "#{goose_one.id},#{goose_two.id}"
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+, name: New Channel with Gooses, gooses: #{goose_one.id}, #{goose_two.id}"\}\n$/) do
        task.invoke
      end
    end
    channel = Gaggle::Channel.last
    assert_equal "New Channel with Gooses", channel.name
    assert_equal [ goose_one.id, goose_two.id ].sort, channel.goose_ids.sort
  end

  test "create_channel succeeds with valid name, goose_ids, and goose_id in environment" do
    goose_one = gaggle_gooses(:goose_one)
    goose_two = gaggle_gooses(:goose_two)
    ENV["name"] = "New Channel with Gooses"
    ENV["goose_ids"] = goose_two.id.to_s
    ENV["GOOSE_ID"] = goose_one.id.to_s
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+, name: New Channel with Gooses, gooses: #{goose_two.id}, #{goose_one.id}"\}\n$/) do
        task.invoke
      end
    end
    channel = Gaggle::Channel.last
    assert_equal "New Channel with Gooses", channel.name
    assert_equal [ goose_one.id, goose_two.id ].sort, channel.goose_ids.sort
  end

  test "create_channel fails with non-numeric goose_ids" do
    ENV["name"] = "New Channel"
    ENV["goose_ids"] = "abc,123"
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_output("Error: All goose IDs must be numeric.\n") do
      task.invoke
    end
    assert_no_difference "Gaggle::Channel.count" do
      task.invoke
    end
  end

  test "create_channel fails with invalid goose_ids" do
    ENV["name"] = "New Channel"
    ENV["goose_ids"] = "9999"
    ENV["GOOSE_ID"] = nil
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_output("Error: Gaggle::Goose IDs not found: 9999\n") do
      task.invoke
    end
    assert_no_difference "Gaggle::Channel.count" do
      task.invoke
    end
  end

  test "create_channel ignores non-numeric GOOSE_ID" do
    ENV["name"] = "New Channel"
    ENV["GOOSE_ID"] = "abc"
    task = Rake::Task["gaggle:create_channel"]
    task.reenable
    assert_difference "Gaggle::Channel.count", 1 do
      assert_output(/^\{"status":"success","message":"Created channel with ID: \d+, name: New Channel, gooses: "\}\n$/) do
        task.invoke
      end
    end
    channel = Gaggle::Channel.last
    assert_equal "New Channel", channel.name
    assert_empty channel.goose_ids
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
    assert_output("Error: Channel name is required.\n") do # Updated error message
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

  test "update_channel succeeds with valid name only" do
    channel = gaggle_channels(:channel_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["name"] = "Updated Channel"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output(/^\{"status":"success","message":"Updated channel with ID: #{channel.id}, name: Updated Channel, gooses: #{channel.goose_ids.join(', ')}"\}\n$/) do
      task.invoke
    end
    channel.reload
    assert_equal "Updated Channel", channel.name
    assert_equal [ gaggle_gooses(:goose_one).id ], channel.goose_ids # From fixture
  end

  test "update_channel succeeds with valid name and goose_ids" do
    channel = gaggle_channels(:channel_one)
    goose_one = gaggle_gooses(:goose_one) # id: 538554782
    goose_two = gaggle_gooses(:goose_two) # id: 197115146
    ENV["channel_id"] = channel.id.to_s
    ENV["name"] = "Updated Channel with Gooses"
    ENV["goose_ids"] = "#{goose_one.id},#{goose_two.id}"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output(/^\{"status":"success","message":"Updated channel with ID: #{channel.id}, name: Updated Channel with Gooses, gooses: #{goose_one.id}, #{goose_two.id}"\}\n$/) do
      task.invoke
    end
    channel.reload
    assert_equal "Updated Channel with Gooses", channel.name
    assert_equal [ goose_one.id, goose_two.id ].sort, channel.goose_ids.sort # Sort to ignore order
  end

  test "update_channel fails with non-numeric goose_ids" do
    ENV["channel_id"] = gaggle_channels(:channel_one).id.to_s
    ENV["name"] = "Updated Channel"
    ENV["goose_ids"] = "abc,123"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: All goose IDs must be numeric.\n") do
      task.invoke
    end
  end

  test "update_channel fails with invalid goose_ids" do
    channel = gaggle_channels(:channel_one)
    ENV["channel_id"] = channel.id.to_s
    ENV["name"] = "Updated Channel"
    ENV["goose_ids"] = "9999"
    task = Rake::Task["gaggle:update_channel"]
    task.reenable
    assert_output("Error: Gaggle::Goose IDs not found: 9999\n") do
      task.invoke
    end
    channel.reload
    assert_equal "channel_one", channel.name # Unchanged
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
    task = Rake::Task["gaggle:get_channel_messages"] # Fixed task name
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
