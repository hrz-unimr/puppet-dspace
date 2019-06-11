# Type: dspace::application::node
#
# @summary Installs and configures a dspace application node in a dspace cluster.
#
# @param cluster
#  Name of cluster in which the node lives.
# @param host
#  Host IP adress.
# @param hostname
#  Host name.
# @param application_port
#  Port of DSpace application server.
# @param application_proxy_port
#  Proxy port for DSpace application server.
# @param database_port
#  Port of database server.
# @param database_proxy_port
#  Proxy port for database server.
# @param index_port
#  Port of index server.
# @param index_proxy_port
#  Proxy port for index server.
#
class dspace::application::node (
  String $cluster                 = 'default',
  String $host                    = $::facts['networking']['ip'],
  String $hostname                = $::fqdn,
  Integer $application_port       = $dspace::application::server::port,
  Integer $application_proxy_port = $application_port,
  Integer $database_port          = $dspace::configuration::database_port,
  Integer $database_proxy_port    = $database_port,
  Integer $index_port             = $dspace::configuration::index_port,
  Integer $index_proxy_port       = $index_port,
) {

  $node_ip = $host ? {
    'localhost'   => '127.0.0.1',
    '*'           => '0.0.0.0',
    default       => $host,
  }

  include ::haproxy

  # Communication from application perspective
  #
  # Portal (1) <-> Application (n)
  # Application (n) <-> Database (1)
  # Application (n) <-> Index (1)
  #

  # Configure relation between portal and application
  #

  # Configure local remote-to-local haproxy listener
  haproxy::listen { 'dspace-application-local':
    collect_exported => false,
    mode             => 'tcp',
    ipaddress        => $node_ip,
    # lint:ignore:only_variable_string
    ports            => [ $application_proxy_port ],
    # lint:endignore
    options          => {
      'option'          => [
        'tcp-check',
        'log-health-checks',
        'tcplog',
      ],
      'log'             => 'global',
      'balance'         => 'leastconn',
      'timeout connect' => '5000',
      'timeout client'  => '360000',
      'timeout server'  => '360000',
    }
  }

  # Configure local-to-local haproxy balancer member
  haproxy::balancermember { "dspace-application-node-in-cluster-${cluster}":
    listening_service => 'dspace-application-local',
    server_names      => '127.0.0.1',
    ipaddresses       => '127.0.0.1',
    # lint:ignore:only_variable_string
    ports             => [ $application_port ],
    # lint:endignore
    options           => [
      'check inter 30000',
      'fastinter 2000',
      'downinter 15000',
    ]
  }

  # Configure and export remote-to-local haproxy balancer member
  @@haproxy::balancermember { "dspace-application-node-in-cluster-${cluster}-with-ip-${node_ip}":
    tag               => "dspace::application::node::in::cluster::${cluster}",
    listening_service => 'dspace-application-remote',
    server_names      => $hostname,
    ipaddresses       => $hostname,
    # lint:ignore:only_variable_string
    ports             => [ $application_proxy_port ],
    # lint:endignore
    options           => [
      'check inter 30000',
      'fastinter 2000',
      'downinter 15000',
      "cookie ${hostname}",
    ]
  }

  # Configure relation between application and database
  #

  # Configure local-to-remote haproxy listener
  haproxy::listen { 'dspace-database-remote':
    collect_exported => false,
    mode             => 'tcp',
    ipaddress        => '127.0.0.1',
    # lint:ignore:only_variable_string
    ports            => [ $database_port ],
    # lint:endignore
    options          => {
      'option'          => [
        'tcp-check',
        'log-health-checks',
        'tcplog',
      ],
      'log'             => 'global',
      'balance'         => 'leastconn',
      'timeout connect' => '5s',
      'timeout client'  => '10m',
      'timeout server'  => '10m',
    }
  }

  notify {"This node lives in cluster ${cluster}":
    withpath => true,
  }

  # Collect and configure remote haproxy balancer members
  Haproxy::Balancermember <<| tag == "dspace::database::node::in::cluster::${cluster}" |>>

  # Configure relation between application and index
  #

  # Configure local-to-remote haproxy listener
  haproxy::listen { 'dspace-index-remote':
    collect_exported => false,
    mode             => 'tcp',
    ipaddress        => '127.0.0.1',
    # lint:ignore:only_variable_string
    ports            => [ $index_port ],
    # lint:endignore
    options          => {
      'option'          => [
        'tcp-check',
        'log-health-checks',
        'tcplog',
      ],
      'log'             => 'global',
      'balance'         => 'leastconn',
      'timeout connect' => '5s',
      'timeout client'  => '10m',
      'timeout server'  => '10m',
    }
  }

  # Collect and configure remote haproxy balancer members
  Haproxy::Balancermember <<| tag == "dspace::index::node::in::cluster::${cluster}" |>>

  # Configure relation between
  # - portal and application,
  # - application and database,
  # - application and index
  # in terms of firewall rules
  #

  # Configure and export remote firewall rules
  @@firewall { "0 dspace-application-node-in-cluster-${cluster}-with-ip-${node_ip}":
    tag    => "dspace::application::node::in::cluster::${cluster}",
    action => 'accept',
    source => $node_ip,
  }

  # Collect and configure remote firewall rules
  Firewall <<| tag == "dspace::portal::node::in::cluster::${cluster}" |>> {
    destination => $node_ip,
    proto       => 'tcp',
    dport       => $application_proxy_port,
  }

}