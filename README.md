cobbler-cookbook
================

Installs and configures [Cobbler][1] and Cobbler Web.

## Supported Platforms
- CentOS 7.x
- RedHat Enterprise Linux 7.x
- Oracle Linux 7.x

## Usage

### cobbler::default
Installs Cobbler and (depending on the attribute values) either Apache or Nginx as the front end to Cobbler.

**NOTE**: Currently only Nginx is supported; pull requests to finish the Apaache integration are welcome.

Include `cobblerd` in your node's `run_list` (installs Nginx by default):

```json
{
  "run_list": [
    "recipe[cobblerd::default]"
  ]
}
```

Install Cobbler with Apache instead of Nginx:

```json
{
  "attributes": {
    "cobblerd": {
      "http_service_name": "nginx"
    }
  },
  "run_list": [
    "recipe[cobblerd::default]"
  ]
}
```

### cobbler::apache

To install and configure Apache as the front end to Cobbler, include `cobblerd::apache` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::apache]"
  ]
}
```

### cobbler::nginx

To install and configure Nginx as the front end to Cobbler, include `cobblerd::nginx` in your node's `run_list`:


```json
{
  "run_list": [
    "recipe[cobblerd::nginx]"
  ]
}
```

### cobbler::repos

To configure the repositories needed for each specific OS (Ubuntu, RedHat, etc), nclude `cobblerd::repos` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::repos]"
  ]
}
```

### cobbler::server

The main installation of the Cobbler services is performed by the `server` recipe; simply include `cobblerd::server` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::server]"
  ]
}
```

### cobbler::uwsgi

As part of proxying Cobbler with Nginx properly, UWSGI must be installed and configured properly. This recipe must be included after the `nginx` and after the `server` recipes as this recipe depends on packages, files, etc created by the Cobbler server install. Include `cobblerd::uwsgi` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::uwsgi]"
  ]
}
```

## Maintainers

Original Author:: [Bloomberg Compute Architecture Group][2] (<compute@bloomberg.net>)
Additional Author:: Justin Spies

###

To build and test, one can run the following (this done using ChefDK binaries):
* `bundler package`
* `kitchen verify '.*'`

[1]: http://www.cobblerd.org
[2]: http://www.bloomberglabs.com/compute-architecture/
