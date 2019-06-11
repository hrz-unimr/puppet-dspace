# Class: dspace::configuration
#
# @summary General configuration for a DSpace instance.
#
# @param system_user
#  Name of UNIX system user of DSpace instance.
# @param clean_backups
#  Enable ANT clean_backups job (https://wiki.duraspace.org/display/DSDOC6x/Ant+targets+and+options).
# @param backup_directory
#  Path to directory for backups, e.g. AIP.
# @param dspace_name
#  Name of DSpace instance.
# @param dspace_hostname
#  Hostname of DSpace instance.
# @param dspace_base_url
#  Base URL of DSpace instance.
# @param dspace_source_dir
#  Path to directory of DSpace main code.
# @param dspace_dir
#  Path to DSpace instance directory.
# @param data_dir
#  Path to DSpace data directory, e.g. a shared one.
# @param assetstore_dir
#  Path to Assetstore directory.
# @param git_repository
#  URL to main code repository.
# @param git_revision
#  Branch or tag to checkout.
# @param separated_code_repositories
#  Use separated code repositories for main and customized code (https://wiki.duraspace.org/display/DSDOC6x/Advanced+Customisation).
# @param dspace_custom_dir
#  Path to directory of DSpace customized code.
# @param dspace_custom_repository
#  URL to customized code repository.
# @param dspace_custom_revision
#  Branch or tag to checkout.
# @param system_proxy_url
#  URL of proxy for OS.
# @param dspace_proxy_url
#  URL of proxy for DSpace application.
# @param git_proxy_url
#  URL of proxy for Git.
# @param manage_java_opts
#  Use pre configured Java Opts.
# @param java_opts
#  Additional Java Opts.
# @param java_memory_share
#  Size of shared Java memory.
# @param java_version
#  Java version.
# @param java_proxy_url
#  URL of proxy for JVM.
# @param manage_maven_opts
#  Use pre configured Maven Opts.
# @param maven_proxy_url
#  URL of proxy for Maven.
# @param maven_opts
#  Additional Maven Opts.
# @param manage_ant_opts
#  Use pre configured Ant Opts.
# @param ant_proxy_url
#  URL of proxy for Ant.
# @param ant_opts
#  Additional Ant Opts.
# @param manage_catalina_opts
#  Use pre configured Tomcat Opts.
# @param tomcat_version
#  Tomcat version.
# @param tomcat_proxy_url
#  URL of proxy for Tomcat.
# @param catalina_opts
#  Additional Tomcat Opts.
# @param default_language
#  Primary used language.
# @param supported_languages
#  On Web-UI supported languages.
# @param index_host
#  Hostname of Index instance.
# @param index_port
#  Port of Index instance.
# @param database_host
#  Hostname of Database instance.
# @param database_port
#  Port of Database instance.
# @param database_name
#  Name of Database.
# @param database_user
#  Name of Database user.
# @param database_passwd
#  Password of Database user.
# @param database_maxconnections
#  Number of maximum open database connections.
# @param database_maxwait
#  Secounds of maximum wait time of database response.
# @param database_maxidle
#  Number of maximum idle database connections.
# @param mail_host
#  Hostname of Mail instance.
# @param mail_port
#  Port of Mail instance.
# @param mail_user
#  Name of Mail user.
# @param mail_pass
#  Password of Mail user.
# @param mail_sender
#  Mail address of outgoing mails.
# @param mail_feedback_address
#  Mail address for user feedback.
# @param mail_admin_address
#  Mail address of system administration.
# @param mail_alert_address
#  Mail address for alert purposes.
# @param handle_prefix
#  DSpace handle prefix.
# @param log_level
#  DSpace log level.
# @param authentication_method
#  Multiple methods can be defined comma separated in one String.
# @param ldap_provider_url
#  URL of LDAP provider + Port. Has to end with '/'.
# @param ldap_search_user
#  DN of user who is allowed to search LDAP tree.
# @param ldap_search_passwd
#  Password of LDAP user.
# @param xml_workflow
#  Enable configurable workflow in XMLUI.
# @param doi_datacite
#  Enable DOI Service.
# @param doi_datacite_prod
#  Enable if no test DOIs should be used.
# @param doi_datacite_user
#  Name of DataCite user.
# @param doi_datacite_passwd
#  Password of DataCite user.
# @param doi_datacite_prefix
#  Used DOI prefix.
# @param doi_datacite_namespace
#  Used namespace separator.
# @param doi_datacite_publisher
#  Name of DOI publishing institution.
# @param doi_datacite_hosting
#  Name of data hosting institution.
# @param doi_datacite_datamanager
#  Name of data managing institution.
# @param item_versioning
#  Enable item versioning. DOI Versioning Service will be also enabled if
#  DOI Service is used.
# @param event_consumers
#  Used consumers. DOI and/or Versioning will be added if enabled.
# @param own_configuration
#  Name of additional configuration file that is included.
# @param dspace_launcher_commands
#  Custom command line tools which should be start as DSpace tool. Add one hash per tool
#
class dspace::configuration(
  String $system_user                  = 'tomcat8',
  Boolean $clean_backups               = false,
  String $backup_directory             = '/var/lib/dspace/app/archive',
  String $dspace_name                  = 'DSpace Repository Web Site',
  String $dspace_hostname              = 'localhost',
  String $dspace_base_url              = "http://${dspace_hostname}:8080",
  String $dspace_source_dir            = '/usr/lib/dspace-source',
  String $dspace_dir                   = '/usr/lib/dspace-instance',
  String $data_dir                     = $dspace_dir,
  String $assetstore_dir               = "${data_dir}/assetstore",
  String $git_repository               = 'https://github.com/DSpace/DSpace.git',
  String $git_revision                 = 'dspace-6.3',
  Boolean $separated_code_repositories = false,
  String $dspace_custom_dir            = '/usr/lib/dspace-custom',
  String $dspace_custom_repository     = '',
  String $dspace_custom_revision       = '',
  String $system_proxy_url             = '',
  String $dspace_proxy_url             = $system_proxy_url,
  String $git_proxy_url                = $system_proxy_url,
  Boolean $manage_java_opts            = true,
  String $java_opts                    = '',
  Float[0.0, 1.0] $java_memory_share   = 0.9,
  String $java_version                 = '8',
  String $java_proxy_url               = $system_proxy_url,
  Boolean $manage_maven_opts           = true,
  String $maven_proxy_url              = $system_proxy_url,
  String $maven_opts                   = '',
  Boolean $manage_ant_opts             = true,
  String $ant_proxy_url                = $system_proxy_url,
  String $ant_opts                     = '',
  Boolean $manage_catalina_opts        = true,
  String $tomcat_version               = '8',
  String $tomcat_proxy_url             = $system_proxy_url,
  String $catalina_opts                = '',
  String $default_language             = 'de',
  String $supported_languages          = 'en, de',
  String $index_host                   = $dspace_hostname,
  Integer $index_port                  = 8983,
  String $database_host                = $dspace_hostname,
  Integer $database_port               = 5432,
  String $database_name                = 'dspace',
  String $database_user                = 'dspace',
  String $database_passwd              = 'dspace',
  Integer $database_maxconnections     = 30,
  Integer $database_maxwait            = 5000,
  Integer $database_maxidle            = 10,
  String $mail_host                    = $dspace_hostname,
  Integer $mail_port                   = 25,
  String $mail_user                    = 'dspace',
  String $mail_pass                    = 'dspace',
  String $mail_sender                  = "noreply@${dspace_hostname}",
  String $mail_feedback_address        = "feedback@${dspace_hostname}",
  String $mail_admin_address           = "admin@${dspace_hostname}",
  String $mail_alert_address           = $mail_admin_address,
  String $handle_prefix                = '123456789',
  String $log_level                    = 'INFO',
  String $authentication_method        = 'org.dspace.authenticate.PasswordAuthentication',
  String $ldap_provider_url            = '',
  String $ldap_search_user             = '',
  String $ldap_search_passwd           = '',
  Boolean $xml_workflow                = false,
  Boolean $doi_datacite                = false,
  Boolean $doi_datacite_prod           = false,
  String $doi_datacite_user            = '',
  String $doi_datacite_passwd          = '',
  String $doi_datacite_prefix          = '10.5072',
  String $doi_datacite_namespace       = 'dspace',
  String $doi_datacite_publisher       = 'My Universitiy',
  String $doi_datacite_hosting         = $doi_datacite_publisher,
  String $doi_datacite_datamanager     = $doi_datacite_publisher,
  Boolean $item_versioning             = false,
  Array $event_consumers               = [ 'discovery', 'eperson' ],
  String $own_configuration            = '',
  Array $dspace_launcher_commands      = []
) {

  # Create Proxy Settings if used
  $proxy_url_regex = '(http|https)://([A-Za-z0-9\-\.]+):(\d+)$'

  # Setup DSpace proxy

  if ($dspace_proxy_url =~ String) and ($dspace_proxy_url != '') {

    $proxy_proto = regsubst($dspace_proxy_url, $proxy_url_regex, '\1')
    $proxy_host = regsubst($dspace_proxy_url, $proxy_url_regex, '\2')
    $proxy_port = regsubst($dspace_proxy_url, $proxy_url_regex, '\3')

    if ($proxy_proto) and ($proxy_host) and ($proxy_port) {
      notice("DSpace proxy will be set to ${proxy_proto}://${proxy_host}:${proxy_port}")
      # ... Proxy variables will be set in local.cfg.erb
    } else {
      fail("Invalid argument ${dspace_proxy_url} for parameter proxy_url")
    }

  }

  # Setup git proxy

  if ($git_proxy_url =~ String) and ($git_proxy_url != '') {

    $git_proxy_proto = regsubst($git_proxy_url, $proxy_url_regex, '\1')
    $git_proxy_host = regsubst($git_proxy_url, $proxy_url_regex, '\2')
    $git_proxy_port = regsubst($git_proxy_url, $proxy_url_regex, '\3')

    if ($git_proxy_proto) and ($git_proxy_host) and ($git_proxy_port) {

      notice("Git proxy will be set to ${git_proxy_proto}://${git_proxy_host}:${git_proxy_port}")

      file { '/etc/gitconfig':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      ini_setting { 'gitconfig.http.proxy':
        ensure  => present,
        path    => '/etc/gitconfig',
        section => 'http',
        setting => 'proxy',
        value   => "${git_proxy_proto}://${git_proxy_host}:${git_proxy_port}",
      }

      ini_setting { 'gitconfig.http.sslVerify':
        ensure  => present,
        path    => '/etc/gitconfig',
        section => 'http',
        setting => 'sslVerify',
        value   => true,
      }

    } else {
      fail("Invalid argument ${git_proxy_url} for parameter git_proxy_url")
    }

  }

  # Setup system proxy

  if ($system_proxy_url =~ String) and ($system_proxy_url != '') {

    $system_proxy_proto = regsubst($system_proxy_url, $proxy_url_regex, '\1')
    $system_proxy_host = regsubst($system_proxy_url, $proxy_url_regex, '\2')
    $system_proxy_port = regsubst($system_proxy_url, $proxy_url_regex, '\3')

    if ($system_proxy_proto) and ($system_proxy_host) and ($system_proxy_port) {

      notice("System proxy will be set to ${system_proxy_proto}://${system_proxy_host}:${system_proxy_port}")

      file { '/etc/profile.d/proxy.sh':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      shellvar { 'profile.proxy.https_proxy':
        ensure   => exported,
        target   => '/etc/profile.d/proxy.sh',
        variable => 'https_proxy',
        value    => "${system_proxy_proto}://${system_proxy_host}:${system_proxy_port}",
        quoted   => 'double',
      }

      shellvar { 'profile.proxy.HTTPS_PROXY':
        ensure   => exported,
        target   => '/etc/profile.d/proxy.sh',
        variable => 'HTTPS_PROXY',
        value    => "${system_proxy_proto}://${system_proxy_host}:${system_proxy_port}",
        quoted   => 'double',
      }

      shellvar { 'profile.proxy.HTTP_PROXY':
        ensure   => exported,
        target   => '/etc/profile.d/proxy.sh',
        variable => 'HTTP_PROXY',
        value    => "${system_proxy_proto}://${system_proxy_host}:${system_proxy_port}",
        quoted   => 'double',
      }

    } else {
      fail("Invalid argument ${system_proxy_url} for parameter system_proxy_url")
    }

  }

  # Setup Java

  if $manage_java_opts {

    $java_file_encoding = 'UTF-8'

    # Reserved share in main memory for Java Virtual Machine
    $java_heap_memory_share = $java_memory_share * 0.8 # We have to reserve a small rest for JVM non-heap memory

    # Set memory configuration parameters
    $java_min_heap_memory = 64
    $java_max_heap_memory = floor($::memorysize_mb * $java_heap_memory_share)

    if ($java_proxy_url =~ String) and ($java_proxy_url != '') {

      $java_proxy_proto = regsubst($java_proxy_url, $proxy_url_regex, '\1')
      $java_proxy_host = regsubst($java_proxy_url, $proxy_url_regex, '\2')
      $java_proxy_port = regsubst($java_proxy_url, $proxy_url_regex, '\3')

      if ($java_proxy_proto) and ($java_proxy_host) and ($java_proxy_port) {
        notice("Java proxy will be set to ${java_proxy_proto}://${java_proxy_host}:${java_proxy_port}")
        $java_opts_for_proxy = "-Dhttps.proxySet=true -Dhttps.proxyHost=${java_proxy_host} -Dhttps.proxyPort=${
          java_proxy_port} -Dhttp.proxySet=true -Dhttp.proxyHost=${java_proxy_host} -Dhttp.proxyPort=${
          java_proxy_port}"
      } else {
        fail("Invalid argument ${java_proxy_url} for parameter java_proxy_url")
      }

    } else {
      $java_opts_for_proxy = ''
    }

    file { '/etc/profile.d/java.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    shellvar { 'profile.java.JAVA_OPTS by dspace::configuration':
      ensure   => exported,
      target   => '/etc/profile.d/java.sh',
      variable => 'JAVA_OPTS',
      value    => "${java_opts} -Xms${java_min_heap_memory}M -Xmx${java_max_heap_memory}M -Dfile.encoding=${
        java_file_encoding} ${java_opts_for_proxy}",
      quoted   => 'double',
    }

    shellvar { 'service.tomcat.JAVA_OPTS by dspace::configuration':
      ensure   => present,
      target   => "/etc/default/tomcat${tomcat_version}",
      variable => 'JAVA_OPTS',
      value    => "${java_opts} -Xms${java_min_heap_memory}M -Xmx${java_max_heap_memory}M -Dfile.encoding=${
        java_file_encoding} ${java_opts_for_proxy}",
      quoted   => 'double',
    }

  }

  # Setup Maven

  if $manage_maven_opts {

    if ($maven_proxy_url =~ String) and ($maven_proxy_url != '') {

      $maven_proxy_proto = regsubst($maven_proxy_url, $proxy_url_regex, '\1')
      $maven_proxy_host = regsubst($maven_proxy_url, $proxy_url_regex, '\2')
      $maven_proxy_port = regsubst($maven_proxy_url, $proxy_url_regex, '\3')

      if ($maven_proxy_proto) and ($maven_proxy_host) and ($maven_proxy_port) {
        notice("Maven proxy will be set to ${maven_proxy_proto}://${maven_proxy_host}:${maven_proxy_port}")
        $maven_opts_for_proxy = "-Dhttps.proxySet=true -Dhttps.proxyHost=${maven_proxy_host} -Dhttps.proxyPort=${
          maven_proxy_port} -Dhttp.proxySet=true -Dhttp.proxyHost=${maven_proxy_host} -Dhttp.proxyPort=${
          maven_proxy_port}"
      } else {
        fail("Invalid argument ${maven_proxy_url} for parameter maven_proxy_url")
      }

    } else {
      $maven_opts_for_proxy = ''
    }

    file { '/etc/profile.d/maven.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    shellvar { 'profile.maven.MAVEN_OPTS':
      ensure   => exported,
      target   => '/etc/profile.d/maven.sh',
      variable => 'MAVEN_OPTS',
      value    => strip("${maven_opts} ${maven_opts_for_proxy}"),
      quoted   => 'double',
    }

  }

  # Setup Ant

  if $manage_ant_opts {

    if ($ant_proxy_url =~ String) and ($ant_proxy_url != '') {

      $ant_proxy_proto = regsubst($ant_proxy_url, $proxy_url_regex, '\1')
      $ant_proxy_host = regsubst($ant_proxy_url, $proxy_url_regex, '\2')
      $ant_proxy_port = regsubst($ant_proxy_url, $proxy_url_regex, '\3')

      if ($ant_proxy_proto) and ($ant_proxy_host) and ($ant_proxy_port) {
        notice("Ant proxy will be set to ${ant_proxy_proto}://${ant_proxy_host}:${ant_proxy_port}")
        $ant_opts_for_proxy = "-Dhttp.proxyHost=${ant_proxy_host} -Dhttp.proxyPort=${ant_proxy_port}"
      } else {
        fail("Invalid argument ${ant_proxy_url} for parameter ant_proxy_url")
      }

    } else {
      $ant_opts_for_proxy = ''
    }

    file { '/etc/profile.d/ant.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    shellvar { 'profile.ant.ANT_OPTS':
      ensure   => exported,
      target   => '/etc/profile.d/ant.sh',
      variable => 'ANT_OPTS',
      value    => strip("${ant_opts} ${ant_opts_for_proxy}"),
      quoted   => 'double',
    }

  }

  # Setup Tomcat

  if $manage_catalina_opts {

    if ($tomcat_proxy_url =~ String) and ($tomcat_proxy_url != '') {

      $tomcat_proxy_proto = regsubst($tomcat_proxy_url, $proxy_url_regex, '\1')
      $tomcat_proxy_host = regsubst($tomcat_proxy_url, $proxy_url_regex, '\2')
      $tomcat_proxy_port = regsubst($tomcat_proxy_url, $proxy_url_regex, '\3')

      if ($tomcat_proxy_proto) and ($tomcat_proxy_host) and ($tomcat_proxy_port) {
        notice("Tomcat proxy will be set to ${tomcat_proxy_proto}://${tomcat_proxy_host}:${tomcat_proxy_port}")
        $tomcat_opts_for_proxy = "-Dhttp.proxyHost=${tomcat_proxy_host} -Dhttp.proxyPort=${tomcat_proxy_port}"
      } else {
        fail("Invalid argument ${tomcat_proxy_url} for parameter tomcat_proxy_url")
      }

    }

    file { "/etc/profile.d/tomcat${tomcat_version}.sh":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    shellvar { "profile.tomcat${tomcat_version}.CATALINA_OPTS":
      ensure   => exported,
      target   => "/etc/profile.d/tomcat${tomcat_version}.sh",
      variable => 'CATALINA_OPTS',
      value    => $catalina_opts,
      quoted   => 'double',
    }

    file { "/etc/default/tomcat${tomcat_version}":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    shellvar { 'service.tomcat.CATALINA_OPTS':
      ensure   => present,
      target   => "/etc/default/tomcat${tomcat_version}",
      variable => 'CATALINA_OPTS',
      value    => $catalina_opts,
      quoted   => 'double',
    }

  }

}