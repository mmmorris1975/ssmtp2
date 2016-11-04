default['ssmtp']['conf_dir'] = '/etc/ssmtp'
default['ssmtp']['debug'] = false

default['ssmtp']['mailhub']['host'] = 'localhost'
default['ssmtp']['mailhub']['port'] = 25

default['ssmtp']['hostname'] = node['fqdn']
default['ssmtp']['rewrite_domain'] = node['domain']
default['ssmtp']['from_line_override'] = true
default['ssmtp']['root'] = ''

# If false, don't put credentials in conf file, or attempt to look them up
default['ssmtp']['auth']['enabled']  = true

# Values from data bag will be preferred over attr overrides for these auth attributes
default['ssmtp']['auth']['username'] = ''
default['ssmtp']['auth']['password'] = ''
default['ssmtp']['auth']['method'] = ''

default['ssmtp']['tls']['tls_ca_file']  = '' # platform_family defaults will be used, unless this attr has a value
default['ssmtp']['tls']['tls_ca_dir']   = ''

# Values from data bag will be preferred over attr overrides for these tls attributes
default['ssmtp']['tls']['use_tls'] = false
default['ssmtp']['tls']['use_starttls']  = false
default['ssmtp']['tls']['tls_auth_cert'] = ''
default['ssmtp']['tls']['tls_auth_key']  = ''

# If empty, use attrs only (user assumes all risk for plain-text credentials)
default['ssmtp']['data_bag']['name'] = 'mail'
default['ssmtp']['data_bag']['item'] = 'ssmtp'

# Always check encrypted databag, unless (this.attr).chomp.strip.downcase.eql? 'plain'
default['ssmtp']['data_bag']['format'] = 'encrypted'

# A hash like: {'user1': 'alias1', 'user2': 'alias2'}, used for building revaliases file
default['ssmtp']['aliases'] = {}

# Requested as part of issue #1
default['ssmtp']['ssmtp_conf']['owner'] = 'root'
default['ssmtp']['ssmtp_conf']['group'] = 'mail'
default['ssmtp']['ssmtp_conf']['mode']  = '2640'
default['ssmtp']['revaliases']['owner'] = 'root'
default['ssmtp']['revaliases']['group'] = 'root'
default['ssmtp']['revaliases']['mode']  = '0644'
