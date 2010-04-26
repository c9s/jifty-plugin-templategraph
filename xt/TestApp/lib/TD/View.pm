package TD::View;
use warnings;
use strict;
use Jifty::View::Declare -base;
use Jifty::View::Declare::Helpers;

template 'index.html' => page {
    show '/app/header';
    show '/app/body';
    show '/app/footer';
};

template '/app/header' => sub { h1 { 'header' } };
template '/app/footer' => sub { h1 { 'footer' } };
template '/app/body' => sub {
    show '/app/foo/name';
    show '/app/bar/name';
};

template '/app/foo/name' => sub { h1 { 'foo' } };
template '/app/bar/name' => sub { h1 { 'bar' } };

1;
