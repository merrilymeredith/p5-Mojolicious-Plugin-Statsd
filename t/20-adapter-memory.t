use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojolicious::Plugin::Statsd;

my $mem = new_ok(
  'Mojolicious::Plugin::Statsd::Adapter::Memory'
);

can_ok(
  $mem => qw( timing increment decrement update_stats )
);

my $data = $mem->stats;
ok( $mem->increment('test1'), 'incremented test1 counter' );
is( $data->{test1}, 1, 'recorded 1 hit for test1' );

ok( $mem->decrement('test2'), 'decremented test2 counter' );
is( $data->{test2}, -1, 'recorded -1 hit for test2' );

ok( $mem->update_stats('test1', 2), 'bumped test1 by 2' );
is( $data->{test1}, 3, 'recorded 2 hits for test1' );

ok(
  $mem->update_stats(['test1', 'test3'], 1),
  'bumped test1 and test3 by 1'
);
ok(
  $data->{test1} == 4 && $data->{test3} == 1,
  'recorded hits for test1 and test3'
);

ok(
  $mem->timing('test4', 1000),
  'timing test4 for 1000ms'
);
is(
  ref( my $test4 = $data->{test4} ),'HASH',
  'created test4 timing structure'
);

is( $test4->{samples}, 1,    'test4 has 1 sample' );
is( $test4->{avg},     1000, 'test4 avg is 1000' );
is( $test4->{min},     1000, 'test4 min is 1000' );
is( $test4->{max},     1000, 'test4 max is 1000' );

ok(
  $mem->timing('test4', 500),
  'timing test4 for 500ms'
);
is( $test4->{samples}, 2,    'test4 has 1 sample' );
is( $test4->{avg},     750,  'test4 avg is 750' );
is( $test4->{min},     500,  'test4 min is 500' );
is( $test4->{max},     1000, 'test4 max is 1000' );

done_testing();
