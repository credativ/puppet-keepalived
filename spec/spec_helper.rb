require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

shared_context "hieradata" do
  let(:hiera_config) do
    { :backends => ['yaml'],
      :hierarchy => [
        'common',
        'keepalived',
        '%{fqdn}/%{calling_module}',
        '%{calling_module}'],
      :yaml => {
        :datadir => File.expand_path(File.join(fixture_path, 'hieradata')) },
    }
  end
end

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
