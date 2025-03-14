require "test_helper"

class GooseChannelTest < ActionDispatch::IntegrationTest
  include MCP::Rails::TestHelper

  setup do
    @server = mcp_server(name: "gaggle")
    @channel = gaggle_channels(:channel_one)
    @message = gaggle_messages(:message_one)
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
    ENV["GOOSE_USER_ID"] = @goose_one.id.to_s
  end

  test "should show channel" do
    mcp_tool_call(@server, "show_gaggle_channels", { id: @channel.id.to_s })
    assert_equal "channel_one", mcp_response_body["name"]
    assert mcp_response_body["messages"].to_s.include?("Hello from goose_one in channel_one"), "Missing 'goose_one' in '#{mcp_response_body}'"
  end

  test "should show new messages only" do
    Gaggle::Notification.destroy_all
    new_message = @channel.messages.create!(content: "hello there")

    mcp_tool_call(@server, "show_gaggle_channels", { id: @channel.id.to_s })
    assert_not mcp_response_body["messages"].to_s.include?(@message.content), "Should not contain #{@message.content} in '#{mcp_response_body}'"
    assert mcp_response_body["messages"].to_s.include?(new_message.content), "Missing #{new_message.content} in '#{mcp_response_body}'"
  end

  test "should create channel and auto assign goose" do
    assert_difference "Gaggle::Channel.count", 1 do
      mcp_tool_call(@server, "create_gaggle_channels", { channel: { name: "New Channel" } })
      assert_equal "New Channel", mcp_response_body["name"]
    end

    new_channel = Gaggle::Channel.last
    assert_equal "New Channel", new_channel.name
    assert new_channel.gooses.include?(@goose_one)
  end

  test "should not create channel without name" do
    assert_no_difference "Gaggle::Channel.count" do
      assert_raises "Missing required param channel.name" do
        mcp_tool_call(@server, "create_gaggle_channels", { channel: { goose_ids: [ @goose_two.id.to_s ] } })
      end
    end
  end

  test "should update channel name" do
    assert_changes "@channel.reload.name", to: "New Name" do
      mcp_tool_call(@server, "update_gaggle_channels", { id: @channel.id.to_s, channel: { name: "New Name" } })
      assert_equal "New Name", mcp_response_body["name"]
    end
  end

  test "should update channel goose ids" do
    @channel.goose_ids = [ @goose_one.id.to_s ]
    assert_difference "@channel.reload.goose_ids.count", 1 do
      mcp_tool_call(@server, "update_gaggle_channels", { id: @channel.id.to_s, channel: { goose_ids: [ @goose_two.id.to_s ] } })
      assert_equal "channel_one", mcp_response_body["name"]
    end
  end

  test "should destroy channel" do
    assert_difference "Gaggle::Channel.count", -1 do
      mcp_tool_call(@server, "destroy_gaggle_channels", { id: @channel.id.to_s })
      assert_equal "channel_one was successfully destroyed.", mcp_response_body
    end
  end
end
