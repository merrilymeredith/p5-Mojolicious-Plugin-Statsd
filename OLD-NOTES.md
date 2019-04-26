
# Mojolicious::Plugin::Statsd

This is work in progress for a Statsd plugin, with plans for easy optional
hooks to record stats and timings for the usual cases.

The following are some work notes for myself.

### Statsd adapter

UDP only, nonblocking mode, fire/mostly forget.

Following protocol linked by etsy/statsd.

### Hooks

- full request timing
 - counters for :
  - hits on routes by name + http verb
  - status codes returned by those

### Test against a real statsd

1. if we have node and git
2. clone statsd at a tag
3. random udp port, basic check that it's not used
4. generate a config file
5. start statsd
6. configure adapter
7. fire tests at it
8. check that all landed on statsd somehow??
9. shut down statsd/node, wipe cloned dir

