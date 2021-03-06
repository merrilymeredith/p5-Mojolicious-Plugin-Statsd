# NAME

Mojolicious::Plugin::Statsd - Emit to Statsd, easy!

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
    my $jobstats = $app->stats->with_prefix('my-special-process.');

    # This becomes myapp.my-special-process.foo
    $jobstats->increment('foo');

# DESCRIPTION

Mojolicious::Plugin::Statsd is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin which adds a helper for
throwing your metrics at statsd.

# INHERITANCE

Mojolicious::Plugin::Statsd
  is a [Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin)

# OPTIONS

Mojolicious::Plugin::Statsd supports the following options.

## adapter

    # Mojolicious::Lite
    plugin Statsd => {adapter => 'Memory'};

The tail-end of a classname in the `Mojolicious::Plugin::Statsd::Adapter::`
namespace, or an object instance to be used as the adapter.

Defaults to `Statsd`, which itself defaults to emit to UDP `localhost:8125`.

Bundled adapters are listed in ["SEE ALSO"](#see-also).  Adapters MUST implement
`counter` and `timing`.

## prefix

    # Mojolicious::Lite
    plugin Statsd => {prefix => 'whatever.'};

A prefix applied to all recorded metrics. This a simple string concatenation,
so if you want to namespace, add the trailing . character yourself.  It
defaults to your `$app->moniker`, followed by `.`.

## helper

    # Mojolicious::Lite
    plugin Statsd => {helper => 'statistics'};

The helper name to be installed. Defaults to 'stats'

# ADDITIONAL OPTIONS

Any further options are passed to the ["adapter"](#adapter) during construction, unless
you've passed an object already.  Refer to the adapter documentation for
supported options.

# ATTRIBUTES

[Mojolicious::Plugin::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd) has the following attributes, which are best
configured through the plugin options above.

# adapter

The statsd adapter in use.

# prefix

The current prefix to apply to metric names.

# METHODS

## register

    $plugin->register(Mojolicious->new);
    $plugin->register(Mojolicious->new, {prefix => 'foo'});

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application. The optional second argument is
a hashref of ["OPTIONS"](#options).

## with\_prefix

    my $new = $stats->with_prefix('baz.');

Returns a new instance with the given prefix appended to our own prefix, for
scoped recording.

## counter

    $stats->counter('foo', 1);
    $stats->counter('bar', 1, 0.5);

Record a change to a counter.

## increment

    $stats->increment($name, $sample_rate);

Shortcut for ["counter"](#counter).

## decrement

    $stats->decrement($name, $sample_rate);

Shortcut for ["counter"](#counter).

## timing

    $stats->timing('foo', 2500, 0.5);
    $stats->timing(foo => 0.5, sub { });
    $stats->timing(foo => sub { });

Record timing.

## gauge

    $stats->gauge(xyzzy => 76);
    $stats->gauge(xyzzy => '+25');
    $stats->gauge(xyzzy => -25);

Send a gauge update.  Some receiving servers accept sending a signed value
rather than an absolute value, and this is supported.  Note that on those
servers, in order to reach a negative value, you must update to 0 first.

## set\_add

    $stats->set_add(things => 42);
    $stats->set_add(primes => 1, 3, 5, 7);

Add one or more values to a set.

# NAMES

In any place a metric name is specified, it can be substituted with an arrayref
in order to update several metrics in a single packet, provided your server
supports it.

# EXAMPLE

    use Mojolicious::Lite;
    plugin 'Statsd';

    hook after_dispatch => sub {
      my ($c) = @_;
      $c->stats->increment('path.' . $c->req->url->path);
    };

    #...

    app->start;

# SEE ALSO

[Mojolicious::Plugin::Statsd::Adapter::Statsd](https://metacpan.org/pod/Mojolicious::Plugin::Statsd::Adapter::Statsd), [Mojolicious::Plugin::Statsd::Adapter::Memory](https://metacpan.org/pod/Mojolicious::Plugin::Statsd::Adapter::Memory).

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides)

# LICENSE

This software is licensed under the same terms as Perl itself.
