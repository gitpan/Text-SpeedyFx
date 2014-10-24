package Text::SpeedyFx;
# ABSTRACT: tokenize/hash large amount of strings efficiently

use strict;
use utf8;
use warnings;

use base q(Exporter);

our $VERSION = '0.006'; # VERSION

require XSLoader;
XSLoader::load('Text::SpeedyFx', $VERSION);

1;

__END__

=pod

=encoding utf8

=head1 NAME

Text::SpeedyFx - tokenize/hash large amount of strings efficiently

=head1 VERSION

version 0.006

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

=head2 new([$seed, $bits])

Initialize parser/hasher, can be customized with the options:

=over 4

=item C<$seed>

Hash seed (default: 1).

=item C<$bits>

How many bits do represent one character.
The default value, 8, sacrifices Unicode handling but is fast and low on memory footprint.
The value of 18 encompasses I<Basic Multilingual>, I<Supplementary Multilingual> and I<Supplementary Ideographic> planes.
See also L</UNICODE SUPPORT>

=back

=head2 hash($octets)

Parses C<$octets> and returns a hash reference where keys are the hashed tokens and values are their respective count.
C<$octets> are assumed to represent UTF-8 string unless L<Text::SpeedyFx> is instantiated with L</$bits> == 8
(which forces Latin-1 mode, see L</UNICODE SUPPORT>).
Note that this is the slowest form due to the (computational) complexity of the Perl hash structure itself:
C<hash_fv()> is 350% faster, while C<hash_min()> is up to 400% faster.

=head2 hash_fv($octets, $n)

Parses C<$octets> and returns a feature vector (string of bits) with length C<$n>.
C<$n> is supposed to be a multiplier of 8, as the length of the resulting feature vector is C<ceil($n / 8)>.
See the included utilities L<cosine_sim> and L<uniq_wc>.

=head2 hash_min($octets)

Parses C<$octets> and returns the hash with the lowest value.
Useful in L<MinHash|http://en.wikipedia.org/wiki/MinHash> implementation.
See also the included L<minhash_cmp> utility.

=head1 UNICODE SUPPORT

Due to the nature of Perl, Unicode support is handled differently from the original implementation.
By default, L<Text::SpeedyFx> recognizes UTF-8 encoded code points in the range I<00000-2FFFF>:

=over 4

=item *

B<Plane 0>, the B<Basic Multilingual Plane> (BMP, I<0000–FFFF>)

=item *

B<Plane 1>, the B<Supplementary Multilingual Plane> (SMP, I<10000–1FFFF>)

=item *

B<Plane 2>, the B<Supplementary Ideographic Plane> (SIP, I<20000–2FFFF>)

=item *

There are planes up to 16; however, as in Perl v5.16.2, there are no code points matching C<isALNUM_utf8()> there (so it's irrelevant for proper algorithm operation).

=back

Although, there is a major drawback: in this mode, B<each instance> allocates up to 1 MB of memory.

If the application doesn't need to support code points beyond the B<Plane 0>
(like the original SpeedyFx implementation) it is possible to constraint the address space to 16 bits, which lowers memory allocation to up to 256 KB.
In fact, L<Text::SpeedyFx> constructor accepts bit range between 8 and 18 to address code points.

=head2 LATIN-1 SUPPORT

8 bit address space has one special meaning: it completely disables multibyte support.
In 8 bit mode, each instance will only allocate 256 bytes and hashing will be run up to 66% faster.
Tokenization will fallback to I<ISO 8859-1 West European languages (Latin-1)> character definitions.

=head1 BENCHMARK

The test platform configuration:

=over 4

=item *

Intel® Core™ i7-2600 CPU @ 3.40GHz with 8 GB RAM;

=item *

Ubuntu 11.10 (64-bit);

=item *

Perl v5.16.2 (installed via L<perlbrew>);

=item *

F<enwik8> from the L<Large Text Compression Benchmark|https://cs.fit.edu/~mmahoney/compression/text.html>.

=back

                     Rate     hash  hash_min_utf8  hash_fv  hash_min
    hash           19.5 MB/s    --           -68%     -78%      -80%
    hash_min_utf8  60.2 MB/s  209%             --     -34%      -40%
    hash_fv        90.5 MB/s  364%            50%       --       -9%
    hash_min       99.6 MB/s  411%            66%      10%        --

All the tests except C<hash_min_utf8> were made in L<Latin-1 mode|/UNICODE SUPPORT>.

=head1 REFERENCES

=over 4

=item *

L<Extremely Fast Text Feature Extraction for Classification and Indexing|http://www.hpl.hp.com/techreports/2008/HPL-2008-91R1.pdf> by L<George Forman|http://www.hpl.hp.com/personal/George_Forman/> and L<Evan Kirshenbaum|http://www.kirshenbaum.net/evan/index.htm>

=item *

L<MinHash — выявляем похожие множества|http://habrahabr.ru/post/115147/>

=item *

L<Фильтр Блума|http://habrahabr.ru/post/112069/>

=item *

L<cosine_sim>, L<minhash_cmp> and L<uniq_wc> utilities from this distribution

=back

=head1 AUTHOR

Stanislaw Pusep <stas@sysd.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Stanislaw Pusep.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
