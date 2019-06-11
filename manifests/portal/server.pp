# Class: dspace::portal::server
#
# @summary Installs and configures the dspace portal server as load balancer for horizontal scaling, high-availability and
# maintainability.
#
# @param host
#  Hostname of web server
# @param port
#  Used HTTP-Port.
# @param ssl
#  Enable SSL-Support.
# @param ssl_key
#  Path to SSL-Key file.
# @param ssl_cert
#  Path to SSL-Certifacte file.
# @param application_host
#  Hostname of DSpace application
# @param application_port
#  Port of DSpace application
# @param no_proxy_paths
#  Paths and Files that should not be handled by proxy.
# @param maintenance_ips
#  IP-Addresses which can access DSpace application, if maintenance site is enabled.
# @param restrict_metadata_url
#  Restrict access to _[dspace-url]/metadata/..._ (XMLUI only).
#
class dspace::portal::server (
  String $host                   = 'localhost',
  Integer $port                  = 443,
  Boolean $ssl                   = true,
  String $ssl_key                = '/etc/ssl/private/portal.key',
  String $ssl_cert               = '/etc/ssl/certs/portal.pem',
  String $application_host       = 'localhost',
  Integer $application_port      = 8080,
  Array $no_proxy_paths          = [],
  Array $maintenance_ips         = [],
  Boolean $restrict_metadata_url = false
) {

  $listen_ip = $host ? {
    'localhost' => '127.0.0.1',
    '*'         => '0.0.0.0',
    default     => $host,
  }

  # Set rewrite rule to maintenance site, if enabled
  if 'maintenance' in $no_proxy_paths and $maintenance_ips != [] {
    # Set up remote address lines
    $remote_addr = inline_template('<%=@maintenance_ips.map {|ip| "%{REMOTE_ADDR} !^"+ip}.join(",")%>')
    # Set up rewrite onditions
    $rewrite_cond = [
      each($remote_addr.split(',')) |$addr| { $addr },
      '%{DOCUMENT_ROOT}/maintenance.html -f',
      '%{DOCUMENT_ROOT}/maintenance.enable -f',
      '%{SCRIPT_FILENAME} !maintenance.html'
    ]
    # Rewrites
    $rewrites = [{
        rewrite_cond => $rewrite_cond,
        rewrite_rule => ['^.*$ /maintenance.html']
    }]
  } else { $rewrites = undef }

  # Set directory for docroot
  $docroot = { 'path' => '/var/www/html', 'provider' => 'directory',
    'allow_override'  => ['None'],
    'options'         => ['Indexes', 'FollowSymLinks', 'Multiviews']
  }

  # Set location for /metadata (XMLUI)
  # Allow access only to local host.
  if $restrict_metadata_url {
    $closed = { 'path' => '/metadata', 'provider' => 'location',
      'require' => ['local'] }
  } else { $closed = {'path' => '/metadata'} }

  file { $ssl_key:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  file { $ssl_cert:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  class { 'apache':
    default_vhost          => false,
    timeout                => 360,
    keepalive              => 'On',
    keepalive_timeout      => 60,
    max_keepalive_requests => 100,
  }

  class { 'apache::mod::ssl':

  }

  apache::vhost { 'portal':
    ip            => $listen_ip,
    port          => $port,
    vhost_name    => '*',
    servername    => $::fqdn,
    serveraliases => '*',
    docroot       => '/var/www/html',
    ssl           => $ssl,
    ssl_key       => $ssl_key,
    ssl_cert      => $ssl_cert,
    proxy_pass    => [{
      'path'          => '/',
      'url'           => "http://${application_host}:${application_port}/",
      'no_proxy_uris' => $no_proxy_paths
    }],
    directories   => [$docroot, $closed],
    rewrites      => $rewrites,
  }

  apache::vhost { 'portal non-ssl':
    ip            => $listen_ip,
    port          => 80,
    vhost_name    => '*',
    servername    => $::fqdn,
    serveraliases => '*',
    docroot       => '/var/www/html',
    ssl           => false,
    rewrites      => [
      {
        rewrite_rule => ['^ https://%{SERVER_NAME}%{REQUEST_URI} [END,QSA,R=permanent]'],
      },
    ],
  }
}