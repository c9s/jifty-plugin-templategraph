package Jifty::Plugin::TemplateGraph;
use warnings;
use strict;
use base qw/Jifty::Plugin/;
use GraphViz;
use strict;
use warnings;
our $graph = GraphViz->new;
our $CURRENT_TEMPLATE = '';

sub init {
    my $self = shift;
    return if $self->_pre_init;
#     return unless Jifty->config->framework('DevelMode')
#                && !Jifty->config->framework('HideHalos');

    warn "Overwriting an existing Template::Declare->around_template"
        if Template::Declare->around_template;

    Template::Declare->around_template( sub { 
            $self->around_template(@_)
        } );
}


sub around_template {
    my $class = shift;
    my $orig = shift;
    my ($path, $args, $code) = @_;
    $graph->add_edge($CURRENT_TEMPLATE => $path);
    local $CURRENT_TEMPLATE = $path;
    $orig->(@_);
}

END {
    open my $handle, '>template.png';
    binmode($handle);
    print $handle $graph->as_png;
}


1;
