package Jifty::Plugin::TemplateGraph;
use warnings;
use strict;
use base qw/Jifty::Plugin/;
use AnyEvent;
use GraphViz;
use strict;
use warnings;

=head1 NAME

Jifty::Plugin::TemplateGraph

=head1 DESCRIPTIONS

This plugin generate template call graph by GraphViz.

put this config to your etc/config.yml

  Plugins: 
    - TemplateGraph:
        entry_pages: 
            - index.html
            - login
        graphviz: { }
        output: template.png

=cut

my $config;
our $graph;
our $CURRENT_TEMPLATE = '';

sub init {
    my $self = shift;
    my %config = @_;
    return if $self->_pre_init;
    $config = \%config;

    warn "Overwriting an existing Template::Declare->around_template"
        if Template::Declare->around_template;

    Template::Declare->around_template( sub { $self->around_template(@_) });

    $self->{done} = AnyEvent->condvar;
    my $pid = fork; # or exit 5;
    if( $pid ) {
        $graph = GraphViz->new( %{ $config->{graphviz} } );

        # parent
        my $ppid = $$;
        $self->{cb} = AnyEvent->child (
                pid => $pid,
                cb  => sub {
                    my ($pid, $status) = @_;
                    warn "pid $pid exited with status $status";
                    $self->{done}->send;

                    # XXX: should stop current server if child process exited.
                },
            );

        # XXX: put in jifty server ready trigger ?
        # $self->{done}->recv;
    }
    else {
        # child
        Jifty->log->debug('TemplateGraph: child pid: ' . $$ );


        # wait for server
        # XXX: wait for server ready signal.
        sleep 5;

        Jifty->log->info( 'TemplateGraph: start fetching ...' );
        require LWP::UserAgent;
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        $ua->env_proxy;
        for my $path ( @{ $config->{entry_pages} } ) {
            my $url = Jifty->web->url() . $path;
            my $response = $ua->get( $url );
            if ($response->is_success) {
                Jifty->log->info( "TemplateGraph: $url fetched." );
            }
            else {
                Jifty->log->error( "TemplateGraph: " . $response->status_line );
            }
        }
        Jifty->log->info( "TemplateGraph: Now please hit Ctrl-c to get template call graph."  );

        # kill child process.
        kill TERM => $$;
    }

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
    my $output = $config->{output} || 'template.png';
    Jifty->log->info( "Generating template call graph to $output." );
    open my $handle, '>', $output;
    binmode($handle);
    print $handle $graph->as_png;
}


1;
