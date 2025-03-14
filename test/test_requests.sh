#!/bin/bash
GOOSE_USER_ID=1

{
# Initialize request
echo '{"jsonrpc": "2.0", "method": "initialize", "params": {"protocolVersion": "2024-11-05"}, "id": 1}'

# Initialized notification
echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'

# List tools request
echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 2}'

# Call index channels
echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "index_gaggle_channels", "arguments": {}}, "id": 3}'

# # Call view channel
# echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "show_gaggle_channels", "arguments": {"id": "24"}}, "id": 3}'

# Call create channel
# echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "create_gaggle_channels", "arguments": {"channel": {"name": "New Channel", "goose_ids": ["1"]}}}, "id": 3}'

# Send message in channel
# echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "create_gaggle_channels_messages", "arguments": {"message": {"content": "Hello"}, "channel_id": "24"}}, "id": 3}'

# Call destroy channel
# echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "destroy_gaggle_channels", "arguments": {"id": "37"}}, "id": 3}'
} | ./test/dummy/tmp/mcp/gaggle_server.rb