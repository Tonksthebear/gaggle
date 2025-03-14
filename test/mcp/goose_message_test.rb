require "test_helper"

class GooseMessageTest < ActionDispatch::IntegrationTest
  include ::MCP::Rails::TestHelper

  setup do
    @server = mcp_server(name: "gaggle")
    @channel = gaggle_channels(:channel_one)
    @message = gaggle_messages(:message_one)
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
    ENV["GOOSE_USER_ID"] = @goose_one.id.to_s
  end

  test "should create message in channel and trigger callbacks" do
    assert_difference "Gaggle::Message.count", 1 do
      mcp_tool_call(@server, "create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "Hello from goose_one" } })
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

    assert_difference "Gaggle::Notification.count", 1 do
      mcp_tool_call(@server, "create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "Hello from goose_one" } })
    end
  end

  test "should not create message without content" do
    assert_no_difference "Gaggle::Message.count" do
      mcp_tool_call(@server, "create_gaggle_channels_messages", { channel_id: @channel.id.to_s, message: { content: "" } })
    end
  end
end
