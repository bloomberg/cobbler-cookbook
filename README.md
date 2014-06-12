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
    <td><tt>['cobbler']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
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

## Maintainers

Author:: [John Bellone][2] [@johnbellone][3] (<jbellone@bloomberg.net>)

[1]: http://www.cobblerd.org
[2]: https://github.com/johnbellone
[3]: https://twitter.com/johnbellone
