# Class dspace::application::cron
#
# @summary Installs and configures cron jobs for DSpace maintenance (https://wiki.duraspace.org/display/DSDOC6x/Scheduled+Tasks+via+Cron).
#
# @param dspace_user
#   Name of UNIX user who runs dspace instance.
# @param dspace_user_group
#   Name of UNIX user group of user who runs dspace instance.
# @param dspace_instance_directory
#   Path to DSpace instance directory.
# @param media_filter_plugins
#   List plugins which should be used in media filter.
#
class dspace::application::cron (
  String $dspace_user               = $dspace::application::server::system_user,
  String $dspace_user_group         = $dspace::application::server::system_group,
  String $dspace_instance_directory = $dspace::application::server::instance_directory,
  Array $media_filter_plugins       = []
) {

  # Check if only specific plugins should be used in media filter.
  $plugins = $media_filter_plugins.empty ? {
    false    => join(["-p '", join($media_filter_plugins,','),"'"],''),
    default => ''
  }

  # Generate sitemaps every eight hours
  cron {
    'generate-sitemaps':
      command => join([$dspace_instance_directory, 'bin/dspace generate-sitemaps > /dev/null'], '/'),
      user    => $dspace_user,
      hour    => [0, 8, 16],
  }

  # Daily cron jobs
  cron {
    'media-filter':
      command => join([$dspace_instance_directory, "bin/dspace filter-media\
                       ${plugins} >\
                       ${dspace_instance_directory}/log/filter-media.log"], '/'),
      user    => $dspace_user,
      hour    => 0,
      minute  => 30,
  }

  cron {
    'index-discovery':
      command => join([$dspace_instance_directory, 'bin/dspace index-discovery > /dev/null'], '/'),
      user    => $dspace_user,
      hour    => 1,
      minute  => 30,
  }

  cron {
    'index-discovery-optimize':
      command => join([$dspace_instance_directory, 'bin/dspace index-discovery -o > /dev/null'], '/'),
      user    => $dspace_user,
      hour    => 2,
      minute  => 0,
  }

  #cron {
  #  'daily-user-notifaction':
  #   command => join([$dspace_instance_directory, 'bin/dspace sub-daily > /dev/null'], '/'),
  #   user    => $dspace_user,
  #   hour    => 5,
  #   minute  => 0,
  #}

  # Weekly cron jobs
  cron {
    'checksum-checker':
      command => join([$dspace_instance_directory, 'bin/dspace checker -l -p'], '/'),
      user    => $dspace_user,
      weekday => 6,
      hour    => 4,
      minute  => 0,
  }

  cron {
    'checksum-email':
      command => join([$dspace_instance_directory, 'bin/dspace checker-emailer -a'], '/'),
      user    => $dspace_user,
      weekday => 6,
      hour    => 5,
      minute  => 5,
  }

  # Monthly clean up
  cron {
    'dspace-clean-up':
      command  => join([$dspace_instance_directory, 'bin/dspace cleanup > /dev/null'], '/'),
      user     => $dspace_user,
      monthday => 1,
      hour     => 5,
      minute   => 30,
  }

}