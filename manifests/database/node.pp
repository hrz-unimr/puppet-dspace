# Type: dspace::database::node
#
# @summary Installs and configures a dspace database node in a dspace cluster.
#
# @param cluster
#  Name of cluster in which the node lives.
# @param host
#  Host IP address.
# @param hostname
#  Host name.
# @param database_port
#  Port of database server.
# @param database_proxy_port
#  Proxy port for database server.
#
class dspace::database::node (
  String $cluster              = 'default',
  String $host                 = $::facts['networking']['ip'],
  String $hostname             = $::fqdn,
  Integer $database_port       = $dspace::database::server::port,
  Integer $database_proxy_port = $database_port,
) {

  $node_ip = $host ? {
    'localhost'   => '127.0.0.1',
    '*'           => '0.0.0.0',
    default       => $host,
  }

  include ::haproxy

  # Communication from database perspective
  #
  # Application (n) <-> Database (1)
  #

  # Configure relation between application and database
  #

  # Configure local remote-to-local haproxy listener
  haproxy::listen { 'dspace-database-local':
    collect_exported => false,
    mode             => 'tcp',
    ipaddress        => $node_ip,
    # lint:ignore:only_variable_string
    ports            => [ $database_proxy_port ],
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

  # Configure local haproxy balancer member
  haproxy::balancermember { "dspace-database-node-in-cluster-${cluster}":
    listening_service => 'dspace-database-local',
    server_names      => '127.0.0.1',
    ipaddresses       => '127.0.0.1',
    ports             => [ $database_port ],
    options           => [
      'check inter 30000',
      'fastinter 2000',
      'downinter 15000',
    ]
  }

  # Configure and export remote haproxy balancer member
  @@haproxy::balancermember { "dspace-database-node-in-cluster-${cluster}-with-ip-${node_ip}":
    tag               => "dspace::database::node::in::cluster::${cluster}",
    listening_service => 'dspace-database-remote',
    server_names      => $hostname,
    ipaddresses       => $hostname,
    ports             => [ $database_proxy_port ],
    options           => [
      'check inter 30000',
      'fastinter 2000',
      'downinter 15000',
    ]
  }

  # Collect and configure remote firewall rules
  Firewall <<| tag == "dspace::application::node::in::cluster::${cluster}" |>> {
    destination => $node_ip,
    proto       => 'tcp',
    dport       => $database_proxy_port,
  }

}