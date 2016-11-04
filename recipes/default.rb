#
# Cookbook Name:: ssmtp2
# Recipe:: default
#
# Copyright 2014, Mike Morris
#

# ssmtp is in the epel yum repo on rhel-ish platforms
if platform_family? 'rhel'
  node.set['yum']['epel']['enabled'] = true
  include_recipe 'yum-epel'
end

# Force package metadata refresh on debian-type platforms
execute 'apt-get update' do
  only_if { platform_family?('debian') }
end

package 'ssmtp' do
  action :upgrade
end

# get data bag config items
mail_host = node['ssmtp']['mailhub']['host']
data_bag  = node['ssmtp']['data_bag']['name']

unless data_bag.nil? || data_bag.strip.empty?
  db_fmt  = node['ssmtp']['data_bag']['format']
  db_item = node['ssmtp']['data_bag']['item']

  bag = if db_fmt.nil? || db_fmt.chomp.strip.casecmp('plain').nonzero?
          Chef::EncryptedDataBagItem.load(data_bag, db_item)
        else
          Chef::DataBagItem.load(data_bag, db_item)
        end

  mail_cfg = bag[mail_host]
  unless mail_cfg.nil?
    node.set['ssmtp']['mailhub']['port'] = mail_cfg['port'] if mail_cfg.key?('port')

    node.set['ssmtp']['auth']['username'] = mail_cfg['username'] if mail_cfg.key?('username')
    node.set['ssmtp']['auth']['password'] = mail_cfg['password'] if mail_cfg.key?('password')
    node.set['ssmtp']['auth']['method']   = mail_cfg['auth_method'] if mail_cfg.key?('auth_method')

    node.set['ssmtp']['tls']['use_tls'] = mail_cfg['use_tls'] if mail_cfg.key?('use_tls')
    node.set['ssmtp']['tls']['use_starttls']  = mail_cfg['use_starttls']  if mail_cfg.key?('use_starttls')
    node.set['ssmtp']['tls']['tls_auth_cert'] = mail_cfg['tls_auth_cert'] if mail_cfg.key?('tls_auth_cert')
    node.set['ssmtp']['tls']['tls_auth_key']  = mail_cfg['tls_auth_key']  if mail_cfg.key?('tls_auth_key')
  end
end

mailhub = "#{mail_host}:#{node['ssmtp']['mailhub']['port']}"

username = node['ssmtp']['auth']['username']
password = node['ssmtp']['auth']['password']
auth_method = node['ssmtp']['auth']['method']

use_tls = node['ssmtp']['tls']['use_tls']
use_starttls = node['ssmtp']['tls']['use_starttls']
tls_cert = node['ssmtp']['tls']['tls_auth_cert']
tls_key  = node['ssmtp']['tls']['tls_auth_key']
ca_crt_file = node['ssmtp']['tls']['tls_ca_file']

unless node['ssmtp']['auth']['enabled']
  username = ''
  password = ''
  auth_method = ''
end

if ca_crt_file.nil? || ca_crt_file.strip.empty?
  ['/etc/pki/tls/certs/ca-bundle.crt', '/etc/ssl/certs/ca-bundle.crt', '/etc/ssl/certs/ca-certificates.crt'].each do |f|
    # Fixed for rubocop
    next unless ::File.exist?(f)

    ca_crt_file = f
    break
  end
end

template "#{node['ssmtp']['conf_dir']}/revaliases" do
  source 'revaliases.erb'
  owner node['ssmtp']['revaliases']['owner']
  group node['ssmtp']['revaliases']['group']
  mode node['ssmtp']['revaliases']['mode']
  variables(
    aliases: node['ssmtp']['aliases'],
    mailhub: mailhub
  )
end

template "#{node['ssmtp']['conf_dir']}/ssmtp.conf" do
  source 'ssmtp.conf.erb'
  owner node['ssmtp']['ssmtp_conf']['owner']
  group node['ssmtp']['ssmtp_conf']['group']
  mode node['ssmtp']['ssmtp_conf']['mode']
  variables(
    debug: node['ssmtp']['debug'],
    root:  node['ssmtp']['root'],
    mailhub: mailhub,
    rewrite_domain: node['ssmtp']['rewrite_domain'],
    hostname: node['ssmtp']['hostname'],
    from_override: node['ssmtp']['from_line_override'],
    use_tls: use_tls,
    use_starttls: use_starttls,
    tls_ca_file:  ca_crt_file,
    tls_ca_dir:   node['ssmtp']['tls']['tls_ca_dir'],
    tls_cert: tls_cert,
    tls_key:  tls_key,
    username: username,
    password: password,
    auth_method: auth_method
  )
end
