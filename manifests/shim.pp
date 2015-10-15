# Creates a shim wrapper script for the Zookeeper executables

define zookeeper::shim(
  $ensure    = undef,
  $configdir = undef,
) {
  include boxen::config
  $libexec = "${boxen::config::homebrewdir}/Cellar/zookeeper/${zookeeper::version}/libexec"

  file { "${boxen::config::homebrewdir}/bin/${name}":
    ensure  => $ensure,
    replace => true,
    content => template('zookeeper/shim_script'),
    mode    => '0755',
    owner   => $::boxen_user,
    group   => staff,
  }
}
