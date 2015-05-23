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
