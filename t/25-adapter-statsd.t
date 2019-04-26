use Mojo::Base -strict;

use Test::More;
use Test::Warnings qw(warning);

use Mojolicious::Plugin::Statsd::Adapter::Statsd;

package Mock::Socket {
  use Mojo::Base -base;

  has buffer        => sub { [] };
  has truncate_send => 0;

  sub send {
    my ($self, $data) = @_;
    push @{$self->buffer}, $data;
    return length($data) unless $self->truncate_send;
  }

  sub pop {
    pop @{(shift)->buffer};
  }
}

my $sock = new_ok 'Mock::Socket';

my $statsd = new_ok
  'Mojolicious::Plugin::Statsd::Adapter::Statsd',
  [socket => $sock];

can_ok $statsd => qw(timing counter);

ok $statsd->counter(['test1'], 1), 'bumped test1 by 1';
is $sock->pop, 'test1:1|c', 'recorded 1 hit for test1';

ok $statsd->counter(['test2'], 1, 0.99) || 1, 'bumped test2 by 1, sampled';
is $sock->pop // 'test2:1|c@0.99', 'test2:1|c@0.99', 'recorded 1 hit for test2';

ok $statsd->counter(['test1', 'test3'], 1),
  'bumped test1 and test3 by 1';
ok $sock->pop eq "test1:1|c\012test3:1|c",
  'recorded hits for test1 and test3';

ok $statsd->timing(['test4'], 1000),
  'timing test4 for 1000ms';
is $sock->pop, 'test4:1000|ms',
  'recorded timing of 1000 for test4';

$statsd->socket->truncate_send(1);
like
  warning { $statsd->counter(['test5'], 1) },
  qr/truncated/,
  'warned/carped about possible truncated packet';

done_testing();
