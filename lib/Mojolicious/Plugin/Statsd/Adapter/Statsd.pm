package Mojolicious::Plugin::Statsd::Adapter::Statsd;
use Mojo::Base 'Mojolicious::Plugin::Statsd::Adapter';

use Mojo::Collection 'c';

has socket => sub {
  IO::Socket->new(
    Proto    => 'udp',
    PeerAddr => '127.0.0.1',
    PeerPort => 8125,
    Blocking => 0,
  );
};

# FIXME:
#  -socket config
#  -etsy statsd allows multi-metric packets separated by \n
#  -no check on socket open or send truncate

sub timing {
  my $self = shift;
  my ( $names, $time, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  for my $name ( @$names ){
    $self->socket->send( sprintf( '%s:%d|ms', $name, $time ) );
  }
  return 1;
}

sub update_stats {
  my $self = shift;
  my ( $counters, $delta, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  for my $counter ( @$counters ){
    $self->socket->send( sprintf('%s:%d|c', $counter, $delta) );
  }
  return 1;
}

1;
