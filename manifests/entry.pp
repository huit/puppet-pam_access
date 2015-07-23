# Define: pam_access::entry
#
# Parameters:
#
#   $create = true (default), false
#
#     If $create is true, an access.conf entry will be created; otherwise, one
#     (or more) will be removed.
#
#   $user = username, (groupname), ALL (EXCEPT)
#
#     Supply a valid user/group specification.
#
#   $origin = tty, hostname, domainname, address, ALL, LOCAL
#
#     Supply a valid origin specification.
#
#   $group = true, false (default)
#
#     If $group is true, the user specification $user will be interpreted as
#     a group name.
#
# Actions:
#
#   Creates an augeas resource to create or remove
#
# Requires:
#
#   Augeas >= 0.8.0 (access.conf lens is not present in earlier releases)
#
# Sample Usage:
#
#   pam_access::entry {
#     "mailman-cron":
#       user   => "mailman",
#       origin => "cron";
#     "root-localonly":
#       permission => "-",
#       user       => "root",
#       origin     => "ALL EXCEPT LOCAL";
#     "lusers-revoke-access":
#       create => false,
#       user   => "lusers",
#       group  => true;
#   }
#
define pam_access::entry (
  $create = true,
  $permission = '+',
  $user = false,
  $group = false,
  $origin = 'LOCAL'
) {

  if $::pam_access {

    # validate params
    case $permission {
      /^[+-]$/: {
        debug("\$pam_access::entry::permission: ${permission}")
      }
      default: {
        fail("\$pam_access::entry::permission must be '+' or '-'; '${permission}' received")
      }
    }

    Augeas {
      context => '/files/etc/security/access.conf/',
      incl    => '/etc/security/access.conf',
      lens    => 'Access.lns',
    }

    if $pam_access::exec {
      Augeas {
        before    => Exec['authconfig-access'],
        notify    => Exec['authconfig-access'],
      }
    }

    if $user {
      $userstr = $group ? {
        true    => "(${user})",
        default => $user
      }
    }
    else {
      $userstr = $group ? {
        true    => "(${title})",
        default => $title
      }
    }

    if $create {
      augeas {
        "augeas-pam_access-create-${title}":
          changes => [
            'ins access before access[last()]',
            "set access[last()-1] ${permission}",
            "set access[last()-1]/user ${userstr}",
            "set access[last()-1]/origin ${origin}",
          ],
          onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'] size == 0";
      }
    }
    else {
      augeas {
        "augeas-pam_access-destroy-${title}":
          changes => [
            "rm access[. = '${permission}'][user = '${userstr}'][origin = '${origin}']",
          ],
          onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'] size > 0";
      }
    }

  } else {
    debug('pam_access is not implemented on this platform, skipping')
  }

}
