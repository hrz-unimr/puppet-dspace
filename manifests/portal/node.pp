# Type: dspace::portal::node
#
# @summary: Installs and configures a dspace portal node in a dspace cluster.
#
# @param cluster
#  Name of cluster in which the node lives.
# @param host
#  Host IP address.
# @param hostname
#  Host name.
# @param application_port
#  Port of DSpace application server.
#
class dspace::portal::node (
  String $cluster           = 'default',
  String $host              = $::facts['networking']['ip'],
  String $hostname          = $::fqdn,
  Integer $application_port = $dspace::portal::server::application_port,
) {

  $node_ip = $host ? {
    'localhost'   => '127.0.0.1',
    '*'           => '0.0.0.0',
    default       => $host,
  }

  include ::haproxy

  # Communication from portal perspective
  #
  # Portal (1) <-> Application (n)
  #

  # Configure relation between portal and application
  #

  # Configure local haproxy listener
  haproxy::listen { 'dspace-application-remote':
    # Since we need access to HTTP header fields,
    # we use HTTP mode
    collect_exported => false,
    mode             => 'http',
    ipaddress        => '127.0.0.1',
    # lint:ignore:only_variable_string
    ports            => [ $application_port ],
    # lint:endignore
    options          => {
      'option'          => [
        'httpchk',
        'log-health-checks',
        # Since we don't want to log HTTP content for security reasons,
        # we use TCP logging
        'tcplog',
      ],
      'http-check'      => 'expect rstatus (2|3)[0-9][0-9]',
      'log'             => 'global',
      # Since we balance mostly long-living connections,
      # and since we have workers with differing hardware configurations,
      # we use leastconn balancing algorithm
      'balance'         => 'leastconn',
      'timeout connect' => '5000',
      'timeout client'  => '360000',
      'timeout server'  => '360000',
      'http-response'   => 'set-header X-DSpace-Worker %s',
      'cookie'          => 'JSESSIONID prefix nocache',
    }
  }

  notify {"This node lives in cluster ${cluster}":
    withpath => true,
  }

  # Collect and configure remote haproxy balancer members
  Haproxy::Balancermember <<| tag == "dspace::application::node::in::cluster::${cluster}" |>>

  # Configure and export remote firewall rule
  @@firewall { "0 dspace-portal-node-in-cluster-${cluster}-with-ip-${node_ip}":
    tag    => "dspace::portal::node::in::cluster::${cluster}",
    action => 'accept',
    source => $node_ip,
  }

  firewall { '0 dspace':
    action => 'accept',
    proto  => 'tcp',
    dport  => $dspace::portal::server::port,
  }

}