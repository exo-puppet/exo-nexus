class nexus (
  $image              = 'sonatype/nexus',
  $version            = 'pro-2.14.14-01',
  $install_dir        = '/opt/nexus',
  $manage_install_dir = true,
  $data_dir           = '/srv/nexus',
  $log_dir            = '/var/log/nexus',
  $account            = 200,
  $front_network      = undef,
  $logo_path          = '',
  $container_labels   = [],
  $heap               = '2g',
  $smtp_network       = 'smtp',
  $smart_proxy_port   = 21976,
) {
  ########################
  ## Directories
  ########################

  if (manage_install_dir == true) {
    file { $nexus::install_dir :
      ensure  => directory,
      owner   => $account,
      group   => $account,
      mode    => '0640',
      require => [File[$nexus::install_dir]],
    }
  }

  file { "${nexus::install_dir}/conf" :
    ensure  => directory,
    owner   => $account,
    group   => $account,
    mode    => '0640',
    require => [File[$nexus::install_dir]],
  }
  -> file { $nexus::data_dir :
    ensure => directory,
    owner  => $account,
    group  => $account,
    # execution for all permission is needed for synchronization with maven central
    mode   => '0641',
  }
  file { $nexus::log_dir :
    ensure => directory,
    owner  => $account,
    group  => $account,
    mode   => '0644',
  }

  ########################
  ## Configuration
  ########################
  file { "${nexus::install_dir}/conf/nexus.properties" :
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template ('nexus/conf/nexus.properties.erb'),
    require => [File[$nexus::install_dir]],
  }

  ########################
  ## Docker compose file
  ########################
  file { "${nexus::install_dir}/docker-compose.yml" :
    ensure  => 'present',
    content => template ('nexus/compose/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => [File[$nexus::install_dir]],
    notify  => [Docker_compose["${nexus::install_dir}/docker-compose.yml"]],
  }

  ###########################
  #  Launch the containers
  ###########################
  docker_compose { "${nexus::install_dir}/docker-compose.yml" :
    ensure  => 'present',
    require => [
      Class['docker::compose'],
      File["${nexus::install_dir}/docker-compose.yml"],
      File["${nexus::install_dir}/conf/nexus.properties"],
    ],
  }

  # TODO backup
}
