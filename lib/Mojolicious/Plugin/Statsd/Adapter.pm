package Mojolicious::Plugin::Statsd::Adapter;
use Mojo::Base -base;

use Carp 'croak';

sub timing {
  croak "Method 'timing' not implemented by subclass!";
}

sub update_stats {
  croak "Method 'update_stats' not implemented by subclass!";
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Statsd::Adapter - Adapter base class

=head1 SYNOPSIS

   package Mojolicious::Plugin::Statsd::Adapter::Foo;

   use Mojo::Base 'Mojolicious::Plugin::Statsd::Adapter';

   sub update_stats {
     my ( $self, $counters, $delta, $sample_rate ) = @_;

     # magic happens
   }

   sub timing {
     my ( $self, $names, $time, $sample_rate ) = @_;

     # magic happens
   }

=head1 DESCRIPTION

L<Mojolicious::Plugin::Statsd::Adapter> is an abstract base class for L<Mojolicious::Plugin::Statsd> adapters.

=head1 ADAPTERS

The following adapters are bundled with L<Mojolicious::Plugin::Statsd>:

=over

=item L<Mojolicious::Plugin::Statsd::Adapter::Memory>

=item L<Mojolicious::Plugin::Statsd::Adapter::Statsd>

=back

=head1 METHODS

L<Mojolicious::Plugin::Statsd> inherits all methods from L<Mojo::Base> and
implements the following new ones:

=head2 timing

This method is called to record timings in the stats backend.  It must be
implemented by subclasses and should expect following arguments:

=over

=item names

An arrayref of timing names to be updated. Adapters should always expect to
record one or more timings.

=item time

A time value in milliseconds

=item sample_rate

Optional. Given a fraction n between 0 and 1, calls to timing() should only be
recorded (n * 100)% of the time.

=back

=head2 update_stats

This method is called to change counters in the stats backend.  It must be
implemented by subclasses and should expect the following arguments:

=over

=item counters

An arrayref of counter names to be updated. Adapters should always expect to
record one or more counters.

=item delta

An positive or negative integer to be applied to the counter. Increment, for
example, is 1; decrement, -1.

=item sample_rate

Optional. Given a fraction n between 0 and 1, calls to timing() should only be
recorded (n * 100)% of the time.

=back

=head1 SEE ALSO

L<Mojolicious::Plugin::Statsd>

=cut
