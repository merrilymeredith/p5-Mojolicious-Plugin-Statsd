package Mojolicious::Plugin::Statsd;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojolicious::Plugin::Statsd::Adapter::Memory;

has adapter => sub {
  Mojolicious::Plugin::Statsd::Adapter::Memory->new()
};

has prefix => sub { '' };

sub register {
  my ($self, $app, $conf) = @_;
  
  # $conf = {
  #   adapter => 'Statsd', (or ref?)
  #   host/port?
  #   prefix  => 'myapp.',
  #   hooks   => {
  #   }
  # }

  $self->{prefix} //= $app->moniker .q[.];

  $app->helper( stats => sub { return $self } );
}

sub copy {
  my ( $self, @args ) = @_;

  return (ref $self)->new(%$self, @args);
}

sub add_prefix {
  my ( $self, $add_prefix ) = @_;

  my $copy = $self->copy;
     $copy->prefix( $self->prefix . $add_prefix );
  return $copy;
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Statsd - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Statsd');

  # Mojolicious::Lite
  plugin 'Statsd';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Statsd> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::Statsd> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
