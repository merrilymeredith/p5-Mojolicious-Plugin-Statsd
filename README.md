# NAME

Mojolicious::Plugin::Statsd

# VERSION

version 0.001

# SYNOPSIS

    # Mojolicious
    $self->plugin('Statsd');

    # Mojolicious::Lite
    plugin 'Statsd';

    # Anywhere you have Mojo helpers available
    $app->stats->increment('frobs.adjusted');

    # It's safe to pass around if need be
    my $stats = $app->stats;

    # Only sample half of the time
    $stats->increment('frobs.discarded', 0.5);

    # Time a code section
    $stats->timing('frobnicate' => sub {
      # section to be timed
    });

    # Or do it yourself
    $stats->timing('frobnicate', $milliseconds);

    # Save repetition
    my $jobstats = $app->stats->add_prefix('my-special-process.');

    # This becomes myapp.my-special-process.foo
    $jobstats->increment('foo');

# DESCRIPTION

[Mojolicious::Plugin::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin.

# NAME

Mojolicious::Plugin::Statsd - Emit to Statsd, easy!

# OPTIONS

[Mojolicious::Plugin::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd) supports the following options.

## helper

    # Mojolicious::Lite
    plugin Statsd => { helper => 'statistics' };

An alternate helper name to be installed. Defaults to 'stats'

## prefix

    # Mojolicious::Lite
    plugin Statsd => { prefix => 'whatever.' };

A prefix applied to all recorded metrics. This a simple string concatenation,
so if you want to namespace, add the . character yourself.

## adapter

    # Mojolicious::Lite
    plugin Statsd => { adapter => 'Memory' };

The tail-end of a classname in the `Mojolicious::Plugin::Statsd::Adapter::`
namespace, or an object instance to be used as the adapter.

# ADDITIONAL OPTIONS

All Statsd options are passed to the [adapter](https://metacpan.org/pod/adapter), which may accept additional
options such as `host` and `port`.  Refer to the adapter documentation.

# ATTRIBUTES

[Mojolicious::Plugin::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd) has the following attributes, which are best
configured through the plugin options above.

# adapter

The statsd adapter in use.

# prefix

The current prefix to apply to metric names.

# METHODS

[Mojolicious::Plugin::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);
    $plugin->register(Mojolicious->new, { prefix => 'foo' });

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application. The optional second argument is
passed directly to ["configure"](#configure).  Register does two additional things with the
options hashref:

- prefix

    If no prefix is yet defined, sets a prefix based on the application moniker,
    followed by a `.`.

- helper

    A helper with the name provided, or `stats`, is installed in the application,
    returning this instance of the plugin object.

## add\_prefix

    my $new = $stats->add_prefix('baz.');

Returns a new instance with the given prefix appended to our own prefix.

## copy

    my $new = $stats->copy( prefix => '' );

Returns a new instance with the same configuration, overridden by any
additional arguments provided.

## configure

    my $stats = $app->stats->configure({ adapter => 'Statsd', host => $host });

Applies configuration as provided to [register](https://metacpan.org/pod/register) to the current object
instance.  Always expects a hashref, accepts anything in ["OPTIONS"](#options) above,
except for `helper`, as well as any ["ADDITIONAL OPTIONS"](#additional-options).

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).

# LICENSE

This software is licensed under the same terms as Perl itself.

# AUTHOR

Meredith Howard <mhoward@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
