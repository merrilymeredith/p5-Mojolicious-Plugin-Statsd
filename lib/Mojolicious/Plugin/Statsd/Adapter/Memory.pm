package Mojolicious::Plugin::Statsd::Adapter::Memory;

use Mojo::Base -base;

# scalar values: counter
# hashref values: timings (keys: samples[] avg min max)
has stats => sub {
  {}
};

sub timing {
  my ($self, $names, $time, $sample_rate) = @_;

  if (($sample_rate // 1) != 1) {
    return unless rand() <= $sample_rate;
  }

  my $stats = $self->stats;
  for my $key (@$names) {
    my $timing = $stats->{$key} //= {};

    ($timing->{samples} //= 0) += 1;

    $timing->{avg} =
      (($timing->{avg} // 0) + $time) / $timing->{samples};

    if (!exists $timing->{min} or $timing->{min} > $time) {
      $timing->{min} = $time;
    }

    if (!exists $timing->{max} or $timing->{max} < $time) {
      $timing->{max} = $time;
    }
  }
  return 1;
}

sub counter {
  my ($self, $counters, $delta, $sample_rate) = @_;

  if (($sample_rate // 1) != 1) {
    return unless rand() <= $sample_rate;
  }

  my $stats = $self->stats;

  for my $name (@$counters) {
    ($stats->{$name} //= 0) += $delta;
  }
  return 1;
}

1;
