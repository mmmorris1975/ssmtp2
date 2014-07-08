ssmtp2 Cookbook
===================
A cookbook to configure the ssmtp utility. The ssmtp tool is a mail transfer agent (MTA), whose only function is to send messages from the local system to a proper mail relay.  The means that systems which previously used full-blown MTAs like sendmail/postfix/exim/etc... to send mail off to other systems, but never had a requirement to receive or process mail, can use ssmtp as a drop-in replacement; with a much simpler configuration, and likely less security concerns.  This cookbook provides access to all documented configuration variables, and will generated a revaliases file, if the attribute is set.  The data bag used by this cookbook will allow easy swapping of upstream mail host configuration by simply changing the mail host attribute. This could be handy in multi-region AWS deployments where you are using Amazon's SES service and want to swap between the SES servers in different regions, without the need to updated attributes for the entire mail server configuration.

Requirements
------------
Ruby 1.9 or later

#### cookbooks
- `yum` - to configure the epel repo on REHL-ish platforms

#### platforms
- RHEL/CentOS
- Fedora
- Ubuntu
- Debian

#### data bags
A data bag (encrypted, or not) can be used to hold mail host configuration, including sensitive authentication credentials. The data bag format uses keys which are the names of the upstream mail host, and the values are hashes of configuration information for the specific mail host.  The recipe's data bag hash key lookup logic uses the value of the ['ssmtp']['mailhub']['host'] attribute. Valid keys for the values hash are (none are required, but storing the 'username' and 'password' in an encrypted data bag is _highly_ recommended):

- **port** (the port to connect to the mail host, overrides the value of attribute ['ssmtp']['mailhub']['port'])
- **username** (the username to use to authenticate to this mail host, overrides the value of attribute ['ssmtp']['auth']['username'])
- **password** (the password to use to authenticate to this mail host, overrides the value of attribute ['ssmtp']['auth']['password'])
- **auth\_method** (the authorization method to use, only supported value is cram-md5, overrides the value of attribute ['ssmtp']['auth']['method']
- **use\_tls** (a boolean to enable TLS communication with the mail host, overrides the value of attribute ['ssmtp']['tls']['use\_tls'])
- **use\_starttls** (a boolean to determine if the STARTTLS command is sent to the mail host, overrides the value of attribute ['ssmtp']['tls']['use\_starttls'])
- **tls\_auth\_cert** (the path to the file which contains the TLS authorization certificate, if the mail host requires one; overrides the value of attribute ['ssmtp']['tls']['tls\_auth\_cert'])
- **tls\_auth\_key** (the path to the file which contains the TLS authorization key, if the mail host requires one; overrides the value of attribute ['ssmtp']['tls']['tls\_auth\_key'])

Attributes
----------

#### ssmtp2::default

*  **['ssmtp']['conf\_dir']**  
    _Type:_ String  
    _Description:_ The location of the ssmtp configuration files  
    _Default:_ /etc/ssmtp

*  **['ssmtp']['debug']**  
    _Type:_ Boolean  
    _Description:_ Enable the Debug setting in the ssmtp.conf file  
    _Default:_ false

*  **['ssmtp']['mailhub']['host']**  
    _Type:_ String  
    _Description:_ The host name of the upstream mail server  
    _Default:_ localhost

*  **['ssmtp']['mailhub']['port']**  
    _Type:_ Integer  
    _Description:_ The port number of the upstream mail server  
    _Default:_ 25

*  **['ssmtp']['hostname']**  
    _Type:_ String  
    _Description:_ The hostname of the local system  
    _Default:_ the value of the node['hostname'] attribute

*  **['ssmtp']['rewrite\_domain']**  
    _Type:_ String  
    _Description:_ The domain name to masquerade outgoing mail as  
    _Default:_ the value of the node['domain'] attribute

*  **['ssmtp']['from\_line\_override']**  
    _Type:_ Boolean  
    _Description:_ Specifies whether the From header of an email, if any, may override the default domain  
    _Default:_ true

*  **['ssmtp']['root']**  
    _Type:_ String  
    _Description:_ The user that gets all mail for userids less than 1000. If blank, address rewriting is disabled.  
    _Default:_

*  **['ssmtp']['auth']['enabled']**  
   _Type:_ Boolean  
   _Description:_ If false, do not put authentication credentials in config file (no authentication will be attempted with the mail server)  
   _Default:_ true

*  **['ssmtp']['auth']['username']**  
    _Type:_ String  
    _Description:_ The username to use for authentication with the upstream mail server  
    _Default:_

*  **['ssmtp']['auth']['password']**  
    _Type:_ String  
    _Description:_ The password to use for authentication with the upstream mail server  
    _Default:_

*  **['ssmtp']['auth']['method']**  
    _Type:_ String  
    _Description:_ The authentication method to use with the upstream mail server  
    _Default:_ no default, only supported value is cram-md5

*  **['ssmtp']['tls']['tls\_ca\_file']**  
    _Type:_ String  
    _Description:_ The location of the CA certificate bundle to validate the mail server's SSL cert  
    _Default:_ Attempt to find the file in common OS locations if no value is specified

*  **['ssmtp']['tls']['tls\_ca\_dir']**  
    _Type:_ String  
    _Description:_ The location of a directory containing trusted CA certificates to validate the mail server's SSL cert  
    _Default:_ Attempt to find the file in common OS locations if no value is specified

*  **['ssmtp']['tls']['use\_tls']**  
    _Type:_ Boolean
    _Description:_ If true, use TLS/SSL to communication with the upstream mail server  
    _Default:_ true

*  **['ssmtp']['tls']['use\_starttls']**  
    _Type:_ Boolean  
    _Description:_ If true, will send the STARTTLS command to the upstream mail server  
    _Default:_ false

*  **['ssmtp']['tls']['tls\_auth\_cert']**  
    _Type:_ String  
    _Description:_ The path to the file containing the authentication certificate for the upstream mail server, if required  
    _Default:_

*  **['ssmtp']['tls']['tls\_auth\_key']**  
    _Type:_ String  
    _Description:_ The path to the file containing the authentication key for the upstream mail server, if required  
    _Default:_

*  **['ssmtp']['data\_bag']['name']**  
    _Type:_ String  
    _Description:_  The name of the data bag that contains mail host configuration  
    _Default:_ mail

*  **['ssmtp']['data\_bag']['item']**  
    _Type:_ String  
    _Description:_ The name of the data bag item that contains the mail host configuration  
    _Default:_ ssmtp

*  **['ssmtp']['data\_bag']['format']**  
    _Type:_ String  
    _Description:_ Specifies whether or not the data bag is encrypted.  A value of 'plain' will use an unencrypted data bag  
    _Default:_ encrypted

*  **['ssmtp']['aliases']**  
    _Type:_ Hash  
    _Description:_ A hash of os_user => mail_alias entries, to be put in the revaliases file  
    _Default:_ empty hash

Usage
-----

#### ssmtp2::default

Just include `ssmtp2` in your node's `run_list` or in a `include_recipe` directive within a recipe

License and Authors
-------------------

Authors: Michael Morris  
License: 3-clause BSD
