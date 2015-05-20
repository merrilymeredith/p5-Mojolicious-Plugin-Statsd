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
  my ( $name, $time, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  c( $name )->flatten->each(sub {
    $self->socket->send( sprintf( '%s|ms:%d', shift, $time ) );
  });
}

sub update_stats {
  my $self = shift;
  my ( $counter, $delta, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  c( $counter )->flatten->each(sub {
    $self->socket->send( sprintf('%s|c:%d', shift, $delta) );
  });
}

1;
