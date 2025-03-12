require "test_helper"

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @channel = gaggle_channels(:channel_one)
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
  end

  test "should show channel" do
    with_engine_routes do
      get gaggle.channel_path(@channel)
      assert_response :success
      assert_select "h1", @channel.name
    end
  end

  test "should get new" do
    get gaggle.new_channel_path
    assert_response :success
    assert_select "form"
  end

  test "should create channel" do
    post gaggle.channels_path, params: { channel: { name: "New Channel", goose_ids: [ @goose_two.id ] } }
    assert_response :redirect
    follow_redirect!
    assert_select "h1", "New Channel"
    # Verify the channel was created with the correct associations
    new_channel = Gaggle::Channel.last
    assert_equal "New Channel", new_channel.name
    assert_includes new_channel.gooses, @goose_two
    assert_equal 3, Gaggle::Channel.count
  end

  test "should not create channel without name" do
    post gaggle.channels_path, params: { channel: { goose_ids: [ @goose_two.id.to_s ] } }
    assert_response :success # Renders new template
    assert_select "div#error_explanation" # Check for error messages
    assert_equal 2, Gaggle::Channel.count # No new channel created
  end

  test "should get edit" do
    get gaggle.edit_channel_path(@channel)
    assert_response :success
    assert_select "form"
  end

  test "should update channel" do
    put gaggle.channel_path(@channel), params: { channel: { name: "Updated Name" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "h1", "Updated Name"
    # Verify the channel was updated
    @channel.reload
    assert_equal "Updated Name", @channel.name
  end

  test "should not update channel with invalid data" do
    put gaggle.channel_path(@channel), params: { channel: { name: "" } }
    assert_response :success # Renders edit template
    assert_select "div#error_explanation"
    # Verify the channel was not updated
    @channel.reload
    assert_not_equal "", @channel.name
  end

  test "should destroy channel" do
    assert_difference "Gaggle::Channel.count", -1 do
      delete gaggle.channel_path(@channel)
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal gaggle.root_path, path # Redirects to root_url
  end
end
