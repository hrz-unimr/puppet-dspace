# Type: dspace::index::node
#
# @summary Installs and configures a dspace index node in a dspace cluster.
#
# @param cluster
#  Name of cluster in which the node lives.
# @param host
#  Host IP address.
# @param hostname
#  Host name
# @param index_port
#  Port of index server.
# @param index_proxy_port
#  Proxy port for index server.
#
class dspace::index::node (
  String $cluster           = 'default',
  String $host              = $::facts['networking']['ip'],
  String $hostname          = $::fqdn,
  Integer $index_port       = $dspace::index::server::port,
  Integer $index_proxy_port = $index_port,
) {

  $node_ip = $host ? {
    'localhost'   => '127.0.0.1',
    '*'           => '0.0.0.0',
    default       => $host,
  }

  include ::haproxy

  # Communication from index perspective
  #
  # Application (n) <-> Index (1)
  #

  # Configure relation between application and index
  #

  # Configure local remote-to-local haproxy listener
  haproxy::listen { 'dspace-index-local':
    collect_exported => false,
    mode             => 'tcp',
    ipaddress        => $node_ip,
    # lint:ignore:only_variable_string
    ports            => [ $index_proxy_port ],
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
  haproxy::balancermember { "dspace-index-node-in-cluster-${cluster}":
    listening_service => 'dspace-index-local',
    server_names      => '127.0.0.1',
    ipaddresses       => '127.0.0.1',
    ports             => [ $index_port ],
    options           => [
      'check inter 30000',
      'fastinter 2000',
      'downinter 15000',
    ]
  }

  # Configure and export remote haproxy balancer member
  @@haproxy::balancermember { "dspace-index-node-in-cluster-${cluster}-with-ip-${node_ip}":
    tag               => "dspace::index::node::in::cluster::${cluster}",
    listening_service => 'dspace-index-remote',
    server_names      => $hostname,
    ipaddresses       => $hostname,
    ports             => [ $index_proxy_port ],
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
    dport       => $index_proxy_port,
  }

}