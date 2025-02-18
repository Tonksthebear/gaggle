module Gaggle
  class Session < ApplicationRecord
    @@running_executables = {}
    belongs_to :goose

    attribute :log_file, :string, default: ""

    scope :running, -> { all.select { |session| session.running? } }

    def start_executable
      @@running_executables[to_global_id] = ::Thread.new do
        Rails.logger.info "Starting executable for: #{goose.name}"
        Open3.popen3({ "GOOSE_ID" => goose.id.to_s }, "goose session") do |stdin, stdout, stderr, wait_thr|
          ::Thread.current[:stdin] = stdin
          @stdout = stdout
          @stderr = stderr
          @pid = wait_thr.pid

          self.log_file = "log/gaggle/goose_#{goose.id}/#{Time.now.iso8601}.log"
          log_file_path = Rails.root.join(self.log_file)
          FileUtils.mkdir_p(File.dirname(log_file_path))
          FileUtils.touch(log_file_path)
          session_logger = Logger.new(log_file_path)
          session_logger.info "Session started"
          save!

          begin
            while (line = @stdout.gets)
              session_logger.info line
              broadcast_append target: dom_id(self, :code), content: line
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
