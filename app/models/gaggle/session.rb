module Gaggle
  class Session < ApplicationRecord
    @@running_executables = {}
    belongs_to :goose

    attribute :output, :text, default: ""

    after_update_commit :update_output

    scope :running, -> { all.select { |session| session.running? } }

    def update_output
      broadcast_update target: dom_id(self, :code), content: output
    end

    def start_executable
      @@running_executables[to_global_id] = ::Thread.new do
        Rails.logger.info "Starting executable for: #{goose.name}"
        Open3.popen3("goose session") do |stdin, stdout, stderr, wait_thr|
          ::Thread.current[:stdin] = stdin
          @stdout = stdout
          @stderr = stderr
          @pid = wait_thr.pid

          begin
            while (line = @stdout.gets)
              output << line.gsub(/\e\[[0-9;]*m/, "")
              save
            end
          rescue IOError => e
            Rails.logger.error "Output stream closed: #{e.message}"
          end
        end
      end
    end

    def write_to_executable(input)
      if thread = @@running_executables[to_global_id]

        thread[:stdin].write(input.gsub("\n", "__NEWLINE_PLACEHOLDER__") + "\n")
      else
        Rails.logger.error "No running executable found for session #{to_global_id}"
      end
    end

    def stop_executable
      if running?
        executable.exit
      end
    end

    def running?
      executable&.alive?
    end

    def executable
      @@running_executables[to_global_id]
    end
  end
end
