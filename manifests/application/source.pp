# Class: dspace::application::source
#
# @summary Installs and configures the dspace source.
#
# @param system_user
#   Name of UNIX system user for DSpace.
# @param system_group
#   Group of UNIX system user.
# @param source_directory
#   Path to DSpace code directory.
# @param git_repository
#   URL of used DSpace code repository.
# @param git_revision
#   Revision of used DSpace code repository.
# @param separated_repositories
#   Use separated repositories for default and customised code.
# @param dspace_custom_directory
#   Path to custom code directory.
# @param dspace_custom_repository
#   URL of used custom code respository.
# @param dspace_custom_revision
#   Revision of used custom code repository.
#
class dspace::application::source (
  String $system_user               = $dspace::configuration::system_user,
  String $system_group              = $system_user,
  String $source_directory          = $dspace::configuration::dspace_source_dir,
  String $git_repository            = $dspace::configuration::git_repository,
  String $git_revision              = $dspace::configuration::git_revision,
  Boolean $separated_repositories   = $dspace::configuration::separated_code_repositories,
  String $dspace_custom_directory   = $dspace::configuration::dspace_custom_dir,
  String $dspace_custom_repository  = $dspace::configuration::dspace_custom_repository,
  String $dspace_custom_revision    = $dspace::configuration::dspace_custom_revision,
) {

  # Set variables

  $required_directories = [
    $source_directory
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

  # DSpace customized source fetch

  if $separated_repositories == true {

    file { $dspace_custom_directory:
      ensure  => directory,
      owner   => $system_user,
      group   => $system_group,
      mode    => '0750',
      require => [
        User[$system_user],
        Group[$system_group]
      ]
    }

    vcsrepo { $dspace_custom_directory:
      ensure   => latest,
      user     => $system_user,
      owner    => $system_user,
      group    => $system_group,
      provider => git,
      source   => $dspace_custom_repository,
      revision => $dspace_custom_revision,
      require  => [
        User[$system_user],
        Group[$system_group],
        File[$required_directories],
        File[$dspace_custom_directory],
        Package['git'],
      ]
    }

    # Link to customize source directory

    file { "${source_directory}/dspace":
      ensure => 'link',
      target => $dspace_custom_directory,
      force  => true
    }

  }

}