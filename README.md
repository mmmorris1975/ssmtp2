ssmtp Cookbook
===================
A cookbook to configure the ssmtp utility. The ssmtp tool is a mail transfer agent (MTA), whose only function is to send messages from the local system to a proper mail relay.  The means that systems which previously used full-blown MTAs like sendmail/postfix/exim/etc... to send mail off to other systems, but never had a requirement to receive or process mail, can use ssmtp as a drop-in replacement; with a much simpler configuration, and likely less security concerns.

Requirements
------------
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

#### ssmtp::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['ssmtp']['conf_dir']</tt></td>
    <td>String</td>
    <td>The location of the ssmtp configuration files</td>
    <td><tt>/etc/ssmtp</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['debug']</tt></td>
    <td>Boolean</td>
    <td>Enable the Debug setting in the ssmtp.conf file</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['mailhub']['host']</tt></td>
    <td>String</td>
    <td>The host name of the upstream mail server</td>
    <td><tt>localhost</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['mailhub']['port']</tt></td>
    <td>Integer</td>
    <td>The port number of the upstream mail server</td>
    <td><tt>25</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['hostname']</tt></td>
    <td>String</td>
    <td>The hostname of the local system</td>
    <td><tt>the value of the node['hostname'] attribute</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['rewrite_domain']</tt></td>
    <td>String</td>
    <td>The domain name to masquerade outgoing mail as</td>
    <td><tt>the value of the node['domain'] attribute</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['from_line_override']</tt></td>
    <td>Boolean</td>
    <td>Specifies whether the From header of an email, if any, may override the default domain</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['root']</tt></td>
    <td>String</td>
    <td>The user that gets all mail for userids less than 1000. If blank, address rewriting is disabled.</td>
    <td><tt>&nbsp;</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['auth']['enabled']</tt></td>
    <td>Boolean</td>
    <td>If false, do not put authentication credentials in config file (no authentication will be attempted with the mail server)</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['auth']['username']</tt></td>
    <td>String</td>
    <td>The username to use for authentication with the upstream mail server</td>
    <td><tt>&nbsp;</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['auth']['password']</tt></td>
    <td>String</td>
    <td>The password to use for authentication with the upstream mail server</td>
    <td><tt>&nbsp;</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['auth']['method']</tt></td>
    <td>String</td>
    <td>The authentication method to use with the upstream mail server</td>
    <td><tt>no default, only supported value is cram-md5</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['tls_ca_file']</tt></td>
    <td>String</td>
    <td>The location of the CA certificate bundle to validate the mail server's SSL cert</td>
    <td><tt>Attempt to find the file in common OS locations if no value is specified</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['tls_ca_dir']</tt></td>
    <td>String</td>
    <td>The location of a directory containing trusted CA certificates to validate the mail server's SSL cert</td>
    <td><tt>no default, not required if using the 'tls_ca_file' attribute</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['use_tls']</tt></td>
    <td>Boolean</td>
    <td>If true, use TLS/SSL to communication with the upstream mail server</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['use_starttls']</tt></td>
    <td>Boolean</td>
    <td>If true, will send the STARTTLS command to the upstream mail server</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['tls_auth_cert']</tt></td>
    <td>String</td>
    <td>The path to the file containing the authentication certificate for the upstream mail server, if required</td>
    <td><tt>&nbsp;</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['tls']['tls_auth_key']</tt></td>
    <td>String</td>
    <td>The path to the file containing the authentication key for the upstream mail server, if required</td>
    <td><tt>&nbsp;</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['data_bag']['name']</tt></td>
    <td>String</td>
    <td>The name of the data bag that contains mail host configuration</td>
    <td><tt>mail</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['data_bag']['item']</tt></td>
    <td>String</td>
    <td>The name of the data bag item that contains the mail host configuration</td>
    <td><tt>ssmtp</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['data_bag']['format']</tt></td>
    <td>String</td>
    <td>Specifies whether or not the data bag is encrypted.  A value of 'plain' will use an unencrypted data bag</td>
    <td><tt>encrypted</tt></td>
  </tr>
  <tr>
    <td><tt>['ssmtp']['aliases']</tt></td>
    <td>Hash</td>
    <td>A hash of os_user => mail_alias entries, to be put in the revaliases file</td>
    <td><tt>empty hash</tt></td>
  </tr>
</table>

Usage
-----
#### ssmtp::default
Just include `ssmtp` in your node's `run_list` or in a `include_recipe` directive within a recipe

License and Authors
-------------------
Authors: Michael Morris

License: 3-clause BSD
