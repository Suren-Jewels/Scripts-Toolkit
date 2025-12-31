# Capability: Enforce DBI retirement state on a Linux host via Puppet.

class dbi::retire {

  notice("Applying DBI retirement enforcement")

  # Stop DBI service if present
  service { 'mysqld':
    ensure => 'stopped',
    enable => false,
    hasstatus => true,
    hasrestart => true,
  }

  # Disable DBI package if installed
  package { 'mysql-server':
    ensure => 'absent',
  }

  # Mark DBI as retired on host
  file { '/etc/dbi_retired.flag':
    ensure  => 'present',
    mode    => '0644',
    content => "DBI retired by Puppet\n",
  }
}
