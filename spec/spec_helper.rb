require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require 'coveralls'

Coveralls.wear!

RSpec.configure do |config|
  config.color = true
  config.alias_example_group_to :describe_recipe, type: :recipe
  config.formatter = :documentation
  config.log_level = :error

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  Kernel.srand config.seed
  config.order = :random

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end

at_exit { ChefSpec::Coverage.report! }

# Cannot be part of the shared_context, otherwise Rspec throws the error
#   `platforms` is not available on an example group (e.g. a `describe` or `context` block). It is only
#   available from within individual examples (e.g. `it` blocks) or from constructs that run in the scope
#   of an example (e.g. `before`, `let`, etc).
def platforms
  {
    'centos' => {
      # CentOS versions don't 100% match those from Oracle Linux
      'versions' => ['6.8', '7.2.1511']
    },
    'oracle' => {
      'versions' => ['6.8', '7.2']
    }
  }
end

RSpec.shared_context 'recipe variables', type: :recipe do
  let(:os_versions) do
    %w(6.9 7.3.1611)
  end

  def kernel(vers)
    "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/vmlinuz"
  end

  def initrd(vers)
    "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/initrd.img"
  end

  let(:boot_file_hash) do
    [{'$img_path/': "/var/www/cobbler/images/centos-netinstall/install.img"}]
  end

  let(:arch) do
    'x86_64'
  end
  let(:breed) do
    'redhat'
  end

  let(:os_vers) do
    'rhel7'
  end

  let(:boot_files) do
    ret = Array.new
    boot_file_hash.each do |ent|
      ent.each_pair do |k,v|
        ret << "'#{k}'='#{v}'"
      end
    end
    ret
  end
end
