package Mojolicious::Plugin::Statsd::Adapter;
use Mojo::Base -base;

use Carp 'croak';

sub increment {
  my $self = shift;
  my ( $counter, $sample_rate ) = @_;

  return $self->update_stats( $counter, 1, $sample_rate );
}

sub decrement {
  my $self = shift;
  my ( $counter, $sample_rate ) = @_;

  return $self->update_stats( $counter, -1, $sample_rate );
}

sub timing {
  croak "Method 'timing' not implemented by subclass!";
}

sub update_stats {
  croak "Method 'update_stats' not implemented by subclass!";
}

1;
