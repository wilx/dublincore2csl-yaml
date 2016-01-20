#! env perl

use strict;
use warnings;

use LWP::Simple qw();
use HTML::DublinCore;
use YAML qw();
use DateTime::Format::ISO8601;
use IO::Handle;

my $htmldoc = LWP::Simple::get($ARGV[0]);
die "Could not get $ARGV[0]. $@" unless defined $htmldoc;

my $dc = HTML::DublinCore->new($htmldoc);
my %entry = ();

sub test {
    my $x = $_[0];
    return defined ($x) && length ($x->content);
}

my $title = $dc->element('Title');
if (test $title) {
    $entry{'title'} = $title->content;
}

my $id = undef;
my @creators = $dc->creator;
if (@creators) {
    foreach my $creator (@creators) {
        my $creator_text = $creator->content;
        my $author = {};
        if ($creator_text =~ /^\s*([^,]+)\s*,\s*(.*\S)\s*$/) {
            my $family = $1;
            my $given = $2;
            $author->{'family'} = $family;
            $author->{'given'} = $given;
        }
        else {
            $author->{'family'} = $creator_text;
        }

        if (! $id) {
            $id = $author->{'family'};
            $id =~ s/\W//g;
            $id = lc $id;
        }
        
        push @{$entry{'author'}}, $author;
    }
    $entry{'id'} = $id;
}


sub date_conversion {
    my $date = $_[0];
    my $year = $date->year;
    my $month = $date->month;
    my $day = $date->day;

    my $issued;
    if ($year && $month && $day) {
        $issued = {'date-parts' => [[$year, $month, $day]]};
    }
    elsif ($year) {
        $issued = [{'year' => $year}];
    }
    else {
        print STDERR "Unrecognizable date.\n";
    }
}

my $dc_date = $dc->date;
if (test $dc_date) {
    #print STDERR "raw date: ", $dc_date->content, "\n";
    my $date = DateTime::Format::ISO8601->parse_datetime($dc_date->content);
    my $year = $date->year;
    my $month = $date->month;
    my $day = $date->day;

    my $issued = date_conversion $date;
    if ($issued) {
        $entry{'issued'} = $issued;
    }

    if (exists $entry{'id'} && $year) {
        $entry{'id'} .= $year;
    }
}

my $dc_type = $dc->type;
if (test $dc_type) {
    my $type = $dc_type->content;
    $entry{'genre'} = ucfirst $type;
}

my $publisher = $dc->publisher;
if (test $publisher) {
    $entry{'publisher'} = $publisher->content;
}

my @subject = $dc->subject;
if (@subject) {
    my @subjects = ();
    for my $dc_subject (@subject) {
        my $subject = $dc_subject->content;
        push @subjects, $subject;
    }
    $entry{'keyword'} = join ", ", @subjects;
}

$entry{'URL'} = $ARGV[0];
$entry{'type'} = "thesis";

$entry{'accessed'} = date_conversion(DateTime->today());


STDOUT->binmode(":utf8");
print "\n---\n", YAML::Dump([\%entry]), "\n...\n";
