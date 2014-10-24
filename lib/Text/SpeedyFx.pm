package Text::SpeedyFx;
# ABSTRACT: tokenize/hash large amount of strings efficiently

use strict;
use utf8;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.005'; # VERSION

require XSLoader;
XSLoader::load('Text::SpeedyFx', $VERSION);

1;


=pod

=encoding utf8

=head1 NAME

Text::SpeedyFx - tokenize/hash large amount of strings efficiently

=head1 VERSION

version 0.005

=head1 SYNOPSIS

    use Data::Dumper;
    use Text::SpeedyFx;

    my $sfx = Text::SpeedyFx->new;

    my $words_bag = $sfx->hash('To be or not to be?');
    print Dumper $words_bag;
    #$VAR1 = {
    #          '1422534433' => '1',
    #          '4120516737' => '2',
    #          '1439817409' => '2',
    #          '3087870273' => '1'
    #        };

    my $feature_vector = $sfx->hash_fv("thats the question", 8);
    print unpack('b*', $feature_vector);
    # 01001000

=head1 DESCRIPTION

XS implementation of a very fast combined parser/hasher which works well on a variety of I<bag-of-word> problems.

L<Original implementation|http://www.hpl.hp.com/techreports/2008/HPL-2008-91R1.pdf> is in Java and was adapted for a better Unicode compliance.

=head1 METHODS

=head2 new([$seed])

Initialize parser/hasher, optionally using a specified C<$seed> (default: 1).

=head2 hash($string)

Parses C<$string> and returns a hash reference where keys are the hashed tokens and values are their respective count.
Note that this is the slowest form due to the (computational) complexity of the Perl hash structure itself:
C<hash_fv()> is 147% faster, while C<hash_min()> is 175% faster.

=head2 hash_fv($string, $n)

Parses C<$string> and returns a feature vector (string of bits) with length C<$n>.
C<$n> is supposed to be a multiplier of 8, as the length of the resulting feature vector is C<ceil($n / 8)>.
Feature vector format can be useful in L<Bloom filter|http://en.wikipedia.org/wiki/Bloom_filter> implementation, for instance.

=head2 hash_min($string)

Parses C<$string> and returns the hash with the lowest value.
Useful in L<MinHash|http://en.wikipedia.org/wiki/MinHash> implementation.
See also the included L<minhash_cmp> utility.

=head1 REFERENCES

=over 4

=item *

L<Extremely Fast Text Feature Extraction for Classification and Indexing|http://www.hpl.hp.com/techreports/2008/HPL-2008-91R1.pdf> by L<George Forman|http://www.hpl.hp.com/personal/George_Forman/> and L<Evan Kirshenbaum|http://www.kirshenbaum.net/evan/index.htm>

=item *

L<MinHash — выявляем похожие множества|http://habrahabr.ru/post/115147/>

=item *

L<Фильтр Блума|http://habrahabr.ru/post/112069/>

=back

=head1 AUTHOR

Stanislaw Pusep <stas@sysd.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Stanislaw Pusep.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

