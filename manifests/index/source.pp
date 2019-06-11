# Class: dspace::index::source
#
# @summary Installs and configures the dspace source.
#
# @param system_user
#   Name of UNIX system user for Solr index.
# @param system_group
#   Group of UNIX system user.
# @param source_directory
#   Path to code directory.
# @param git_repository
#   URL of code repository.
# @param git_revision
#   Branch or tag to checkout.
#
class dspace::index::source (
  String $system_user      = $dspace::configuration::system_user,
  String $system_group     = $system_user,
  String $source_directory = '/usr/lib/solr-source',
  String $git_repository   = $dspace::configuration::git_repository,
  String $git_revision     = $dspace::configuration::git_revision,
) {

  # Set variables

  $required_directories = [
    $source_directory,
  ]

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

  # Package configuration (possibly already defined elsewhere)

  ensure_packages('git', {
    ensure => 'installed',
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

  # DSpace source fetch

  vcsrepo { $source_directory:
    ensure   => latest,
    user     => $system_user,
    owner    => $system_user,
    group    => $system_group,
    provider => git,
    source   => $git_repository,
    revision => $git_revision,
    require  => [
      User[$system_user],
      Group[$system_group],
      File[$required_directories],
      Package['git'],
    ]
  }

}