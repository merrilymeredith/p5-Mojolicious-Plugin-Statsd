package Mojolicious::Plugin::Statsd;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader;

our $VERSION = '0.01';

use Mojolicious::Plugin::Statsd::Adapter::Memory;

has adapter => sub {
  Mojolicious::Plugin::Statsd::Adapter::Memory->new()
};

has prefix => sub { '' };

sub register {
  my ($self, $app, $conf) = @_;
  
  # $conf = {
  #   adapter => 'Statsd', (or ref?)
  #   host/port?
  #   prefix  => 'myapp.',
  # }

  $self->config($conf);

  $self->{prefix} //= $app->moniker .q[.];

  $app->helper( ($conf->{helper} // 'stats') => sub { return $self } );
}

sub config {
  my ( $self, $conf ) = @_;

  return $self->{config} if !$conf;

  $self->{config} = $conf;

  if ( exists $conf->{prefix} ){
    $self->{prefix} = $conf->{prefix};
  }

  if ( my $adapter = $conf->{adapter} ){
    $self->_load_adapter( $adapter );
  }
}

sub _load_adapter {
  my ( $self, $adapter ) = @_;

  return $self->adapter( $adapter ) if ref $adapter;

  my $class = sprintf('%s::Adapter::%s', ref $self, $adapter);
  my $err   = Mojo::Loader::load_class $class;

  if ( ref $err ){
    die "Loading adapter $class failed: $err";
  }

  $self->adapter( $class->new($self->{config}) );
}

sub copy {
  my ( $self, @args ) = @_;

  return (ref $self)->new(%$self, @args);
}

sub add_prefix {
  my ( $self, $add_prefix ) = @_;

  my $copy = $self->copy;
     $copy->prefix( $self->prefix . $add_prefix );
  return $copy;
}

sub update_stats {
  my ( $self, $name, @args ) = @_;

  $self->adapter->update_stats( $self->_prepare_names($name), @args );
}

sub increment {
  (shift)->update_stats( shift, 1, shift );
}

sub decrement {
  (shift)->update_stats( shift, -1, shift );
}

#
# $stats->timing( 'foo', 2500, 1 );
# $stats->timing( foo => 1, sub { } );
# $stats->timing( foo => sub { } );
#
sub timing {
  my ( $self, $name, $time, $sample_rate ) = @_;

  if ( ref $sample_rate ){
    ( $time, $sample_rate ) = ( $sample_rate, $time );
  }

  if ( ref $time eq 'CODE' ){
    my @start = gettimeofday();
    $time->();
    $time = int( tv_interval(\@start) * 1000 );
  }

  $self->adapter->timing( $self->_prepare_names($name), $time, $sample_rate );
}

sub _prepare_names {
  my ( $self, $names ) = @_;

  return [
    map { $self->prefix . $_ } ref($names) ? @$names : $names
  ];
}


1;
__END__

=encoding utf8

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

L<Mojolicious::Plugin::Statsd> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::Statsd> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
