package Mojolicious::Plugin::Statsd::Adapter::Statsd;
use Mojo::Base 'Mojolicious::Plugin::Statsd::Adapter';

use Carp 'carp';
use IO::Socket::INET;

has socket => sub {
  my $self = shift;

  IO::Socket::INET->new(
    Proto    => 'udp',
    PeerAddr => $self->host,
    PeerPort => $self->port,
    Blocking => 0,
  );
};

# FIXME:
#  -socket config
#  -no check on socket open

has host => sub {
  $ENV{MOJO_STATSD_HOST} // '127.0.0.1';
};

has port => sub {
  $ENV{MOJO_STATSD_PORT} // 8125;
};

sub timing {
  my $self = shift;
  my ( $names, $time, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  my $payload = join("\x0a",
    map { sprintf('%s:%d|ms', $_, $time) } @$names
  );

  $self->socket->send( $payload ) == length($payload)
    or carp "stats: UDP packet may have been truncated";

  return 1;
}

sub update_stats {
  my $self = shift;
  my ( $counters, $delta, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  my $payload = join("\x0a",
    map { sprintf('%s:%d|c', $_, $delta) } @$counters
  );

  $self->socket->send( $payload ) == length($payload)
    or carp "stats: UDP packet may have been truncated";

  return 1;
}

1;
