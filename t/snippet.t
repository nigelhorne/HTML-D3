#!/usr/bin/env perl

use warnings;
use strict;

use HTML::D3;
use Test::Most tests => 14;

my $chart = HTML::D3->new(
	width  => 800,
	height => 600,
	title  => 'Embedded Chart',
);

my $data = [
	['January',  1000],
	['February', 1200],
	['March',     950],
];

isa_ok($chart, 'HTML::D3', 'Chart object is created');
is($chart->{width},  800, 'Width is set correctly');
is($chart->{height}, 600, 'Height is set correctly');
is($chart->{title},  'Embedded Chart', 'Title is set correctly');

my $fragment;
lives_ok { $fragment = $chart->render_line_chart_snippet($data) } 'Snippet renders without error';

is(ref($fragment), 'HASH', 'Returns a hash reference');
is($fragment->{svg_id}, 'chart', 'svg_id key is present and correct');

my $html = $fragment->{html};
like($html,   qr/<svg id="chart"/,              'Fragment contains SVG element');
like($html,   qr/January/,                      'Fragment contains data label');
like($html,   qr/1000/,                         'Fragment contains data value');
like($html,   qr/<div class="tooltip"/,         'Fragment contains tooltip div');
unlike($html, qr/<!DOCTYPE/i,                   'Fragment has no DOCTYPE');
unlike($html, qr/<html/i,                       'Fragment has no <html> wrapper');

throws_ok {
	$chart->render_line_chart_snippet('Invalid data');
} qr/Data must be an array of arrays/, 'Dies on invalid data';
