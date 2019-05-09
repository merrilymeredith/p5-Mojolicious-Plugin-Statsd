# vim: ft=perl

requires 'Mojolicious', '5.00';

on test => sub {
  requires 'Test::More', '0.96';
  requires 'Test::Warnings';
};

