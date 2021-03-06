#
# Cookbook Name:: chef_stack
# Resource:: automate
#
# Copyright 2016 Chef Software Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name 'chef_automate'
default_action :create

property :fqdn, String, name_property: true
property :channel, Symbol, default: :stable
property :version, [String, Symbol], default: :latest
property :config, String, required: true
property :accept_license, [TrueClass, FalseClass], default: false
property :enterprise, [String, Array], default: 'chef'
property :license, String
property :chef_user, String, default: 'workflow'
property :chef_user_pem, String, required: true
property :validation_pem, String, required: true
property :builder_pem, String, required: true
property :platform, String
property :platform_version, String

load_current_value do
  # node.run_state['chef-users'] ||= Mixlib::ShellOut.new('chef-server-ctl user-list').run_command.stdout
  # node.run_state['chef-orgs'] ||= Mixlib::ShellOut.new('chef-server-ctl org-list').run_command.stdout
  # current_value_does_not_exist! unless node.run_state['chef-orgs'].index(/^#{org}$/)
end

action :create do
  required_config = <<-EOF
    delivery['chef_username'] = '#{new_resource.chef_user}'
    delivery['chef_private_key'] = '/etc/delivery/#{new_resource.chef_user}.pem'
    delivery['default_search'] = 'tags:delivery-build-node'
  EOF

  chef_ingredient 'automate' do
    action :upgrade
    channel new_resource.channel
    version new_resource.version
    config ensurekv(new_resource.config.dup.concat(required_config), delivery_fqdn: new_resource.fqdn)
    accept_license new_resource.accept_license
    platform new_resource.platform if new_resource.platform
    platform_version new_resource.platform_version if new_resource.platform_version
  end

  directory '/etc/delivery'
  directory '/etc/chef'

  directory '/var/opt/delivery/license/' do
    recursive true
  end

  {
    '/var/opt/delivery/license/delivery.license' => new_resource.license,
    "/etc/delivery/#{new_resource.chef_user}.pem" => new_resource.chef_user_pem,
    '/etc/chef/validation.pem' => new_resource.validation_pem,
    '/etc/delivery/builder_key' => new_resource.builder_pem,
  }.each do |file, src|
    chef_file file do
      source src
      user 'root'
      group 'root'
      mode '0600'
    end
  end

  file '/etc/delivery/builder_key.pub' do
    content lazy { "ssh-rsa #{[OpenSSL::PKey::RSA.new(::File.read('/etc/delivery/builder_key')).to_blob].pack('m0')}" }
    user 'root'
    group 'root'
    mode '0644'
  end

  directory '/var/opt/delivery/nginx/etc/addon.d/' do
    recursive true
  end

  file '/var/opt/delivery/nginx/etc/addon.d/99-installer_internal.conf' do
    content <<-EOF
      location /installer {
        alias /opt/delivery/embedded/service/omnibus-ctl/installer;
      }
      EOF
  end

  ingredient_config 'automate' do
    notifies :reconfigure, 'chef_ingredient[automate]', :immediately
  end

  Array(enterprise).each do |ent|
    execute "create enterprise #{ent}" do
      command "delivery-ctl create-enterprise #{ent} --ssh-pub-key-file=/etc/delivery/builder_key.pub >> /etc/delivery/#{ent}.creds"
      not_if "delivery-ctl list-enterprises --ssh-pub-key-file=/etc/delivery/builder_key.pub | grep -w #{ent}"
      only_if 'delivery-ctl status'
    end
  end
end
