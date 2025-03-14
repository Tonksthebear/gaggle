require "test_helper"

class GooseGooseTest < ActionDispatch::IntegrationTest
  include MCP::Rails::TestHelper

  setup do
    @server = mcp_server(name: "gaggle")
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
    ENV["GOOSE_USER_ID"] = @goose_one.id.to_s
  end

  test "can view list of geese" do
    mcp_tool_call(@server, "index_gaggle_gooses")
    assert response.body.include?(@goose_two.name)
    assert_not response.body.include?(@goose_one.name)
  end
end
