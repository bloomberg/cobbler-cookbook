cobbler-cookbook
================

Installs and configures [Cobbler][1] and Cobbler Web.

## Supported Platforms
- CentOS 6.5, 5.10
- Ubuntu 12.04, 14.04

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

### cobbler::apache

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::web]"
  ]
}
```

### cobbler::nginx

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::centos]"
  ]
}
```

### cobbler::repos

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::ubuntu]"
  ]
}
```

### cobbler::server

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::ubuntu]"
  ]
}
```

### cobbler::uwsgi

Include `cobblerd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobblerd::ubuntu]"
  ]
}
```

## Maintainers

Author:: [Bloomberg Compute Architecture Group][2] (<compute@bloomberg.net>)

### Maintainers

To build and test, one can run the following (this done using ChefDK binaries):
* `bundler package`
* `kitchen verify '.*'`

[1]: http://www.cobblerd.org
[2]: http://www.bloomberglabs.com/compute-architecture/
