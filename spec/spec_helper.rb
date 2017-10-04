require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require_relative 'platforms'
# require 'coveralls'

# Coveralls.wear!

RSpec.configure do |config|
  config.color = true
  config.alias_example_group_to :describe_recipe, type: :recipe
  config.formatter = :documentation
  config.log_level = :error

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  Kernel.srand config.seed
  config.order = :random

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end

# Include all our own libraries.
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

# Run the ChefSpec coverage report when the tests are finished.
at_exit { ChefSpec::Coverage.report! }

# Common variables to be used by multiple recipes.
RSpec.shared_context 'recipe variables', type: :recipe do
  let(:os_versions) do
    %w[6.9 7.4.1708]
  end

  def kernel(vers)
    "/var/www/cobbler/images/centos-#{vers}/isolinux/vmlinuz"
  end

  def initrd(vers)
    "/var/www/cobbler/images/centos-#{vers}/isolinux/initrd.img"
  end

  let(:boot_file_hash) do
    [{ '$img_path/': "/var/www/cobbler/images/centos-netinstall/install.img" }]
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
    ret = []
    boot_file_hash.each do |ent|
      ent.each_pair do |k, v|
        ret << "'#{k}'='#{v}'"
      end
    end
    ret
  end
end
