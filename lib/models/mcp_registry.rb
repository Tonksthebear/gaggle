class McpToolRegistry
  class << self
    # Store tools in a class-level array
    def tools
      @tools ||= generate_mcp_routes
    end

    # Clear tools (useful for development reloading)
    def reset!
      @tools = nil
    end

    def find_by_tool_name(tool_name)
      tools.find { |tool| tool[:tool_name] == tool_name }
    end

    private

    def generate_mcp_routes
      def mounted_engines
        Rails::Engine.subclasses.select { |engine| engine.routes? }
      end

      all_routes = []
      all_routes += Rails.application.routes.routes.to_a

      mounted_engines.each do |engine|
        engine_routes = engine.routes.routes.to_a
        all_routes += engine_routes
      end

      filtered_routes = all_routes.select do |route|
        mcp = route.defaults[:mcp]
        if mcp == true
          true
        elsif mcp.is_a?(Array) && route.defaults[:action]
          route.defaults[:action].to_s.in?(mcp.map(&:to_s))
        else
          false
        end
      end

      filtered_routes.map do |route|
        next unless route.defaults[:controller] && route.defaults[:action]
        next unless route.defaults[:action].to_s.in?(%w[create index show update destroy])
        next if route.verb.downcase == "put"

        begin
          controller_class = "#{route.defaults[:controller].camelize}Controller".constantize
          action = route.defaults[:action].to_sym
          params_def = controller_class.permitted_params(action)
          mcp_hash = controller_class.mcp_hash(action)
        rescue NameError
          next
        end

        # Extract required URL parameters (e.g., :channel_id from the path)
        url_params = required_url_params(route)
        required_body_params = params_def.select { |p| p[:required] }
        required_parameters = (url_params + required_body_params).uniq

        {
          name: route.defaults[:controller],
          tool_name: "#{action}_#{route.defaults[:controller].parameterize}",
          action: action,
          method: route.verb.downcase,
          description: "Handles #{action} for #{route.defaults[:controller]}",
          mcp_hash: (mcp_hash || {}).merge(required_url_mcp_hash(route)),
          required_parameters: required_parameters,
          accepted_parameters: params_def.map do |param|
            {
              name: param[:name],
              type: param[:type] || "string",
              example: param[:example],
              required: param[:required],
              nested: param[:nested]&.map { |n| { name: n[:name], type: n[:type], required: n[:required] } }
            }.compact
          end
        }
      end.compact
    end

    def required_url_params(route)
      (route.path.ast.names - [ "format" ]).map do |name|
        {
          name: name,
          type: "string",
          required: true
        }
      end
    end

    def required_url_mcp_hash(route)
      mcp_hash = {}
      (route.path.ast.names - [ "format" ]).each do |name|
        mcp_hash[name] = {
          type: "string",
          required: true
        }
      end
      mcp_hash
    end

    def tool_properties(tool, properties = {})
      parameters = Array.wrap(tool.dig(:required_parameters))
      parameters += Array.wrap(tool.dig(:accepted_parameters))
      parameters.uniq { |p| p[:name] }.each do |param|
        properties[param[:name]] = {
          type: param[:type],
          required: param[:required]
        }

        Array.wrap(param[:nested]).each do |nested_param|
          properties[param[:name]][:properties] ||= {}
          properties[param[:name]][:properties][nested_param[:name]] = tool_properties(nested_param)
        end
      end
      properties
    end
  end
end
