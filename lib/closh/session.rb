require "fog"
require "net/ssh"
require "rainbow"

module CloudShell
  class Session
    def initialize(config, options)
      @config = config
      @provider = config[:compute][:provider]
      @key_name = config[:compute][:key_name] || "closh"

      @options = options
      Fog.mock! if options[:dry_run]

      @compute = Fog::Compute.new(config[:compute])
    end

    def upload_ssh_key(key)
      if @compute.key_pairs.get(@key_name).nil?
        debug("uploading SSH public key to #{@provider} ...")
        @compute.import_key_pair(@key_name, key)
      end
    end

    def list_servers
      debug("listing servers on #{@provider} ...")
      @compute.servers.each do |server|
        next unless server.ready?
        puts server.public_ip_address if server.public_ip_address
      end
    end

    def find_server(address)
      debug("finding server on #{@provider} ...")
      config = @config[:server]
      @username = config[:username] || "root"
      @compute.servers.each do |server|
        return @server = server if server.public_ip_address == address
      end
      error("could not find server on #{@provider}")
      exit 1
    end

    def create_server
      debug("creating server on #{@provider} ...")
      config = @config[:server].merge({ key_name: @key_name })
      @username = config[:username] || "root"
      @server = @compute.servers.create(config)
      @server.wait_for { ready? }
    end

    def destroy_server
      debug("destroying server ...")
      @server.destroy
    end

    def exec(command, &block)
      debug("connecting to '#{@username}@#{@server.public_ip_address}' ...")
      if @options[:dry_run]
        debug("executing command '#{command}' ...")
        system(command)
      else
        Net::SSH.start(@server.public_ip_address, @username) do |ssh|
          ssh.open_channel do |channel|
            debug("executing command `#{command}` ...")
            channel.exec(command) do |_, success|
              channel.on_data do |_, data|
                print data
              end

              if block_given?
                block.call(channel)
              end
            end
          end
          ssh.loop
        end
      end
    rescue Errno::ECONNREFUSED
      n = 10
      error("connection refused, retrying in #{n} seconds")
      sleep n
      retry
    end

    private

    def debug(text)
      puts Rainbow("debug: ").cyan + text if @options[:verbose]
    end

    def error(text)
      puts Rainbow("error: ").yellow + text if @options[:verbose]
    end
  end
end
