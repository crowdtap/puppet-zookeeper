# Internal: Do everything the stock homebrew zookeeper package does
# as of Homebrew/homebrew@5a1138c09ce6d3c4825bb5e4d9ef3aaeeca5eebe
# but following boxen conventions

class zookeeper::package(
  $ensure    = undef,

  $package   = undef,
  $version   = undef,

  $configdir = undef,
  ) {
    $real_ensure = $ensure ? {
      present => $version,
      default => absent,
    }

    if $ensure == "present" {
      $shim_ensure = "file"
    } else {
      $shim_ensure = $ensure
    }

    package { $package:
      ensure => $real_ensure,
    }

    if $::operatingsystem == 'Darwin' {
      include boxen::config

      homebrew::formula { 'zookeeper': }

      ->
      Package[$package]

      ~>
      file { "${configdir}/defaults":
        ensure  => $ensure,
        content => template('zookeeper/defaults'),
      }

      ~>
      zookeeper::shim {
        [
          'zkServer',
          'zkCli',
          'zkCleanup'
        ]:
          ensure    => $ensure,
          configdir => $configdir;
      }
    }
}
