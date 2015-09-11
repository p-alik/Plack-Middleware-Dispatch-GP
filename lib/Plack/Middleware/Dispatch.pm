package Plack::Middleware::Dispatch;
$Plack::Middleware::Dispatch::VERSION = '0.01';

=head1 NAME

Plack::Middleware::Dispatch - Simple general purposes dispatcher middleware

=head1 VERSION

Version 0.01

=cut

use strict;
use warnings FATAL => 'all';

use parent "Plack::Middleware";
use Plack::Util::Accessor qw/
    dispatch
    /;

use Plack::Request ();
use Scalar::Util   ();

=head1 SYNOPSIS

  use Plack::Builder;

  my $foo = Foo->new() # Foo should provide dispatch method

  my $app = sub { ... };
  builder {
    enable "Dispatch", dispatch => [\&cb, $foo];
    $app;
  };

  # cb(Plack::Request)
  sub cb {
    my($req) = @_;
    ...
  }


=head1 SUBROUTINES/METHODS

=head2 new($p)

C<$p> a hash reference

C<$p->{dispatch} [CODE reference or an object provides dispatch method]

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    (@_ == 1 && ref $_[0] eq "HASH")
        || die "$class->new expects a has reference parameter";

    my $disp = delete($_[0]->{dispatch});
    ($disp) || die "$class requires dispatch parameter";

    my $self = $class->SUPER::new(@_);
    my @d
        = ref($disp) eq 'ARRAY'
        ? @{$disp}
        : ($disp);
    for (my $i = 0; $i <= $#d; $i++) {
        if (Scalar::Util::blessed($d[$i])) {
            my $cb = $d[$i];

            $cb->can("dispatch")
                || die ref($cb) . " doesn't provide dispatch()";

            $d[$i] = sub { $cb->dispatch(@_) };
        } ## end if (Scalar::Util::blessed...)

        (ref($d[$i]) eq "CODE") || die <<'HERE';
dispatch should be a code reference or an object that responds to dispatch()
HERE
    } ## end for (my $i = 0; $i <= $#d...)

    $self->dispatch([@d]);

    return $self;
} ## end sub new

=head2 call($env)

delivers Plack::Request->new($env) to the dispatchers

=cut

sub call {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    foreach my $d (@{ $self->dispatch }) {
        $d->($req);
    }

    $self->app->($env);
} ## end sub call

1;    # End of Plack::Middleware::Dispatch

=head1 AUTHOR

Alexei Pastuchov, C<< <palik at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-plack-middleware-dispatch1 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Plack-Middleware-Dispatch>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 REPOSITORY

L<https://github.com/p-alik/Plack-Middleware-Dispatch>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Plack::Middleware::Dispatch

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Plack-Middleware-Dispatch>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Plack-Middleware-Dispatch>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Plack-Middleware-Dispatch>

=item * Search CPAN

L<http://search.cpan.org/dist/Plack-Middleware-Dispatch/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Alexei Pastuchov.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
