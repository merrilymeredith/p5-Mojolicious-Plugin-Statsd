package Mojolicious::Plugin::Statsd::Adapter::Statsd;

use Mojo::Base -base;

use IO::Socket::INET ();

has socket => sub {
  my $self = shift;

  IO::Socket::INET->new(
    Proto    => 'udp',
    PeerAddr => $self->addr,
    Blocking => 0,
  ) or die "Can't open write socket for stats: $@";
};

has addr => sub {
  $ENV{STATSD_ADDR} // '127.0.0.1:8125';
};

# FIXME: Need to add @rate

sub timing {
  my ($self, $names, $time, $sample_rate) = @_;

  if (($sample_rate // 1) != 1) {
    return unless rand() <= $sample_rate;
  }

  my $payload = join(
    "\x0a",
    map { sprintf('%s:%d|ms', $_, $time) } @$names
  );

  ($self->socket->send($payload) // -1) == length($payload)
    or warn "stats: UDP packet may have been truncated ($!)";

  return 1;
}

sub counter {
  my ($self, $counters, $delta, $sample_rate) = @_;

  if (($sample_rate // 1) != 1) {
    return unless rand() <= $sample_rate;
  }

  my $payload = join(
    "\x0a",
    map { sprintf('%s:%d|c', $_, $delta) } @$counters
  );

  ($self->socket->send($payload) // -1) == length($payload)
    or warn "stats: UDP packet may have been truncated ($!)";

  return 1;
}

1;
