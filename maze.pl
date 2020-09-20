use List::Util 'max';

my ( $w, $h, $x, $y, $z ) = @ARGV;

my $CORRIDOR_WIDTH = 3;
my $WALL_WIDTH     = 1;
my $WALL_HEIGHT    = 5;
my $CELL_WIDTH     = $CORRIDOR_WIDTH + $WALL_WIDTH;


if ( ! defined $z )
{
  print "Usage: perl maze.pl w h x y z\n";
}

my $avail = $w * $h;

# cell is padded by sentinel col and row, so I don't check array bounds
my @cell = (map([(('1') x $w), 0], 1 .. $h), [('') x ($w + 1)]);
my @ver = map([("|  ") x $w], 1 .. $h);
my @hor = map([("+--") x $w], 0 .. $h);

sub walk {
	my ($x, $y) = @_;
	$cell[$y][$x] = '';
	$avail-- or return;	# no more bottles, er, cells

	my @d = ([-1, 0], [0, 1], [1, 0], [0, -1]);
	while (@d) {
		my $i = splice @d, int(rand @d), 1;
		my ($x1, $y1) = ($x + $i->[0], $y + $i->[1]);

		$cell[$y1][$x1] or next;

		if ($x == $x1) { $hor[ max($y1, $y) ][$x] = '+  ' }
		if ($y == $y1) { $ver[$y][ max($x1, $x) ] = '   ' }
		walk($x1, $y1);
	}
}

walk(int rand $w, int rand $h);	# generate



my $sx = $x;
my $sy = $y + 1;
my $sz = $z;
my $tx = $sx + ($w * $CELL_WIDTH);
my $ty = $sy + $CELL_WIDTH;
my $tz = $sz + ($h * $CELL_WIDTH);

my $cmd = "mcrcon 'fill $sx $sy $sz $tx $ty $tz air replace'";
print $cmd, "\n";
`$cmd`;

for my $row (0 .. $h) {			# display
  my $column = 0;

  push( @{$hor[$row]}, "+  " );
  for my $cell ( @{$hor[$row]} )
  {
    my $sx = $x + ($row * $CELL_WIDTH);
    my $sy = $y + 1;
    my $sz = $z + ($column * $CELL_WIDTH);
    my $tx = $sx + ($WALL_WIDTH - 1);
    my $ty = $y + $WALL_HEIGHT;
    my $tz = $sz + $CORRIDOR_WIDTH;

    print $cell;
    my $cmd = "";
    if ( $cell eq "+--" )
    {
      $cmd = "mcrcon 'fill $sx $sy $sz $tx $ty $tz stone replace'";
    }
    else
    {
      $cmd = "mcrcon 'fill $sx $sy $sz $tx $ty $sz stone replace'";
    }

    `$cmd`;

#    sleep(1);
    $column++;

  }
  print "+\n";
#  $cmd = "mcrcon 'fill $sx $sy $sz $tx $ty $sz stone replace'";


  $column = 0;
  push( @{$ver[$row]}, "|  " ) if $row < $h;
	for my $cell ( @{$ver[$row]} )
  {
    my $sx = $x + ($row * $CELL_WIDTH) + 1;
    my $sy = $y + 1;
    my $sz = $z + ($column * $CELL_WIDTH);
    my $tx = $sx + ($CORRIDOR_WIDTH - 1);
    my $ty = $y + $WALL_HEIGHT;
    my $tz = $sz + ($WALL_WIDTH - 1);

    my $fill = $cell eq "   " ? "air" : "stone";
    my $cmd = "mcrcon 'fill $sx $sy $sz $tx $ty $tz $fill replace'";

    print $cell;
    `$cmd`;
    $column++;
  }

  print  "|\n" if $row < $h;


}
