# Class: dspace::application::server
#
# @summary Installs and configures the dspace application server.
#
# @param host
#   Host name of server.
# @param port
#   Port of web application server.
# @param system_user
#   Unix user who runs DSpace instance.
# @param system_group
#   Group of system_user.
# @param tomcat_version
#   Used Tomcat version.
# @param tomcat_instance_directory
#   Path to Tomcat directory.
# @param java_version
#   Used Java version.
# @param source_directory
#   Path to DSpace source directory.
# @param instance_directory
#   Path to DSpace instance directory.
# @param data_directory
#   Path to DSpace data directory.
# @param build_timeout
#   Time out of Maven build.
# @param install_timeout
#   Time out of Ant install.
# @param clean_backups
#   Enable clean up of ant install backup directories.
#
class dspace::application::server (
  String $host                        = 'localhost',
  Integer $port                       = 8080,
  String $system_user                 = $dspace::configuration::system_user,
  String $system_group                = $system_user,
  String $tomcat_version              = $dspace::configuration::tomcat_version,
  String $tomcat_instance_directory   = '/var/lib/tomcat8',
  String $java_version                = $dspace::configuration::java_version,
  String $source_directory            = $dspace::configuration::dspace_source_dir,
  String $instance_directory          = $dspace::configuration::dspace_dir,
  String $data_directory              = $dspace::configuration::data_dir,
  Integer $build_timeout              = 3600,
  Integer $install_timeout            = 300,
  Boolean $clean_backups              = $dspace::configuration::clean_backups,
) {

  # Set variables

  $required_java_package = "openjdk-${java_version}-jdk"

  $required_packages = [
    'maven',
    'ant',
  ]

  $required_directories = [
    $instance_directory,
    $data_directory,
    $tomcat_instance_directory,
  ]

  $listen_ip = $host ? {
    'localhost' => '127.0.0.1',
    '*'         => '0.0.0.0',
    default     => $host,
  }

  # System package configuration

  # Separate Java package from other because of their dependencies.
  # E.g. Maven installed Java if not exists, which may be a not
  # supported version.
  ensure_packages($required_java_package, {
    ensure => 'installed'
  })

  ensure_packages($required_packages, {
    ensure  => 'installed',
    require => [
      Package[$required_java_package]
    ]
  })

  # System user and group configuration (possibly already defined elsewhere)

  ensure_resources('group', {
    $system_group => {
      system => true,
    }
  }, {
    ensure => present,
  })

  ensure_resources('user', {
    $system_user => {
      system      => true,
      groups      => [$system_group],
      require     => [
        Group[$system_group],
      ],
    }
  }, {
    ensure => present,
  })

  # File and directory configuration

  ensure_resources('file', {
    $required_directories => {
      owner   => $system_user,
      group   => $system_group,
      mode    => '0750',
      require => [
        User[$system_user],
        Group[$system_group],
      ]
    }
  }, {
    ensure => directory,
  })

  # Maven settings.xml for proxy support

  if ($dspace::configuration::tomcat_proxy_url =~ String) and ($dspace::configuration::tomcat_proxy_url != '') {

    file { "${tomcat_instance_directory}/.m2":
      ensure  => directory,
      owner   => $system_user,
      group   => $system_group,
      mode    => '0750',
      require => [
        User[$system_user],
        Group[$system_group],
        Class['dspace::application::source'],
      ]
    }

    file { "${tomcat_instance_directory}/.m2/settings.xml":
      ensure  => file,
      owner   => $system_user,
      group   => $system_group,
      mode    => '0640',
      content => template('dspace/config/settings.xml.erb'),
      require => [
        User[$system_user],
        Group[$system_group],
        Class['dspace::application::source'],
      ]
    }

  }

  # DSpace source configuration

  file { "${source_directory}/dspace/config/local.cfg":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0600',
    content => template('dspace/config/local.cfg.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  # DSpace configurable workflow configuration and versioning

  file { "${source_directory}/dspace/config/xmlui.xconf":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/xmlui.xconf.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  file { "${source_directory}/dspace/config/hibernate.cfg.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/hibernate.cfg.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  file { "${source_directory}/dspace/config/spring/api/core-services.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/core-services.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  file { "${source_directory}/dspace/config/spring/api/core-factory-services.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/core-factory-services.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  # DSpace DOI per Datacite

  file { "${source_directory}/dspace/config/spring/api/identifier-service.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/identifier-service.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  # DSpace-Rest web.xml for SSL support

  file { "${source_directory}/dspace-rest/src/main/webapp/WEB-INF/web.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/web.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  # DSpace launcher for CLI-Tools

  file { "${source_directory}/dspace/config/launcher.xml":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/launcher.xml.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::application::source'],
    ]
  }

  # DSpace build, only if vcsrepo or local.cfg updated

  exec { "Build DSpace in ${source_directory}":
    user        => $system_user,
    group       => $system_group,
    provider    => posix,
    cwd         => $source_directory,
    command     => '/bin/bash -c \'mvn clean package -Dmirage2.on=true\'',
    path        => [
      '/usr/bin',
      '/bin',
    ],
    timeout     => $build_timeout,
    logoutput   => true,
    subscribe   => [
      Package['maven'],
      Vcsrepo[$source_directory],
      File["${source_directory}/dspace/config/local.cfg"],
      File["${source_directory}/dspace/config/xmlui.xconf"],
      File["${source_directory}/dspace/config/hibernate.cfg.xml"],
      File["${source_directory}/dspace/config/spring/api/core-services.xml"],
      File["${source_directory}/dspace/config/spring/api/core-factory-services.xml"],
      File["${source_directory}/dspace/config/spring/api/identifier-service.xml"],
    ],
    refreshonly => true,
    # Disable applying exec in puppet noop run
    noop        => false,
  }

  # DSpace install, only if build was executed

  exec { "Install DSpace in ${instance_directory}":
    user        => $system_user,
    group       => $system_group,
    provider    => posix,
    cwd         => "${source_directory}/dspace/target/dspace-installer",
    command     => "/bin/bash -c 'if [ -f ${instance_directory}/bin/dspace ];
        then ant update;
        else ant fresh_install; fi;
        if [ ${clean_backups} = true ];
        then ant clean_backups; fi'",
    timeout     => $install_timeout,
    logoutput   => true,
    subscribe   => [
      Package['ant'],
      Exec["Build DSpace in ${source_directory}"],
    ],
    notify      => [
      Tomcat::Instance["tomcat${tomcat_version}"],
      Tomcat::Service["tomcat${tomcat_version}"],
    ],
    refreshonly => true,
    # Disable applying exec in puppet noop run
    noop        => false,
  }

  # Change mode of local.cfg to 0600
  file { "${instance_directory}/config/local.cfg":
    ensure    => file,
    mode      => '0600',
    subscribe => [
        Exec["Install DSpace in ${instance_directory}"],
    ],
  }

  # Create links to DSpace data directory,
  # if data directory is not instance directory.
  if ($instance_directory != $data_directory) {

    file { "${data_directory}/exports":
      ensure    => 'directory',
      owner     => $system_user,
      group     => $system_group,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${instance_directory}/exports":
      ensure    => 'link',
      owner     => $system_user,
      group     => $system_group,
      target    => "${data_directory}/exports",
      force     => true,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { ["${data_directory}/var", "${data_directory}/var/oai"]:
      ensure    => 'directory',
      owner     => $system_user,
      group     => $system_group,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${instance_directory}/var/oai":
      ensure    => 'link',
      owner     => $system_user,
      group     => $system_group,
      target    => "${data_directory}/var/oai",
      force     => true,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${data_directory}/ctqueues":
      ensure    => 'directory',
      owner     => $system_user,
      group     => $system_group,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${instance_directory}/ctqueues":
      ensure    => 'link',
      owner     => $system_user,
      group     => $system_group,
      target    => "${data_directory}/ctqueues",
      force     => true,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${data_directory}/sitemaps":
      ensure    => 'directory',
      owner     => $system_user,
      group     => $system_group,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

    file { "${instance_directory}/sitemaps":
      ensure    => 'link',
      owner     => $system_user,
      group     => $system_group,
      target    => "${data_directory}/sitemaps",
      force     => true,
      subscribe => [
        Exec["Install DSpace in ${instance_directory}"]
      ]
    }

  }

  # Create webapp links in tomcat webapps directory,
  # referring to dspace webapp directories

  file { "${tomcat_instance_directory}/webapps/rest":
    ensure    => 'link',
    target    => "${instance_directory}/webapps/rest",
    subscribe => [
      Exec["Install DSpace in ${instance_directory}"],
    ],
  }

  file { "${tomcat_instance_directory}/webapps/ROOT":
    ensure    => 'link',
    target    => "${instance_directory}/webapps/xmlui",
    subscribe => [
      Exec["Install DSpace in ${instance_directory}"],
    ],
    force     => true,
  }

  file { "${tomcat_instance_directory}/webapps/oai":
    ensure    => 'link',
    target    => "${instance_directory}/webapps/oai",
    subscribe => [
      Exec["Install DSpace in ${instance_directory}"],
    ],
  }

  file { "${tomcat_instance_directory}/webapps/rdf":
    ensure    => 'link',
    target    => "${instance_directory}/webapps/rdf",
    subscribe => [
      Exec["Install DSpace in ${instance_directory}"],
    ],
  }

  # Tomcat instance configuration

  ensure_resources('tomcat::install', {
    "tomcat${tomcat_version}" => {
      install_from_source => false,
      package_name        => "tomcat${tomcat_version}",
      allow_insecure      => false,
    }
  },
  )

  ensure_resources('tomcat::instance', {
    "tomcat${tomcat_version}" => {
      catalina_home  => $tomcat_instance_directory,
      user           => $system_user,
      group          => $system_group,
      manage_user    => false,
      manage_group   => false,
      manage_service => false,
    }
  },
  )

  tomcat::config::server::connector { 'Tomcat DSpace HTTP connector':
    catalina_base         => $tomcat_instance_directory,
    port                  => $port,
    protocol              => 'HTTP/1.1',
    additional_attributes => {
      'address'           => $listen_ip,
      'connectionTimeout' => '60000', # 60 seconds
      'keepAliveTimeout'  => '300000', # 5 minutes
      'maxPostSize'       => '4294967296', # 4 GB
      'URIEncoding'       => 'UTF-8',
    },
  }

  ensure_resources('tomcat::service', {
    "tomcat${tomcat_version}" => {
      catalina_home  => $tomcat_instance_directory,
      catalina_base  => $tomcat_instance_directory,
      use_init       => true,
      service_name   => "tomcat${tomcat_version}",
      service_ensure => 'running',
    }
  },
  )

}