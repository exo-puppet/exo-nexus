class nexus (
  $image              = 'sonatype/nexus',
  $version            = 'pro-2.13.0-01',
  $install_dir        = '/opt/nexus',
  $data_dir           = '/srv/nexus',
  $log_dir            = '/var/log/nexus',
  $account            = 200,
  $front_network      = undef,
  $logo_path          = "",
  $container_labels   = [],
  $heap               = '2g',
  $smtp_network       = 'smtp',
) {
  ########################
  ## Directories
  ########################  
  file { "${nexus::install_dir}" :
    ensure    => directory,
    owner     => "${account}",
    group     => "${account}",
    mode      => '644',
  } ->
  file { "${nexus::install_dir}/conf" :
    ensure    => directory,
    owner     => "${account}",
    group     => "${account}",
    mode      => '640',
  } ->
  file { "${nexus::data_dir}" :
    ensure    => directory,
    owner     => "${account}",
    group     => "${account}",
    mode      => '640',
  }
  file { "${nexus::log_dir}" :
    ensure    => directory,
    owner     => "${account}",
    group     => "${account}",
    mode      => '644',
  }

  ########################
  ## Configuration
  ########################
  file { "${nexus::install_dir}/conf/nexus.properties" :
    ensure    => present,
    owner     => 'root',
    group     => 'root',
    mode      => '644',
    content     => template ('nexus/conf/nexus.properties.erb'),
  }

  ########################
  ## Docker compose file
  ########################
  file { "${nexus::install_dir}/docker-compose.yml" :
    ensure      => 'present',
    content     => template ('nexus/compose/docker-compose.yml.erb'),
    owner       => 'root',
    group       => 'root',
    mode        => '640',
  }
  
  ###########################
  #  Launch the containers
  ###########################
  docker_compose { "${nexus::install_dir}/docker-compose.yml" :
    ensure  => 'present',
    require => [
      Class['docker::compose'],
      File["${nexus::install_dir}/docker-compose.yml"],
    ],
  }

  # TODO backup
  # TODO rotation logs
}