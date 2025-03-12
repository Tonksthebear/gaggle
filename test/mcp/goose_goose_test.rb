require "mcp_test_helper"

class GooseGooseTest < MCPTestHelper
  setup do
    @goose_one = gaggle_gooses(:goose_one)
    @goose_two = gaggle_gooses(:goose_two)
  end

  test "can view list of geese" do
    within_server(@goose_one) do |stdin, stdout|
      tool_call = call_tool("index_gaggle_gooses")
      output = write_to_mcp_server(tool_call)
      assert output.include?(@goose_two.name)
      assert_not output.include?(@goose_one.name)
    end
  end
end
