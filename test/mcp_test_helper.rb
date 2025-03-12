require "test_helper"
require "action_dispatch/system_test_case"
require "capybara/minitest"
require "capybara/rails"

Capybara.server = :puma
Capybara.app = Rails.application

class MCPTestHelper < ActionDispatch::SystemTestCase
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  driven_by :rack_test

  setup do
    @server ||= Capybara::Server.new(Capybara.app).boot
    @temp_dir = Dir.mktmpdir nil, ::Rails.root.join("tmp")
    @key_path = File.join(@temp_dir, "bypass_key.txt")
    @output_dir = @temp_dir

    MCP::Rails.configure do |config|
      config.bypass_key_path = @key_path
      config.output_directory = @output_dir
      config.base_url = @server.base_url
      config.server_name = "test-server"
      config.server_version = "1.0.0"
      config.env_vars = [ "GOOSE_USER_ID" ]
    end

    @generator = MCP::Rails::ServerGenerator
    server_files = @generator.generate_files
    @gaggle_server = server_files.first
  end

  teardown do
    FileUtils.remove_entry @temp_dir
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def within_server(goose = nil, &block)
    Open3.popen3("GOOSE_USER_ID=#{goose&.id} #{@gaggle_server}") do |stdin, stdout, stderr, thread|
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @thread = thread

      @stdin.sync = true
      @stdout.sync = true
      @stdin.write(initialize_server + "\r\n")
      @stdin.write(initialize_notification + "\r\n")
      read_all_available(@stdout)

      # Check stderr for errors
      errors = read_all_available(@stderr)
      assert_empty errors, "Server produced errors: #{errors}" unless errors.empty?
      begin
        yield @stdin, @stdout
      rescue => e
        raise e.inspect
      ensure
        @stdin.close unless @stdin.closed?
        @stdout.close unless @stdout.closed?
        @stderr.close unless @stderr.closed?
        Process.kill("TERM", @thread.pid)
        @thread.join
      end
    end
  end

  def write_to_mcp_server(command)
    @stdin.write(command + "\r\n")
    read_all_available(@stdout)
  end

  def read_all_available(io, timeout = 2)
    output = ""
    while IO.select([ io ], nil, nil, timeout)
      begin
        output << io.read_nonblock(1024)
      rescue IO::EAGAINWaitReadable
        break
      rescue EOFError
        break
      end
    end
    output # Keep newlines for debugging
  end


  def initialize_server
    command = <<~JSON
    {
        "jsonrpc": "2.0",
        "method": "initialize",
        "params": {
          "protocolVersion": "1.0.0",
          "capabilities": {}
        },
        "id": 1
    }
    JSON

    command.gsub(/[\r\n]/, "").strip
  end

  def initialize_notification
    <<~JSON
      {"jsonrpc": "2.0", "method": "notifications/initialized", "id": 2}
    JSON
  end

  def call_tool(tool_name, arguments = {})
    <<~JSON
      {"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "#{tool_name}", "arguments": #{arguments.to_json}}, "id": 4}
    JSON
  end

  def list_tools
    <<~JSON
      {"jsonrpc": "2.0", "method": "tools/list", "id": 3}
    JSON
  end
end
