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

  if (($sample_rate //= 1) < 1) {
    return unless rand() <= $sample_rate;
  }

  $self->_send(
    map { $sample_rate < 1 ? "$_\@$sample_rate" : $_ }
    map { sprintf '%s:%d|ms', $_, $time }
    @$names
  );

  return 1;
}

sub counter {
  my ($self, $counters, $delta, $sample_rate) = @_;

  if (($sample_rate //= 1) < 1) {
    return unless rand() <= $sample_rate;
  }

  $self->_send(
     map { $sample_rate < 1 ? "$_\@$sample_rate" : $_ }
     map { sprintf '%s:%d|c', $_, $delta }
     @$counters
  );

  return 1;
}

sub _send {
  my ($self) = shift;
  my $payload = join("\012", @_);

  ($self->socket->send($payload) // -1) == length($payload)
    or warn "stats: UDP packet may have been truncated ($!)";
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Statsd::Adapter::Statsd - Statsd UDP recording

=head1 DESCRIPTION

This adapter for L<Mojolicious::Plugin::Statsd> sends stats immediately over
UDP to a statsd service.

=head1 INHERITANCE

Mojolicious::Plugin::Statsd::Adapter::Statsd
  is a L<Mojo::Base>

=head1 ATTRIBUTES

=head2 addr

The statsd service address.  Defaults to the value of C<$ENV{STATSD_ADDR}>, or
C<localhost:8125>.

=head2 socket

An L<IO::Socket::INET>.  Opened connecting to L</addr> when necessary.

=head1 METHODS

=head2 timing

See L<Mojolicious::Plugin::Statsd/timing>.

=head2 counter

See L<Mojolicious::Plugin::Statsd/counter>.

=cut
