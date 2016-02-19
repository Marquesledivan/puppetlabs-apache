# Class: apache::mod::status
#
# This class enables and configures Apache mod_status
# See: http://httpd.apache.org/docs/current/mod/mod_status.html
#
# Parameters:
# - $allow_from is an array of hosts, ip addresses, partial network numbers
#   or networks in CIDR notation specifying what hosts can view the special
#   /server-status URL.  Defaults to ['127.0.0.1', '::1'].
# - $extended_status track and display extended status information. Valid
#   values are 'On' or 'Off'.  Defaults to 'On'.
# - $status_path is the path assigned to the Location directive which
#   defines the URL to access the server status. Defaults to '/server-status'.
#
# Actions:
# - Enable and configure Apache mod_status
#
# Requires:
# - The apache class
#
# Sample Usage:
#
#  # Simple usage allowing access from localhost and a private subnet
#  class { 'apache::mod::status':
#    $allow_from => ['127.0.0.1', '10.10.10.10/24'],
#  }
#
class apache::mod::status (
  $allow_from      = ['127.0.0.1','::1'],
  $extended_status = 'On',
  $apache_version  = undef,
  $status_path     = '/server-status',
) inherits ::apache::params {
  include ::apache
  $real_apache_version = pick($apache_version, $apache::apache_version)
  validate_array($allow_from)
  validate_re(downcase($extended_status), '^(on|off)$', "${extended_status} is not supported for extended_status.  Allowed values are 'On' and 'Off'.")
  ::apache::mod { 'status': }
  # Template uses $allow_from, $extended_status, $apache_version, $status_path
  file { 'status.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/status.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/status.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
