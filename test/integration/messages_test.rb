require "test_helper"

class MessagesTest < ActionDispatch::IntegrationTest
  setup do
    @channel = gaggle_channels(:channel_one)
    @message = gaggle_messages(:message_one)
    @goose = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
  end

  # Test Gaggle::Channels::MessagesController#create
  test "should create message in channel and trigger callbacks" do
    assert_difference "Gaggle::Message.count", 1 do
      assert_difference "Gaggle::Notification.count", 1 do # Notify goose_two (in channel_one)
        post gaggle.channel_messages_path(@channel), params: { goose_user_id: @goose.id, message: { content: "Hi @goose_two" } }
      end
    end

    turbo_streams = capture_turbo_stream_broadcasts @channel
    assert_equal 1, turbo_streams.length
    assert_equal "prepend", turbo_streams.first["action"]
    assert_equal "messages", turbo_streams.first["target"]

    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "h1", @channel.name # Assuming show page has channel name

    # Verify message
    message = Gaggle::Message.last
    assert_equal "Hi @goose_two", message.content
    assert_equal @channel, message.messageable
    assert_equal @goose, message.goose

    # Verify notifications callback
    notification = Gaggle::Notification.last
    assert_equal message, notification.message
    assert_equal @goose_two, notification.goose
    assert_equal @channel, notification.messageable
    assert_not_nil notification.delivered_at # From notify_goose

    # Verify associate_goose callback (no change since goose_one is already in channel_one)
    assert_includes @goose.channels, @channel

    # broadcast_create is harder to test in integration; consider unit test for Turbo Streams
  end

  test "should not create message without content" do
    assert_no_difference "Gaggle::Message.count" do
      assert_no_difference "Gaggle::Notification.count" do
        post gaggle.channel_messages_path(@channel), params: { message: { content: "" } }
      end
    end

    assert_response :success # Renders new template
  end

  # Test Gaggle::MessagesController#destroy (current behavior)
  test "should render destroy message text without deleting" do
    delete gaggle.message_path(@message)
    assert_response :success
    assert_equal "Message destroyed: #{@message.id}", response.body
    assert Gaggle::Message.exists?(@message.id) # Not actually destroyed
    assert_equal 2, Gaggle::Message.count
  end
end
