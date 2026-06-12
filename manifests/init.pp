# @summary Main class to install and manage OpenHAB on OpenBSD.
#
# @param packages List of OpenHAB packages to install.
# @param service_name Name of the OpenHAB service.
# @param service_ensure Desired state of the service.
# @param service_enable Whether the service should start at boot.
class openhab (
  Array[String] $packages,
  String        $service_name,
  String        $service_ensure,
  Boolean       $service_enable,
  Integer       $http_port       = 8081,
  String        $http_address    = '127.0.0.1',
  String        $extra_java_opts = '',
) {
  # OpenBSD specific sanity check
  if $facts['os']['name'] != 'OpenBSD' {
    fail("This module is only supported on OpenBSD, detected: ${facts['os']['name']}")
  }

  package { $openhab::packages:
    ensure => installed,
  }

  file { '/etc/openhab.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    content => epp('openhab/openhab.conf.epp', {
      'http_port'       => $openhab::http_port,
      'http_address'    => $openhab::http_address,
      'extra_java_opts' => $openhab::extra_java_opts,
    }),
  }

  service { $openhab::service_name:
    ensure     => $openhab::service_ensure,
    enable     => $openhab::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

  # Ordering: Install packages -> Deploy config -> Refresh service if config changes
  Package[$packages] -> File['/etc/openhab.conf'] ~> Service[$service_name]
}

