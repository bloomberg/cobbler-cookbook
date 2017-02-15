#
# Cookbook Name:: cobblerd
# Library:: profile
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
begin
  require 'poise'
rescue LoadError
end

class Chef
  class Resource::CobblerProfile < Resource
    include Poise
    include Cobbler::Parse

    actions(:import)
    actions(:delete)

    attribute(:name, kind_of: String)
    attribute(:distro, kind_of: String, required: true)
    attribute(:kickstart, kind_of: String, default: lazy { source_default })
    attribute(:kickstart_meta, kind_of: Hash, default: {})
    attribute(:kernel_options, kind_of: Hash, default: { 'interface' => 'auto' })
    attribute(:kernel_options_postinstall, kind_of: Hash, default: {} )

    private
    def source_default
      return lazy {
        if ['ubuntu', 'debian'].include?(breed)
          "#{name}.preseed"
        elsif breed == 'redhat'
          "#{name}.ks"
        elsif breed == 'suse'
          "#{name}.xml"
        else
          Chef::Application.fatal!("Unsupported breed (#{breed})!")
        end
      }
    end

    private
    def breed
      # return breed (e.g. "redhat", "debian", "ubuntu" or "suse")
      @breed ||= cobbler_distro(distro, "Breed")
    end
  end

  class Provider::CobblerProfile < Provider
    include Poise
    provides(:cobbler_profile) if respond_to?(:provides)

    def action_delete
      converge_by("deleting #{new_resource.name} into cobbler") do
          cobbler_profile_delete
      end
    end

    def action_import
      converge_by("importing #{new_resource.name} into cobbler") do
          cobbler_profile_add
      end
    end

    private

    def cobbler_profile_add
      template "/var/lib/cobbler/kickstarts/#{new_resource.name}" do
        source "#{new_resource.kickstart}.erb"
        action :create
      end

      bash "#{new_resource.name}-cobbler-profile-add" do
        code (<<-CODE)
          cobbler profile add --name='#{new_resource.name}' \
          --clobber \
          --distro='#{new_resource.distro}' \
          --kickstart='/var/lib/cobbler/kickstarts/#{new_resource.name}' \
          #{"--kopts='#{new_resource.kernel_options.map{ |k,v| "#{k}=#{v}" }.join(" ")}'" if new_resource.kernel_options.length > 0} \
          #{"--kopts-post='#{new_resource.kernel_options_postinstall.map{ |k,v| "#{k}=#{v}" }.join(" ")}'" if new_resource.kernel_options_postinstall.length > 0} \
          #{"--ksmeta='#{new_resource.kernel_options_postinstall.map{ |k,v| "#{k}=#{v}" }.join(" ")}'" if new_resource.kernel_options_postinstall.length > 0 } 
        CODE
        umask 0002
        notifies :run, 'bash[cobbler-sync]', :delayed
        not_if "cobbler profile find --name='#{new_resource.name}' --distro='#{new_resource.distro}'|grep -q '^#{new_resource.name}$'"
      end

      bash "#{new_resource.name}-verify cobbler-profile-add" do
        code "cobbler profile find --name='#{new_resource.name}' --distro='#{new_resource.distro}'|grep -q '^#{new_resource.name}$'"
      end

    end

    def cobbler_profile_delete
      bash "#{new_resource.name}-cobbler-profile-delete" do
        code "cobbler profile remove --name='#{new_resource.name}'"
        notifies :run, 'bash[cobbler-sync]', :delayed
        only_if "cobbler profile find --name='#{new_resource.name}' --distro='#{new_resource.distro}'|grep -q '^#{new_resource.name}$'"
      end

      file "/var/lib/cobbler/kickstarts/#{new_resource.name}" do
        action :delete
        only_if { ::File.exist? "/var/lib/cobbler/kickstarts/#{new_resource.name}" }
      end

      bash "#{new_resource.name}-verify cobbler-profile-delete" do
        code "cobbler profile find --name='#{new_resource.name}' --distro='#{new_resource.distro}'|grep -q '^#{new_resource.name}$'"
        returns [1]
      end
    end

  end
end
