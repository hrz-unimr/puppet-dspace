# DSpace

#### Table of Contents

1. [Overview](#overview)
1. [Module description - What the module does and why it is useful](#description)
1. [Setup - The basics of getting started](#setup)
    * [Setup requirements](#requirements)
    * [Beginning with this module](#beginning)
1. [Usage - Configuration options and addition functionality](#usage)
    * [System and DSpace configuration](#system-and-dspace-configuration)
        * [Authentication](#authentication)
        * [DOI Registration via DataCite](#doi-registration-via-datacite)
        * [Item Versioning](#item-versioning)
        * [Maintenance jobs](#maintenance-jobs)
        * [Manage custom command line tools](#manage-custom-command-line-tools)
        * [Managed options](#managed-options)
        * [Modularisation](#modularisation)
        * [Proxy](#proxy)
        * [Separated DSpace directories](#separated-dspace-directories)
    * [Node configuration](#node-configuration)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)   
1. [Limitations - OS compatibility, etc.](#limitations)

### Overview

The DSpace module lets you use Puppet to install and configure a DSpace 
instance with all its components (web, database, index and application
server).

### Module description

DSpace is a Java web application. The DSpace module lets you use Puppet to 
install DSpace and manage its configuration files. It supports to install a 
DSpace instance with all components on one virtual machine or in a cluster.

### Setup

#### Requirements

The DSpace module requires:
* [puppetlabs-apache](https://forge.puppetlabs.com/puppetlabs/apache) version 3.0.0 or newer
* [puppetlabs-haproxy](https://forge.puppetlabs.com/puppetlabs/haproxy) version 2.1.0 or newer
* [puppetlabs-postgresql](https://forge.puppetlabs.com/puppetlabs/postgresql) version 5.2.1 or newer
* [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version 4.25.1 or newer
* [puppetlabs-tomcat](https://forge.puppetlabs.com/puppetlabs/tomcat) version 2.1.0 or newer
* [puppetlabs-vcsrepo](https://forge.puppetlabs.com/puppetlabs/vcsrepo) version 2.2.0 or newer

#### Beginning

The simplest way to get a DSpace instance with all its components is to install
all components and configure the basics in the _configuration_ class.

```ruby

# Setup basic configuration

class { 'dspace::configuration':
    database_name   => 'name of youre database',
    database_user   => 'name of the database user',
    database_passwd => 'database user password',
}

# Setup web server

class { 'dspace::portal::server':
    host => '0.0.0.0',
}

# Setup database server

class { 'dspace::database::server':

}

# Setup application server

class { 'dspace::application::source':

}

class { 'dspace::application::server':

}

# Setup index server

class { 'dspace::index::source':

}

class { 'dspace::index::server':

}
```

### Usage

#### System and DSpace configuration

The basic system and DSpace configuration is held in `dspace::configuration`.
The most of the configuration in *local.cfg* is parameterized in this class. In
some cases additional keys are implemented to cover a functionality. Also a 
path to a additional configuration file with customized configuration can be 
added by the parameter `own_configuration`.

##### Authentication 

This module supports authentication configuration. To enable configure selected 
[methods](https://wiki.duraspace.org/display/DSDOC6x/Authentication+Plugins)
in one String separated with commas.

```ruby
class { 'dspace::configuration':
    authentication_method => 'org.dspace.authenticate.PasswordAuthentication, org.dspace.authenticate.ShibAuthentication'
}
```

For LDAP and Shibboleth authentication this module implements a basic 
configuration in [local.cfg](templates/config/local.cfg.erb).

##### DOI Registration via DataCite

This module supports the DSpace [DOI Configuration](https://wiki.duraspace.org/display/DSDOC6x/DOI+Digital+Object+Identifier)
. Currently only DataCite is available. The three necessary configuration files 
([local.cfg](templates/config/local.cfg.erb), [DIM2DataCite.xsl](templates/config/DIM2DataCite.xsl.erb)
, [identifier-service.xml](templates/config/identifier-service.xml)) are managed 
as templates. All parameter are located in the [configuration class](manifests/configuration.pp).

##### Item Versioning
This module supports item versioning which is not activated per default. It is
configurable via `dspace::configuration::item_versioning`.

##### Maintenance jobs

This module supports the DSpace maintenance per various cron jobs. **Important:** 
You have to configure your email and database settings properly before use it.

For the `filter-media` job the [plugins](https://wiki.duraspace.org/display/DSDOC6x/Mediafilters+for+Transforming+DSpace+Content)
are configurable. Per default all plugins are used. Selected plugins can be 
configured as Array:
```ruby
# Only filter text, no thumbnails
class { 'dspace::server::cron':
    media_filter_plugins => [PDF Text Extractor,HTML Text Extractor,Word Text Extractor]
}
```

##### Manage custom command line tools

If you write customized command line tools for DSpace, you have to start them
via DSpace [launcher](https://wiki.duraspace.org/display/DSDOC6x/Application+Layer#ApplicationLayer-DSpaceCommandLauncher)
and configure in *launcher.xml*. This module supports the launcher configuration.

```ruby
class { 'dspace::configuration':
    dspace_launcher_commands => [
        {
            "name":"metadata-archive-export",
            "description":"Export UUIDs and last modification dates of all items.",
            "class":"org.dspace.app.bulkedit.MetadataArchiveExport"
        },
        {
            "name":"group-builder",
            "description":"Build/update DSpace group structure.",
            "class":"org.dspace.administer.GroupBuilder"
        }
    ]
}
```

The configured hashs are implemented in the [*launcher.xml* template](templates/config/launcher.xml.erb).

##### Managed options

This module supports pre configured options for Java components: JVM, Tomcat,
Maven, Ant. These options are enabled per default. Additional options are 
configurable via `dspace::configuration`: `java_opts`, `maven_opts`, `ant_opts`
and `catalina_opts`.

##### Modularisation
This module supports a separated installation of default DSpace code and own 
customise code via separated Git repositories. Therefore the 
[overlay-mechanic](https://wiki.duraspace.org/display/DSDOC6x/Advanced+Customisation)
is used. 

```ruby
class { 'dspace::configuration':
    git_repository              => 'https://github.com/DSpace/DSpace.git',
    git_revision                => 'dspace-6.3',
    separated_code_repositories => true,
    dspace_custom_repository    => 'https://gitlab.myinstitution.edu/DSpace/custom.git',
    dspace_custom_revision      => 'master'
}
```

The second Git repository should only contents the `dspace`-directory with 
`config`, `modules`, `solr` directories. So it is not necassary to take care of 
the default DSpace source code.

##### Proxy

This module supports proxy configuration for every component of the DSpace 
instance - except the webserver. If all components use one proxy server it is
configurable via `dspace::configuration::system_proxy_url` which is default for
all components. Other proxy configuration parameter are:
* `dspace_proxy_url` for DSpace application
* `git_proxy_url` for Git
* `java_proxy_url` for JVM
* `maven_proxy_url` for Maven
* `ant_proxy_url` for Ant
* `tomcat_proxy_url` for Tomcat

##### Separated DSpace directories

This module supports to separate the DSpace instance directory from the data
directory, e.g. asset store. Per default the instance directory is also the 
data direcotry. If you use a shared directory, for example in a cluster setting,
you can configure a different path in `dspace::configuration::data_dir`. In which
the asset store is also located. The data directory also included all directories
which have to be shared in a cluster setting, like upload, export, tasks and 
OAI.

### Reference

See [REFERENCE.md](REFERENCE.md)

### Limitations

##### Tested Operating Systems

* Debian Stretch
* Debian Buster (Testing) 
* Ubuntu 16.04 LTS.

##### Tested DSpace Version

* 6.X

##### Tested web application server

Tomcat in version 8. Jetty is **not** supported.

##### Tested Databases

PostgreSQL in version 9.6 and 11. Oracle is **not** supported.

##### User Interface

At the moment this module supports only the XMLUI with Mirage 2 theme. Also many
configuration parameters belonging only to the XMLUI.  With small customizations
of the `dspace::application::server` class the JSPUI can also be installed. 

##### Multiple Instances

It is not possible to install more than one DSpace instance with this module.
There is only one central configuration for Java, Maven and Ant. So it is not
possible to configure several instances of one node class with different system
settings. But it is possible to install more than one instance of a node class
with the same configuration.



