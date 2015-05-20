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
is( $sock->pop, 'test1|c:1', 'recorded 1 hit for test1' );

ok( $statsd->decrement('test2'), 'decremented test2 counter' );
is( $sock->pop, 'test2|c:-1', 'recorded -1 hit for test2' );

ok( $statsd->update_stats('test1', 2), 'bumped test1 by 2' );
is( $sock->pop, 'test1|c:2', 'recorded 2 hits for test1' );

ok(
  $statsd->update_stats(['test1', 'test3'], 1),
  'bumped test1 and test3 by 1'
);
ok(
  $sock->pop eq 'test3|c:1' && $sock->pop eq 'test1|c:1',
  'recorded hits for test1 and test3'
);

ok(
  $statsd->timing('test4', 1000),
  'timing test4 for 1000ms'
);
is(
  $sock->pop, 'test4|ms:1000',
  'recorded timing of 1000 for test4'
);

done_testing();
