cobbler-cookbook
================
Installs and configures [Cobbler][1].

## Supported Platforms
- CentOS 6.5
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
    <td><tt>['cobbler-cookbook']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### cobbler-cookbook::default

Include `cobbler-cookbook` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cobbler-cookbook::default]"
  ]
}
```

## License and Authors

Author:: John Bellone (<jbellone@bloomberg.net>) (<jbellone@bloomberg.net>)
