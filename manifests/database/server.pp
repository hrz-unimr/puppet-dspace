# Class: dspace::database::server
#
# @summary Installs and configures the dspace database server.
#
# @param version
#   PostgreSQL version.
# @param host
#   Host name of database server.
# @param port
#   Port of database server.
# @param data_directory
#   Path to PostgreSQL data directory.
# @param system_user
#   Name of PostgreSQL UNIX system user.
# @param system_group
#   Group of system user.
# @param database_name
#   Name of used database.
# @param database_user
#   Name of database user.
# @param database_pass
#   Password of database user.
# @param cluster
#   Name of cluster to which database server belongs.
# @param memory_share
#   Size of shared database memory.
# @param manage_memory_share
#   Memory share is managed by this module.
# @param manage_database
#   Database is managed by this module.
#
class dspace::database::server (
  String $version               = '9.6',
  String $host                  = $dspace::configuration::database_host,
  Integer $port                 = $dspace::configuration::database_port,
  String $data_directory        = '/var/lib/postgresql',
  String $system_user           = 'postgres',
  String $system_group          = 'postgres',
  String $database_name         = $dspace::configuration::database_name,
  String $database_user         = $dspace::configuration::database_user,
  String $database_pass         = $dspace::configuration::database_passwd,
  Optional[String] $cluster     = undef,
  Float[0.0, 1.0] $memory_share = 0.9,
  Boolean $manage_memory_share  = true,
  Boolean $manage_database      = true,
) {

  $listen_ip = $host ? {
    'localhost' => '127.0.0.1',
    '*'         => '0.0.0.0',
    default     => $host,
  }

  group { $system_group:
    ensure => present,
    system => true,
  }

  user { $system_user:
    ensure  => present,
    system  => true,
    groups  => [$system_group],
    require => [
      Group[$system_group],
    ],
  }

  class { 'postgresql::globals':
    version  => $version,
    encoding => 'UTF-8',
  }

  class { 'postgresql::server':
    port    => $port,
    user    => $system_user,
    group   => $system_group,
    require => [
      User[$system_user],
      Group[$system_group],
    ]
  }

  postgresql::server::config_entry { 'listen_addresses':
    value => $listen_ip,
  }

  if $manage_memory_share == true {

    # PostgreSQL performance tuning, mainly based on the PostgreSQL server
    # tuning documentation from 2017-12-15, see:
    # https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server

    # Reserved share in main memory for database application
    $database_memory_share = $memory_share
    # Reserved share in main memory for system and other applications
    $system_memory_share = 1 - $database_memory_share
    # Reserved share in main memory for PostgreSQL shared buffers
    $shared_buffers_memory_share = $database_memory_share * 0.3
    # Reserved share in main memory for total PostgreSQL connection pool
    $connection_pool_memory_share = $database_memory_share - $shared_buffers_memory_share

    # Set PostgreSQL performance configuration parameters
    $connection_work_mem = 4 # PostgreSQL 9.6 default
    $maintenance_work_mem = 64 # PostgreSQL 9.6 default
    $shared_buffers_mem = floor($::memorysize_mb * $shared_buffers_memory_share)
    $connection_pool_mem = floor($::memorysize_mb * $connection_pool_memory_share)
    $max_connections = floor($connection_pool_mem / $connection_work_mem)

    notice("Set database memory share of ${memory_share} in ${::memorysize_mb} MB main memory, resulting in ${
      shared_buffers_mem} MB shared buffers memory, ${
      connection_pool_mem} MB connection pool memory and ${max_connections} maximum connections each provided with ${
      connection_work_mem} MB connection work memory.")

    postgresql::server::config_entry { 'shared_buffers':
      value => "${shared_buffers_mem}MB",
    }

    postgresql::server::config_entry { 'work_mem':
      value => "${connection_work_mem}MB",
    }

    postgresql::server::config_entry { 'maintenance_work_mem':
      value => "${maintenance_work_mem}MB",
    }

    postgresql::server::config_entry { 'max_connections':
      value => $max_connections,
    }

  }

  if $manage_database == true {

    if $database_name and $database_user and $database_pass {

      postgresql::server::db { $database_name:
        user     => $database_user,
        password => postgresql_password($database_user, $database_pass),
      }

    } else {
      fail('Attributes for parameters database_name, database_user and database_pass must be supplied')
    }

    postgresql::server::extension { 'pgcrypto':
      ensure   => present,
      database => $database_name,
    }

  }

}