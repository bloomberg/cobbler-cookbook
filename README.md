cobbler-cookbook
================
![Release](http://img.shields.io/github/release/johnbellone/cobbler-cookbook.svg)
[![Build Status](http://img.shields.io/travis/johnbellone/cobbler-cookbook.svg)][4]
[![Code Coverage](http://img.shields.io/coveralls/johnbellone/cobbler-cookbook.svg)][5]

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

### cobbler::web

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::web]"
  ]
}
```

### cobbler::centos

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::centos]"
  ]
}
```

### cobbler::ubuntu

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::ubuntu]"
  ]
}
```

## Maintainers

Author:: [John Bellone][2] [@johnbellone][3] (<jbellone@bloomberg.net>)

[1]: http://www.cobblerd.org
[2]: https://github.com/johnbellone
[3]: https://twitter.com/johnbellone
[4]: http://travis-ci.org/johnbellone/cobbler-cookbook
[5]: https://coveralls.io/r/johnbellone/cobbler-cookbook
