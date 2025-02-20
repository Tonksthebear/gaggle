require "pty"

module Gaggle
  class Session < ApplicationRecord
    @@running_executables = {}
    belongs_to :goose

    attribute :log_file, :string, default: ""

    scope :running, -> { all.select { |session| session.running? } }

    def start_executable
      self.log_file = "log/gaggle/goose_#{goose.id}/#{Time.now.iso8601}.log"
      log_file_path = Rails.root.join(self.log_file)
      FileUtils.mkdir_p(File.dirname(log_file_path))
      FileUtils.touch(log_file_path)
      logger = Logger.new(log_file_path)
      self.save
      Rails.logger.info "Starting executable for: #{goose.name}"

      @@running_executables[to_global_id] = Thread.new(logger) do |logger|
        Thread.current[:input_queue] = input_queue = Queue.new
        Thread.current[:logger] = logger

        # PTY.spawn("GOOSE_ID=#{goose_id} goose session") do |stdout, stdin, pid|
        Open3.popen3({ "GOOSE_ID" => goose.id.to_s }, "goose session") do |stdin, stdout, stderr, wait_thr|
          @pid = wait_thr.pid
          logger.info "Session started"
          save!

          output_thread = Thread.new(stdout, logger) do |stdout|
            begin
              stdout.each_line do |line|
                logger.info line
                broadcast_append target: dom_id(self, :code), content: Strings::ANSI.sanitize(line)
              end
            rescue IOError => e
              logger.error "Output stream closed: #{e.message}"
            end
          end

          input_thread = Thread.new(input_queue, logger, stdin) do |input_queue, logger, stdin|
            loop do
              command = input_queue.pop
              stdin.write command + "\n"
              stdin.flush
              logger.info "Sent command: #{command}"
            end
          end

          input_thread.join
          output_thread.join
        end
      end
    end

    def write_to_executable(input)
      if thread = @@running_executables[to_global_id]
        thread[:logger].info "Attempting to send input"
        broadcast_append target: dom_id(self, :code), content: Strings::ANSI.sanitize(input)
        thread[:input_queue].push(input.gsub("\n", "__NEWLINE_PLACEHOLDER__") + "\n")
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
