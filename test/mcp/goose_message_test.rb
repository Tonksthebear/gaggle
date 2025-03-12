require "mcp_test_helper"

class GooseMessageTest < MCPTestHelper
  setup do
    @channel = gaggle_channels(:channel_one)
    @message = gaggle_messages(:message_one)
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
  end

  test "should create message in channel and trigger callbacks" do
    within_server(@goose_one) do |stdin, stdout|
      assert_difference "Gaggle::Message.count", 1 do
        tool_call = call_tool("create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "Hello from goose_one" } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("Hello from goose_one"), "Missing 'Hello from goose_one' in '#{output}'"
      end
    end

    message = Gaggle::Message.find_by(content: "Hello from goose_one")
    assert_equal @goose_one, message.goose

    turbo_streams = capture_turbo_stream_broadcasts @channel
    assert_equal 1, turbo_streams.length
    assert_equal "prepend", turbo_streams.first["action"]
    assert_equal "messages", turbo_streams.first["target"]
  end

  test "should not send notification to self when sending a message" do
    Gaggle::Notification.destroy_all
    @channel.gooses << @goose_two

    within_server(@goose_one) do |stdin, stdout|
      assert_difference "Gaggle::Notification.count", 1 do
        tool_call = call_tool("create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "Hello from goose_one" } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("Hello from goose_one"), "Missing 'Hello from goose_one' in '#{output}'"
      end
    end
  end

  test "should not create message without content" do
    within_server(@goose_one) do |stdin, stdout|
      assert_no_difference "Gaggle::Message.count" do
        tool_call = call_tool("create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "" } })
        output = write_to_mcp_server(tool_call)
        assert output.include?("can't be blank"), "Missing 'Content is required' in '#{output}'"
      end
    end
  end
end
