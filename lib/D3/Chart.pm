package D3::Chart;

use strict;
use warnings;

=head1 NAME

D3::Chart - A simple Perl module for generating bar charts using D3.js.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use D3::Chart;

    my $chart = D3::Chart->new(
        width  => 1024,
        height => 768,
        title  => 'Sample Bar Chart'
    );

    my $data = [
        ['Category 1', 10],
        ['Category 2', 20],
        ['Category 3', 30]
    ];

    my $html = $chart->render_bar_chart($data);
    print $html;

    $chart = D3::Chart->new(title => 'Sales Data');

    my $data = [
        ['Product A', 100],
        ['Product B', 150],
        ['Product C', 200]
    ];

    $html = $chart->render_bar_chart($data);
    print $html;

=head1 DESCRIPTION

D3::Chart is a Perl module that provides functionality to create simple bar charts
using D3.js. The module generates HTML and JavaScript code to render the chart in a web browser.

=head1 METHODS

=head2 new

    my $chart = D3::Chart->new(%args);

Creates a new D3::Chart object. Accepts the following optional arguments:

=over 4

=item * C<width> - The width of the chart (default: 800).

=item * C<height> - The height of the chart (default: 600).

=item * C<title> - The title of the chart (default: 'Chart').

=back

=cut

# Constructor to initialize chart properties
sub new {
    my ($class, %args) = @_;
    my $self = {
        width  => $args{width}  || 800,  # Default chart width
        height => $args{height} || 600,  # Default chart height
        title  => $args{title}  || 'Chart',  # Default chart title
    };
    return bless $self, $class;
}

=head2 render_bar_chart

    my $html = $chart->render_bar_chart($data);

Generates HTML and JavaScript code to render a bar chart. Accepts the following arguments:

=over 4

=item * C<$data> - An array reference containing data points. Each data point should
be an array reference with two elements: the label (string) and the value (numeric).

=back

Returns a string containing the HTML and JavaScript code for the chart.

=cut

# Method to render a bar chart with given data
sub render_bar_chart {
    my ($self, $data, %options) = @_;

    # Validate input data to ensure it is an array of arrays
    die "Data must be an array of arrays" unless ref($data) eq 'ARRAY';

    # Generate JSON representation of data
    require JSON;
    my $json_data = JSON::encode_json([
        map { { label => $_->[0], value => $_->[1] } } @$data
    ]);

    # Generate HTML and D3.js JavaScript for rendering the bar chart
    my $html = <<'HTML';
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$self->{title}</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
</head>
<body>
    <h1 style="text-align: center;">$self->{title}</h1>
    <svg id="chart" width="$self->{width}" height="$self->{height}" style="border: 1px solid black;"></svg>
    <script>
        const data = $json_data;

        const svg = d3.select("#chart");
        const margin = { top: 20, right: 30, bottom: 40, left: 40 };
        const width = $self->{width} - margin.left - margin.right;
        const height = $self->{height} - margin.top - margin.bottom;

        // Set up scales for x and y axes
        const x = d3.scaleBand()
            .domain(data.map(d => d.label))
            .range([0, width])
            .padding(0.1);

        const y = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.value)])
            .nice()
            .range([height, 0]);

        const chart = svg.append("g")
            .attr("transform", `translate(${margin.left},${margin.top})`);

        // Add bars to the chart
        chart.append("g")
            .selectAll("rect")
            .data(data)
            .join("rect")
            .attr("x", d => x(d.label))
            .attr("y", d => y(d.value))
            .attr("height", d => height - y(d.value))
            .attr("width", x.bandwidth())
            .attr("fill", "steelblue");

        // Add the y-axis
        chart.append("g")
            .call(d3.axisLeft(y));

        // Add the x-axis with labels rotated for better readability
        chart.append("g")
            .attr("transform", `translate(0,${height})`)
            .call(d3.axisBottom(x))
            .selectAll("text")
            .attr("transform", "rotate(-45)")
            .style("text-anchor", "end");
    </script>
</body>
</html>
HTML

    return $html;
}

=head1 AUTHOR

Nigel Horne <njh@bandsman.co.uk>

=head1 LICENSE

This program is released under the following licence: GPL2

=cut

1;
