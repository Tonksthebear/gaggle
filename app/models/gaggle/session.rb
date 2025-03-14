require "pty"

module Gaggle
  class Session < ApplicationRecord
    class << self; attr_reader :running_executables; end
    @running_executables = {}

    SUBMISSION_SIGNAL = "\r\n".freeze

    belongs_to :goose
    attribute :log_file, :string, default: ""

    scope :running, -> { all.select(&:running?) }

    def start_executable
      prepare_logging
      logger = Logger.new(log_path)
      Rails.logger.info "Starting goose session for: #{goose.name}"

      self.class.running_executables[to_global_id] = Thread.new(logger) do |session_logger|
        Thread.current.name = "gaggle-session-#{to_global_id}"
        Thread.current[:input_queue] = input_queue = Queue.new
        prompt_mutex = Mutex.new
        prompt_cond = ConditionVariable.new
        prompt_active = false
        server_name = MCP::Rails.configuration.for_engine(Gaggle::Engine).server_name
        server_path = MCP::Rails.configuration.output_directory.join(server_name)


        Thread.current[:logger] = session_logger

        PTY.spawn("goose session --with-extension \"GOOSE_USER_ID=#{goose.id} #{server_path}_server.rb\"") do |stdout, stdin, pid|
          session_logger.info "Spawned PID: #{pid}"
          stdout.sync = true
          stdin.sync = true

          input_thread = Thread.new(input_queue, stdin, prompt_mutex, prompt_cond, name: "input-#{to_global_id}") do |queue, input_stream, mutex, cond|
            loop do
              mutex.synchronize do
                cond.wait(mutex)
                next if queue.empty?
                begin
                  command = queue.pop
                  cmd_to_send = command.is_a?(String) ? "#{command}#{SUBMISSION_SIGNAL}" : command&.to_s || SUBMISSION_SIGNAL
                  session_logger.info "Sent command: #{command.inspect}"
                  input_stream.write(cmd_to_send)
                  input_stream.flush
                  prompt_active = false  # Reset after sending
                rescue StandardError => e
                  session_logger.error "Input thread error: #{e.class} - #{e.message}"
                end
              end
            end
          end

          begin
            loop do
              ready = IO.select([ stdout ], nil, nil, 2)
              if ready
                line = nil
                begin
                  Timeout.timeout(1) { line = stdout.gets }
                rescue Timeout::Error
                  alive = Process.waitpid(pid, Process::WNOHANG).nil?
                  break unless alive
                  next
                end
                if line
                  prompt_active = false
                  session_logger.info "Output: #{line.chomp}"
                  broadcast_output(line)
                else
                  break
                end
              else
                prompt_mutex.synchronize do
                  unless prompt_active || input_queue.empty?
                    prompt_active = true
                    prompt_cond.signal
                  end
                end
              end
            end
          rescue Errno::EIO, Errno::EPIPE, IOError => e
            session_logger.error "Stream error: #{e.class} - #{e.message}"
          rescue StandardError => e
            session_logger.error "Unexpected error: #{e.class} - #{e.message}"
          ensure
            stdout.close unless stdout.closed?
            stdin.close unless stdin.closed?
            input_thread.kill
            self.class.running_executables.delete(to_global_id)
            session_logger.info "Session thread exiting, PID: #{pid rescue 'unknown'}"
          end
        end
      end
    end

    def write_to_executable(input)
      if (thread = executable)
        thread[:logger].info "Received input: #{input.inspect}"
        broadcast_output(input)
        thread[:input_queue].push(input)
      else
        Rails.logger.error "No running session found for: #{to_global_id}"
      end
    end

    def stop_executable
      executable&.exit if running?
    end

    def running?
      executable&.alive?
    end

    private

    def prepare_logging
      self.log_file = "log/gaggle/goose_#{goose.id}/#{Time.now.iso8601}.log"
      FileUtils.mkdir_p(File.dirname(log_path))
      FileUtils.touch(log_path)
      save!
    end

    def log_path
      Rails.root.join(log_file)
    end

    def broadcast_output(content)
      broadcast_append target: dom_id(self, :code), content: Strings::ANSI.sanitize(content)
    end

    def executable
      self.class.running_executables[to_global_id]
    end
  end
end
