package Mojolicious::Plugin::Statsd;

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Loader;
use Time::HiRes qw(gettimeofday tv_interval);

has adapter => undef;
has prefix  => '';

sub register {
  my ($self, $app, $conf) = @_;

  $self->_load_adapter(($conf->{adapter} // 'Statsd'), $conf);

  $self->{prefix} = $conf->{prefix} // $app->moniker . q[.];

  $app->helper(($conf->{helper} // 'stats') => sub {$self});
}

sub _load_adapter {
  my ($self, $adapter, $conf) = @_;

  return $self->adapter($adapter) if ref $adapter;

  my $class = sprintf('%s::Adapter::%s', ref $self, $adapter);
  my $err = Mojo::Loader::load_class $class;

  if (ref $err) {
    die "Loading adapter $class failed: $err";
  }

  $self->adapter($class->new(%$conf));
}

sub copy {
  my ($self, @args) = @_;

  return (ref $self)->new(%$self, @args);
}

sub add_prefix {
  my ($self, $add_prefix) = @_;

  my $copy = $self->copy;
  $copy->prefix($self->prefix . $add_prefix);
  return $copy;
}

sub update_stats {
  my ($self, $name, @args) = @_;

  $self->adapter->update_stats($self->_prepare_names($name), @args);
}

sub increment {
  (shift)->update_stats(shift, 1, shift);
}

sub decrement {
  (shift)->update_stats(shift, -1, shift);
}

#
# $stats->timing( 'foo', 2500, 1 );
# $stats->timing( foo => 1, sub { } );
# $stats->timing( foo => sub { } );
# Keep the code ref at the end.
sub timing {
  my ($self, $name, @args) = @_;

  my ($time, $sample_rate) = ref $args[1] ? reverse(@args) : @args;

  if (ref $time eq 'CODE') {
    my @start = gettimeofday();
    $time->();
    $time = int(tv_interval(\@start) * 1000);
  }

  $self->adapter->timing($self->_prepare_names($name), $time, $sample_rate);
}

sub _prepare_names {
  my ($self, $names) = @_;

  return [map { $self->prefix . $_ } ref($names) ? @$names : $names];
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Statsd - Emit to Statsd, easy!

=head1 SYNOPSIS

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


=head1 DESCRIPTION

Mojolicious::Plugin::Statsd is a L<Mojolicious> plugin which adds a helper for
throwing your metrics at statsd.

=head1 INHERITANCE

Mojolicious::Plugin::Statsd
  is a L<Mojolicious::Plugin>

=head1 OPTIONS

Mojolicious::Plugin::Statsd supports the following options.

=head2 adapter

   # Mojolicious::Lite
   plugin Statsd => { adapter => 'Memory' };

The tail-end of a classname in the C<Mojolicious::Plugin::Statsd::Adapter::>
namespace, or an object instance to be used as the adapter.

Defaults to C<Statsd>, which itself defaults to emit to UDP C<localhost:8125>.

Bundled adapters are listed in L</SEE ALSO>.  Adapters MUST implement
C<update_stats> and C<timing>.

=head2 prefix

   # Mojolicious::Lite
   plugin Statsd => { prefix => 'whatever.' };

A prefix applied to all recorded metrics. This a simple string concatenation,
so if you want to namespace, add the trailing . character yourself.  It
defaults to your C<< $app->moniker >>, followed by C<.>.

=head2 helper

   # Mojolicious::Lite
   plugin Statsd => { helper => 'statistics' };

The helper name to be installed. Defaults to 'stats'

=head1 ADDITIONAL OPTIONS

Any further options are passed to the L</adapter> during construction, unless
you've passed an object already.  Refer to the adapter documentation for
supported options.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::Statsd> has the following attributes, which are best
configured through the plugin options above.

=head1 adapter

The statsd adapter in use.

=head1 prefix

The current prefix to apply to metric names.

=head1 METHODS

=head2 register

  $plugin->register(Mojolicious->new);
  $plugin->register(Mojolicious->new, { prefix => 'foo' });

Register plugin in L<Mojolicious> application. The optional second argument is
a hashref of L</OPTIONS>.

=head2 add_prefix

  my $new = $stats->add_prefix('baz.');

Returns a new instance with the given prefix appended to our own prefix.

=head2 copy

  my $new = $stats->copy( prefix => '' );

Returns a new instance with the same configuration, overridden by any
additional arguments provided.

=head1 SEE ALSO

L<Mojolicious::Plugin::Statsd::Adapter::Statsd>, L<Mojolicious::Plugin::Statsd::Adapter::Memory>.

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=head1 LICENSE

This software is licensed under the same terms as Perl itself.

=cut
