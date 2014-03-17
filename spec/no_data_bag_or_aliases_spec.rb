require 'spec_helper'

platforms = [
  { 'centos' => '6.3' },
  { 'centos' => '6.4' },
  { 'centos' => '6.5' },
  { 'redhat' => '6.3' },
  { 'redhat' => '6.4' },
  { 'redhat' => '6.5' },
  { 'fedora' => '18' },
  { 'fedora' => '19' },
  { 'fedora' => '20' },
  { 'ubuntu' => '12.04' },
  { 'ubuntu' => '13.04' },
  { 'debian' => '7.2' },
  { 'debian' => '7.4' }
]

platforms.each { |i| i.each_pair do |p,v|
  describe 'ssmtp2::default' do
    let (:chef_run) { ChefSpec::Runner.new(platform:p, version:v, :log_level => :info) do |node|
      Chef::Log.debug(sprintf("#### FILE: %s  PLATFORM: %s  VERSION: %s ####", ::File.basename(__FILE__), p, v))

      env = Chef::Environment.new
      env.name 'testing'
      # Stub the node to return this environment
      node.stub(:chef_environment).and_return env.name

      node.set['ec2']['local_ipv4'] = "55.55.55.55"

      # set attributes here
      node.set['ssmtp']['mailhub']['host'] = "email-smtp.us-east-1.amazonaws.com"
      node.set['ssmtp']['rewrite_domain']  = "mydomain.com"
      node.set['ssmtp']['aliases'] = {}
      node.set['ssmtp']['data_bag']['name'] = ''

      Chef::Config[:solo] = true
      Chef::Config[:data_bag_path] = File.join(File.dirname(__FILE__), "/data_bags")

      default_data_bag_secret = ::File.join(ENV['CHEF_HOME'] || ENV['HOME'], '.chef', 'encrypted_data_bag_secret')
      Chef::Config[:encrypted_data_bag_secret] = ENV['ENCRYPTED_DATA_BAG_SECRET'] || default_data_bag_secret

      # Stub any calls to Environment.load to return this environment
      Chef::Environment.stub(:load).and_return env
    end.converge described_recipe }

    it 'checks for handling the epel yum repo' do
      if (chef_run.node.platform_family?('rhel'))
      then
        expect(chef_run).to include_recipe "yum::epel"
      else
        expect(chef_run).to_not include_recipe "yum::epel"
      end
    end

    it 'installs the ssmtp package' do
      expect(chef_run).to upgrade_package 'ssmtp'
    end

    it 'installs the ssmtp.conf file' do
      mail_host = chef_run.node['ssmtp']['mailhub']['host']
      mail_port = chef_run.node['ssmtp']['mailhub']['port']

      file = '/etc/ssmtp/ssmtp.conf'

      expect(chef_run).to create_template(file)
        .with(
          user:  'root',
          group: 'mail',
          mode:  '2640'
        )

      expect(chef_run).to render_file(file).with_content("mailhub=#{mail_host}:25")
      expect(chef_run).to render_file(file).with_content(/^RewriteDomain=mydomain.com$/)
      expect(chef_run).to render_file(file).with_content(/^FromLineOverride=YES$/)
      expect(chef_run).to render_file(file).with_content(/^TLS_CA_File=\/etc\/.*\/certs\/.*\.crt$/)
      expect(chef_run).to render_file(file).with_content(/^Hostname=.*/)

      expect(chef_run).to_not render_file(file).with_content(/^UseTLS=YES$/)
      expect(chef_run).to_not render_file(file).with_content(/^AuthUser=.*/)
      expect(chef_run).to_not render_file(file).with_content(/^AuthPass=.*/)
    end

    it 'installs the revaliases file' do
      file = '/etc/ssmtp/revaliases'
      mail_host = chef_run.node['ssmtp']['mailhub']['host']
      mail_port = chef_run.node['ssmtp']['mailhub']['port']

      expect(chef_run).to create_template(file)
        .with(
          user:  'root',
          group: 'root',
          mode:  '0644'
        )

      expect(chef_run).to_not render_file(file).with_content(/^[^#].*:.*:.*/)
    end
  end
end }
