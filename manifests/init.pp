# Class: pam_access
#
# This module manages pam_access
#    this module manages /etc/security/access.conf file
#
# Parameters:
#
#   $exec: true, false
#
#   If true, pam_access will take care of calling authconfig to apply its
#   changes; if false, you must do this yourself elsewhere in your manifest.
#
# Actions:
#
# Requires:
#
# See pam_access::entry for more documentation.
#
# [Remember: No empty lines between comments and class definition]
class pam_access (
  $exec = true
) {
  if $::pam_access {

    file { '/etc/security/access.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    if $pam_access::exec {

      exec { 'authconfig-access':
        command => 'authconfig --enablelocauthorize --enablepamaccess --update',
        path    => '/usr/bin:/usr/sbin:/bin',
        unless  => "grep '^account.*required.*pam_access.so' \
                      /etc/pam.d/system-auth 2>/dev/null",
        require => File['/etc/security/access.conf'],
      }
    }

  } else {
    debug('pam_access not implemented on this platform')
  }
}
