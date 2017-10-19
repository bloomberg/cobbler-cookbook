cobbler-cookbook
================

Installs and configures [Cobbler][1] and Cobbler Web.

## Supported Platforms
- CentOS 6.5, 5.10
- Ubuntu 12.04, 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cobbler']['root_password']</tt></td>
    <td>String</td>
    <td>Root password for Kickstart templates.</td>
    <td><tt>`echo 'root' | shasum -a 512 -p`</tt></td>
  </tr>
  <tr>
    <td><tt>['cobbler']['user']['password']</tt></td>
    <td>String</td>
    <td>Root password for Kickstart templates.</td>
    <td><tt>`echo 'cloud' | shasum -a 512 -p`</tt></td>
  </tr>
  <tr>
    <td><tt>['cobbler']['user']['name']</tt></td>
    <td>String</td>
    <td>UNIX username</td>
    <td><tt>cloud</tt></td>
  </tr>
  <tr>
    <td><tt>['cobbler']['user']['uid']</tt></td>
    <td>Integer</td>
    <td>UNIX uid</td>
    <td><tt>900</tt></td>
  </tr>
</table>

## Usage

### cobbler::default

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::default]"
  ]
}
```

This installs Cobbler on your machine

### cobbler::source

Include `cobblerd::source` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::default]"
  ]
}
```

This builds Cobbler from source code

### cobbler::web

Include `cobblerd::web` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::web]"
  ]
}
```

This provides the Cobbler web interface

### cobbler::centos

Include `cobblerd::centos` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::centos]"
  ]
}
```

This provides a CentOS image via Cobbler

### cobbler::ubuntu

Include `cobblerd::ubuntu` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::ubuntu]"
  ]
}
```

This provides an Ubuntu image via Cobbler

## Maintainers

Author:: [Bloomberg Compute Architecture Group][2] (<compute@bloomberg.net>)

### Maintainers

To build and test, one can run the following (this done using ChefDK binaries):
* `bundler package`
* `kitchen verify '.*'`

[1]: http://www.cobblerd.org
[2]: http://www.bloomberglabs.com/compute-architecture/
