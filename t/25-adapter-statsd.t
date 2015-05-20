use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojolicious::Plugin::Statsd::Adapter::Statsd;

package Mock::Socket {
  use Mojo::Base -base;

  has buffer => sub { [] };

  sub send {
    push @{ (shift)->buffer }, @_;
  }

  sub pop {
    pop @{ (shift)->buffer };
  }
}

my $sock = new_ok( 'Mock::Socket' );

my $statsd = new_ok(
  'Mojolicious::Plugin::Statsd::Adapter::Statsd',
  [ socket => $sock ]
);

can_ok(
  $statsd => qw( timing increment decrement update_stats )
);

ok( $statsd->increment('test1'), 'incremented test1 counter' );
is( $sock->pop, 'test1:1|c', 'recorded 1 hit for test1' );

ok( $statsd->decrement('test2'), 'decremented test2 counter' );
is( $sock->pop, 'test2:-1|c', 'recorded -1 hit for test2' );

ok( $statsd->update_stats('test1', 2), 'bumped test1 by 2' );
is( $sock->pop, 'test1:2|c', 'recorded 2 hits for test1' );

ok(
  $statsd->update_stats(['test1', 'test3'], 1),
  'bumped test1 and test3 by 1'
);
ok(
  $sock->pop eq 'test3:1|c' && $sock->pop eq 'test1:1|c',
  'recorded hits for test1 and test3'
);

ok(
  $statsd->timing('test4', 1000),
  'timing test4 for 1000ms'
);
is(
  $sock->pop, 'test4:1000|ms',
  'recorded timing of 1000 for test4'
);

done_testing();
