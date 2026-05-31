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
) {
  # OpenBSD specific sanity check (optional but recommended)
  if $facts['os']['name'] != 'OpenBSD' {
    fail("This module is only supported on OpenBSD, detected: ${facts['os']['name']}")
  }

  package { $openhab::packages:
    ensure => installed,
  }

  service { $openhab::service_name:
    ensure     => $openhab::service_ensure,
    enable     => $openhab::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

  Package[$packages] ~> Service[$service_name]

}

