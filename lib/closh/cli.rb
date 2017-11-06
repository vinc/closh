require "active_support/core_ext/object/blank"
require "active_support/hash_with_indifferent_access"
require "erb"
require "trollop"
require "yaml"

module CloudShell
  module CLI
    def self.run
      opts = parse_opts(ARGV)

      config = load_config(File.expand_path(opts[:config]))

      shell = CloudShell::Session.new(config, opts)

      if opts[:list]
        shell.list_servers
        exit
      end

      if opts[:resume]
        shell.find_server(opts[:resume])
      else
        key_path = File.expand_path(opts[:key])
        key_body = File.read(key_path)
        shell.upload_ssh_key(key_body)

        shell.create_server
      end

      begin
        command = ARGV.join(" ").presence || "$SHELL"
        shell.exec(command) do |channel|
          unless STDIN.tty?
            channel.send_data(STDIN.read)
            channel.eof!
          end
        end
      ensure
        shell.destroy_server if opts[:kill]
      end
    end

    def self.load_config(path)
      YAML.safe_load(ERB.new(File.read(path)).result).deep_symbolize_keys
    end

    private

    def self.parse_opts(args)
      Trollop::options(ARGV) do
        version "Cloud Shell v#{CloudShell::VERSION}"
        usage "<command>"
        opt :dry_run, "Create fake server and run locally", short: "n"
        opt :config,  "Config file", type: :string, default: "~/.closh.yaml"
        opt :key,     "SSH public key", type: :string, default: "~/.ssh/id_rsa.pub"
        opt :resume,  "Resume session", type: :string
        opt :kill,    "Kill session at the end", short: "x"
        opt :list,    "List sessions"
        opt :verbose, "Use verbose mode"
        opt :help,    "Show this message"
        opt :version, "Print version and exit", short: "V"
      end
    end
  end
end
