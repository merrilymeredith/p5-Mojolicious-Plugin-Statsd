package Mojolicious::Plugin::Statsd::Adapter::Memory;
use Mojo::Base 'Mojolicious::Plugin::Statsd::Adapter';

use Mojo::Collection 'c';

# scalar values: counter
# hashref values: timings (keys: samples[] avg min max)
has stats => sub {
  {}
};

sub timing {
  my $self = shift;
  my ( $name, $time, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  my $stats = $self->stats;
  c( $name )->flatten->each(sub {
    my $key = shift;
    
    my $timing = $stats->{$key} //= {};

    ($timing->{samples} //= 0) += 1;

    $timing->{avg} = 
      ( ($timing->{avg} // 0) + $time ) / $timing->{samples};

    if ( !exists $timing->{min} or $timing->{min} > $time ){
      $timing->{min} = $time
    }

    if ( !exists $timing->{max} or $timing->{max} < $time ){
      $timing->{max} = $time
    }
  });
}

sub update_stats {
  my $self = shift;
  my ( $counter, $delta, $sample_rate ) = @_;

  if ( ($sample_rate // 1) != 1 ){
    return unless rand() <= $sample_rate;
  }

  my $stats = $self->stats;

  c( $counter )->flatten->each(sub {
    ($stats->{$_[0]} //= 0) += $delta;
  });
}

1;
