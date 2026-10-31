#!/usr/bin/perl
# What an application hands HTML::D3 may well have come from a request or a saved
# chart, and it is written into a page.  A chart's colours and its title must not
# be able to end the script, attribute or element they are written into.

use strict;
use warnings;

use Test::Most;

use_ok('HTML::D3');

my @HOSTILE_COLOURS = (
	q{red"];alert(1);//},
	q{red';alert(1);//},
	q{</script><script>alert(1)</script>},
	qq{red\nalert(1)},
	q{red\\},
);

my @BARS   = (['a', 1], ['b', 2]);
my @POINTS = ([1, 2], [3, 4]);
my @COMBO  = ({ x => 'a', bar_val => 1, line_val => 2 });
my @HIST   = (1, 2, 3, 4);

# Each option, how to draw with it, and the colour it falls back to.
my %COLOUR_OPTIONS = (
	'bar color' => [ sub { HTML::D3->new->render_bar_chart_snippet(\@BARS, { color => $_[0] }) }, 'steelblue' ],
	'scatter color' => [ sub { HTML::D3->new->render_scatter_chart_snippet(\@POINTS, { color => $_[0] }) }, 'steelblue' ],
	'histogram color' => [ sub { HTML::D3->new->render_histogram_snippet(\@HIST, { color => $_[0] }) }, 'steelblue' ],
	'combo bar_color' => [ sub { HTML::D3->new->render_combo_snippet(\@COMBO, { bar_color => $_[0] }) }, 'steelblue' ],
	'combo line_color' => [ sub { HTML::D3->new->render_combo_snippet(\@COMBO, { line_color => $_[0] }) }, '#e15759' ],
);

subtest 'a colour cannot end what it is written into' => sub {
	for my $name (sort keys %COLOUR_OPTIONS) {
		my ($draw, $default) = @{ $COLOUR_OPTIONS{$name} };
		for my $colour (@HOSTILE_COLOURS) {
			my $html = $draw->($colour)->{html};
			unlike($html, qr/alert\(1\)/, "$name does not write out the script");
			like($html, qr/\Q$default\E/, "$name falls back to its default");
		}
	}
};

# The check is there to stop a script, so it must not stop a colour.
subtest 'every form of CSS colour is still drawn' => sub {
	for my $colour ('tomato', '#1a48c8', 'rgb(10, 20, 30)', 'rgba(10,20,30,0.5)', 'hsl(120 50% 50% / 25%)', 'var(--brand-colour)') {
		for my $name (sort keys %COLOUR_OPTIONS) {
			like($COLOUR_OPTIONS{$name}[0]->($colour)->{html}, qr/\Q$colour\E/, "$name draws $colour");
		}
	}
	like(HTML::D3->new->render_bar_chart_snippet(\@BARS, { color => 'categorical' })->{html}, qr/#4e79a7/i,
		"the 'categorical' token still means the palette");
};

# With a scheme to go to, a bad colour is as good as no colour.
subtest 'a binned histogram with a bad colour draws its scheme' => sub {
	my @bins = ({ label => '0-1', count => 1 }, { label => '1-2', count => 2 });
	my $html = HTML::D3->new->render_histogram_snippet(\@bins, {
		binned => 1, color => $HOSTILE_COLOURS[0], scheme => 'set2',
	})->{html};
	unlike($html, qr/alert\(1\)/, 'the script is not written out');
	like($html, qr/\Q${\ HTML::D3->colour_at('set2', 0) }\E/, 'the scheme is drawn instead');
};

my $TITLE = q{Tom's <b>"Q&A"</b></title><script>alert(1)</script>};
my $SHOWN = q{Tom&#39;s &lt;b&gt;&quot;Q&amp;A&quot;&lt;/b&gt;&lt;/title&gt;&lt;script&gt;alert(1)&lt;/script&gt;};

my @FULL_PAGES = (
	[ render_bar_chart => \@BARS ],
	[ render_line_chart => \@BARS ],
	[ render_animated_bar_chart => \@BARS ],
	[ render_animated_line_chart => \@BARS ],
	[ render_line_chart_with_tooltips => \@BARS ],
	[ render_pie_chart => \@BARS ],
	[ render_animated_pie_chart => \@BARS ],
	[ render_multi_series_line_chart_with_tooltips => [ { name => 's', data => \@BARS } ] ],
	[ render_multi_series_line_chart_with_animated_tooltips => [ { name => 's', data => \@BARS } ] ],
	[ render_multi_series_line_chart_with_legends => [ { name => 's', data => \@BARS } ] ],
	[ render_multi_series_line_chart_with_interactive_legends => [ { name => 's', data => \@BARS } ] ],
);

subtest 'a title is text on every full page' => sub {
	my $chart = HTML::D3->new(title => $TITLE);
	for my $case (@FULL_PAGES) {
		my ($method, $data) = @$case;
		my $html = $chart->$method($data);
		unlike($html, qr/<script>alert/, "$method does not write out the title's script");
		unlike($html, qr/<b>"Q/, "$method does not write out the title's markup");
		like($html, qr{<title>\Q$SHOWN\E</title>}, "$method: <title> holds it as text");
		like($html, qr{<h1[^>]*>\Q$SHOWN\E</h1>}, "$method: <h1> holds it as text");
	}
	is($chart->{title}, $TITLE, 'the object keeps what it was given');
};

subtest 'an ordinary title is unchanged' => sub {
	my $html = HTML::D3->new(title => 'Monthly Revenue (2026)')->render_bar_chart(\@BARS);
	like($html, qr{<title>Monthly Revenue \(2026\)</title>}, 'in <title>');
	like($html, qr{>Monthly Revenue \(2026\)</h1>}, 'in <h1>');
};

done_testing();
