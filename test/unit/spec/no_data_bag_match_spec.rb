require_relative 'spec_helper'

platforms = [
  { 'centos' => '6.5' },
  { 'centos' => '7.0' },
  { 'redhat' => '6.5' },
  { 'redhat' => '7.0' },
  { 'fedora' => '19' },
  { 'fedora' => '20' },
  { 'fedora' => '21' },
  { 'ubuntu' => '12.04' },
  { 'ubuntu' => '13.10' },
  { 'ubuntu' => '14.04' },
  { 'debian' => '7.4' },
  { 'debian' => '8.0' }
]

platforms.each do |i|
  i.each_pair do |p, v|
    describe 'ssmtp2::default' do
      let :chef_run do
        ChefSpec::SoloRunner.new(platform: p, version: v, log_level: :error) do |node|
          Chef::Log.debug(format('#### FILE: %s  PLATFORM: %s  VERSION: %s ####', ::File.basename(__FILE__), p, v))

          env = Chef::Environment.new
          env.name 'testing'
          # Stub the node to return this environment
          node.stub(:chef_environment).and_return env.name

          node.set['ec2']['local_ipv4'] = '55.55.55.55'

          # set attributes here
          node.set['ssmtp']['mailhub']['host'] = 'mail.google.com'
          node.set['ssmtp']['rewrite_domain']  = 'mydomain.com'
          node.set['ssmtp']['aliases'] = { root: 'no-reply@mydomain.com', user1: 'no-reply@mydomain.com' }
          node.set['ssmtp']['data_bag']['format'] = 'plain'
          # Force value to correctly run on MacOS
          node.set['ssmtp']['tls']['tls_ca_file'] = '/etc/ssl/certs/ca-bundle.crt'

          Chef::Config[:solo] = true
          Chef::Config[:data_bag_path] = File.join(File.dirname(__FILE__), '/data_bags')

          default_data_bag_secret = ::File.join(ENV['CHEF_HOME'] || ENV['HOME'], '.chef', 'encrypted_data_bag_secret')
          Chef::Config[:encrypted_data_bag_secret] = ENV['ENCRYPTED_DATA_BAG_SECRET'] || default_data_bag_secret

          # Stub any calls to Environment.load to return this environment
          Chef::Environment.stub(:load).and_return env
        end.converge described_recipe
      end

      it 'checks for handling the epel yum repo' do
        if chef_run.node.platform_family?('rhel')
          expect(chef_run).to include_recipe 'yum-epel'
        else
          expect(chef_run).to_not include_recipe 'yum-epel'
        end
      end

      it 'installs the ssmtp package' do
        expect(chef_run).to upgrade_package 'ssmtp'
      end

      it 'installs the ssmtp.conf file' do
        mail_host = chef_run.node['ssmtp']['mailhub']['host']

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
        expect(chef_run).to render_file(file).with_content(%r{^TLS_CA_File=/etc/.*/certs/.*\.crt$})
        expect(chef_run).to render_file(file).with_content(/^Hostname=.*/)

        expect(chef_run).to_not render_file(file).with_content(/^UseTLS=YES$/)
        expect(chef_run).to_not render_file(file).with_content(/^AuthUser=my_user$/)
        expect(chef_run).to_not render_file(file).with_content(/^AuthPass=my_pass$/)
      end

      it 'installs the revaliases file' do
        file = '/etc/ssmtp/revaliases'
        mail_host = chef_run.node['ssmtp']['mailhub']['host']

        expect(chef_run).to create_template(file)
          .with(
            user:  'root',
            group: 'root',
            mode:  '0644'
          )

        unless chef_run.node['ssmtp']['aliases'].empty?
          chef_run.node['ssmtp']['aliases'].each_pair do |key, val|
            expect(chef_run).to render_file(file).with_content("#{key}:#{val}:#{mail_host}:25")
          end
        end
      end
    end
  end
end
