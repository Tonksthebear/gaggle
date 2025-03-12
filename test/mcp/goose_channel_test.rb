require "mcp_test_helper"

class GooseChannelTest < MCPTestHelper
  setup do
    @channel = gaggle_channels(:channel_one)
    @message = gaggle_messages(:message_one)
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
  end

  test "should show channel" do
    within_server(@goose_one) do |stdin, stdout|
      tool_call = call_tool("show_gaggle_channels", { id: @channel.id.to_s })
      output = write_to_mcp_server(tool_call)
      assert output.include?("channel_one"), "Missing 'channel_one' in '#{output}'"
      assert output.include?("Hello from goose_one in channel_one"), "Missing 'goose_one' in '#{output}'"
    end
  end

  test "should show new messages only" do
    Gaggle::Notification.destroy_all
    new_message = @channel.messages.create!(content: "hello there")

    within_server(@goose_one) do |stdin, stdout|
      tool_call = call_tool("show_gaggle_channels", { id: @channel.id.to_s })
      output = write_to_mcp_server(tool_call)
      assert_not output.include?(@message.content), "Should not contain #{@message.content} in '#{output}'"
      assert output.include?(new_message.content), "Missing #{new_message.content} in '#{output}'"
    end
  end

  test "should create channel and auto assign goose" do
    within_server(@goose_one) do |stdin, stdout|
      assert_difference "Gaggle::Channel.count", 1 do
        tool_call = call_tool("create_gaggle_channels", { channel: { name: "New Channel" } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("New Channel"), "Missing 'New Channel' in '#{output}'"
      end
    end

    new_channel = Gaggle::Channel.last
    assert_equal "New Channel", new_channel.name
    assert new_channel.gooses.include?(@goose_one)
  end

  test "should not create channel without name" do
    within_server(@goose_one) do |stdin, stdout|
      assert_no_difference "Gaggle::Channel.count" do
        tool_call = call_tool("create_gaggle_channels", { channel: { goose_ids: [ @goose_two.id.to_s ] } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("Missing required param channel.name"), "Missing 'Name is required' in '#{output}'"
      end
    end
  end

  test "should update channel name" do
    within_server(@goose_one) do |stdin, stdout|
      assert_changes "@channel.reload.name", to: "New Name" do
        tool_call = call_tool("update_gaggle_channels", { id: @channel.id.to_s, channel: { name: "New Name" } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("New Name")
      end
    end
  end

  test "should update channel goose ids" do
    @channel.goose_ids = [ @goose_one.id.to_s ]
    within_server(@goose_one) do |stdin, stdout|
      assert_difference "@channel.reload.goose_ids.count", 1 do
        tool_call = call_tool("update_gaggle_channels", { id: @channel.id.to_s, channel: { goose_ids: [ @goose_two.id.to_s ] } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("channel_one")
      end
    end
  end

  test "should destroy channel" do
    within_server(@goose_one) do |stdin, stdout|
      assert_difference "Gaggle::Channel.count", -1 do
        tool_call = call_tool("destroy_gaggle_channels", { id: @channel.id.to_s })
        output = write_to_mcp_server(tool_call)
        assert output.include?("channel_one was successfully destroyed")
      end
    end
  end
end
