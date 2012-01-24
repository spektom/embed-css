#!/usr/bin/env perl

use File::Spec;
use File::Basename;
use File::MimeInfo;
use MIME::Base64;

my $inputCSS = shift(@ARGV);
if (!$inputCSS) {
	die ("USAGE: $0 <CSS file>\n");
}

my $dir = dirname($inputCSS);

open(F, $inputCSS) or die($!);
my $line;
while ($line = <F>) {
	$line =~ s/([ \:])url\(([^\)]+)\)/"$1url(".encodeURL($2).")"/gie;
	print $line;
}
close(F);

sub encodeURL {
	my $url = shift;
	my $original = $url;
	$url =~ s/^['"](.*)['"]$/$1/;
	$url = File::Spec->file_name_is_absolute($url) ? $url : $dir."/".$url;
	my $mimeType = mimetype($url);
	if ($mimeType =~ /^image\//) {
		my $image;
		{
			local $/ = undef;
			open (FILE, $url) or die($!);
			binmode FILE;
			$image = <FILE>;
			close FILE;
		}
		my $encoded = encode_base64($image, "");
		return "'data:$mimeType;base64,$encoded'";
	}
	return $original;
}

