# Class: dspace::index::server
#
# @summary Installs and configures the dspace index server.
#
# @param host
#   Host name of index server.
# @param port
#   Port of index server.
# @param system_user
#   Name of UNIX system user for Solr index.
# @param system_group
#   Group of system user.
# @param version
#   Version of Solr index.
# @param java_version
#   Used Java version.
# @param source_directory
#   Path to Solr code directory.
# @param instance_directory
#   Path to Solr instance directory.
# @param data_directory
#   Path to Solr data directory.
# @param build_timeout
#   Time out of Maven build.
# @param install_timeout
#   Time out of Ant install.
# @param tomcat_version
#   Used Tomcat version.
# @param tomcat_instance_directory
#   Path to Tomcat instance directory.
# @param tomcat_proxy_url
#   Proxy URL for Tomcat.
#
class dspace::index::server (
  String $host                      = $dspace::configuration::index_host,
  Integer $port                     = $dspace::configuration::index_port,
  String $system_user               = $dspace::configuration::system_user,
  String $system_group              = $system_user,
  String $version                   = '4.10.4',
  String $java_version              = $dspace::configuration::java_version,
  String $source_directory          = '/usr/lib/solr-source',
  String $instance_directory        = '/usr/lib/solr-instance',
  String $data_directory            = '/var/lib/solr',
  Integer $build_timeout            = 360,
  Integer $install_timeout          = 60,
  String $tomcat_version            = $dspace::configuration::tomcat_version,
  String $tomcat_instance_directory = '/var/lib/tomcat8',
  String $tomcat_proxy_url          = $dspace::configuration::tomcat_proxy_url,
) {

  # Set variables

  $required_java_package = "openjdk-${java_version}-jdk"

  $required_packages = [
    'maven',
    'ant',
  ]

  $required_directories = [
    $instance_directory,
    $tomcat_instance_directory,
    $data_directory,
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
      system  => true,
      groups  => [$system_group],
      require => [
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


  # Solr source configuration
  # Currently we use the dspace sources in a separate
  # directory for separate dspace-flavoured dspace-solr installation

  file { "${source_directory}/dspace/config/local.cfg":
    ensure  => file,
    owner   => $system_user,
    group   => $system_group,
    mode    => '0640',
    content => template('dspace/config/solr-local.cfg.erb'),
    require => [
      User[$system_user],
      Group[$system_group],
      Class['dspace::index::source'],
    ]
  }

  # Solr build, only if vcsrepo or local.cfg updated

  exec { "Build Solr in ${source_directory}":
    user        => $system_user,
    group       => $system_group,
    provider    => posix,
    cwd         => $source_directory,
    command     =>
      '/bin/bash -c \'mvn package -P \
      "dspace-solr,!dspace-jspui,!dspace-xmlui,!dspace-oai,!dspace-sword,\
      !dspace-swordv2,!dspace-rest,!dspace-rdf"\''
    ,
    path        => [
      '/usr/bin',
      '/bin',
    ],
    timeout     => $build_timeout,
    logoutput   => true,
    subscribe   => [
      User[$system_user],
      Group[$system_group],
      Package['maven'],
      Vcsrepo[$source_directory],
      File["${source_directory}/dspace/config/local.cfg"],
    ],
    refreshonly => true,
    # Disable applying exec in puppet noop run
    noop        => false,
  }

  # Solr install, only if build was executed

  exec { "Install Solr in ${instance_directory}":
    user        => $system_user,
    group       => $system_group,
    provider    => posix,
    cwd         => "${source_directory}/dspace/target/dspace-installer",
    command     => "/bin/bash -c 'if [ -f ${instance_directory}/webapps/solr/WEB-INF ];
       then ant update_configs; ant update_code; ant update_webapps;
       else ant init_installation; ant init_configs; ant install_code; ant copy_webapps; fi'"
    ,
    timeout     => $install_timeout,
    logoutput   => true,
    subscribe   => [
      Package['ant'],
      Exec["Build Solr in ${source_directory}"],
    ],
    notify      => [
      Tomcat::Instance["tomcat${tomcat_version}"],
      Tomcat::Service["tomcat${tomcat_version}"],
    ],
    refreshonly => true,
    # Disable applying exec in puppet noop run
    noop        => false,
  }

  # Solr instance configuration

  file { "${instance_directory}/solr/authority/conf/solrcore.properties":
    ensure    => file,
    owner     => $system_user,
    group     => $system_group,
    mode      => '0640',
    content   => "solr.data.dir = ${data_directory}/authority",
    subscribe => [
      Exec["Install Solr in ${instance_directory}"],
    ]
  }

  file { "${instance_directory}/solr/search/conf/solrcore.properties":
    ensure    => file,
    owner     => $system_user,
    group     => $system_group,
    mode      => '0640',
    content   => "solr.data.dir = ${data_directory}/search",
    subscribe => [
      Exec["Install Solr in ${instance_directory}"],
    ]
  }

  file { "${instance_directory}/solr/oai/conf/solrcore.properties":
    ensure    => file,
    owner     => $system_user,
    group     => $system_group,
    mode      => '0640',
    content   => "solr.data.dir = ${data_directory}/oai",
    subscribe => [
      Exec["Install Solr in ${instance_directory}"],
    ]
  }

  file { "${instance_directory}/solr/statistics/conf/solrcore.properties":
    ensure    => file,
    owner     => $system_user,
    group     => $system_group,
    mode      => '0640',
    content   => "solr.data.dir = ${data_directory}/statistics",
    subscribe => [
      Exec["Install Solr in ${instance_directory}"],
    ]
  }

  # Create webapp links in tomcat webapps directory,
  # referring to solr webapp directories

  file { "${tomcat_instance_directory}/webapps/solr":
    ensure    => 'link',
    target    => "${instance_directory}/webapps/solr",
    subscribe => [
      File[
        "${instance_directory}/solr/authority/conf/solrcore.properties",
        "${instance_directory}/solr/search/conf/solrcore.properties",
        "${instance_directory}/solr/oai/conf/solrcore.properties",
        "${instance_directory}/solr/statistics/conf/solrcore.properties",
      ],
      Exec["Install Solr in ${instance_directory}"],
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

  tomcat::config::server::connector { 'Tomcat Solr HTTP connector':
    catalina_base         => $tomcat_instance_directory,
    port                  => $port,
    protocol              => 'HTTP/1.1',
    additional_attributes => {
      'address'           => $listen_ip,
      'connectionTimeout' => '60000', # 60 seconds
      'keepAliveTimeout'  => '300000', # 5 minutes
      'maxPostSize'       => '4194304', # 4 MB
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