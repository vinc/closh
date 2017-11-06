require "tempfile"

RSpec.describe CloudShell do
  before do
    # Export environment variables
    ENV["AWS_SECRET_ACCESS_KEY"] = "secret"
    ENV["AWS_ACCESS_KEY_ID"] = "secret"

    # Read YAML config
    path = File.join(File.dirname(__FILE__), "../closh.sample.yaml")
    @config = CloudShell::CLI.load_config(path)

    # Create SSH key
    key = OpenSSL::PKey::RSA.new 2048
    type = key.ssh_type
    data = [key.to_blob].pack("m0")
    body = [type, data].join(" ")
    @ssh_key = Tempfile.new("closh")
    @ssh_key.write(body)
    @ssh_key.rewind

    # CLI args
    @opts = {
      dry_run: true,
      key: @ssh_key.path
    }
  end

  after do
    @ssh_key.close
    @ssh_key.unlink
  end

  it "reads config file" do
    expect(@config[:compute][:provider]).to eq("AWS")
    expect(@config[:server][:flavor_id]).to eq("t2.micro")
  end

  it "creates server" do
    shell = CloudShell::Session.new(@config, @opts)

    key_body = @ssh_key.read
    shell.upload_ssh_key(key_body)

    nothing = ""
    address = /[0-9.]{7,15}/

    expect { shell.list_servers }.to output(nothing).to_stdout

    shell.create_server

    expect { shell.list_servers }.to output(address).to_stdout

    shell.destroy_server

    expect { shell.list_servers }.to output(nothing).to_stdout
  end
end
