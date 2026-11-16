use <lib/sieve.scad>;

/* [General] */

// Outer diameter of the
outer_diameter = 120; //[5.0:.1:250.0]

// Width of the filter wires generally keep this greater than your nozzle diameter
strand_width = .8; //[.10:.01:10.00]

// Thickness (height) of the filter wires. If 'Offset strands' is enabled, the filter grid will be twice this thick.
strand_height = .8; //[.10:.01:5]

// Spacing between filter wires, i.e. hole size.
gap_size = 1; //[.10:.01:10.00]

// Thickness (width) of the outer rim (will increase with height if taper > 1).
rim_thickness = 3; //[.3:.01:5]

// Total height of the outer rim.
rim_height = 5; //[0:.1:50]

// Taper of the tube: scale factor of top versus bottom contour.
taper = 1; //[1:0.01:3]

// If true, wires are placed in layers for faster, better prints with thin strands.
offset_strands = true;

// Set to first layer height for thin strands to avoid squishing or wide extrusion.
lift_strands = 0; //[0.00:0.01:2.00]

// Define the allowance to achieve the desired diameter clearance between the sieve and the holder
holder_insert_allowance = 0.5;

// Define the allowance to achieve the desired diameter clearance between the holder and it's female cut
holder_dia_allowance = 0.3;

// Define the height allowance to to prevent seam gaps between the sieve and holder
holder_height_allowance = 0.4;

// Number of segments for round shape, low values can be used to obtain polygons that fit inside a circle of the
// specified outer diameter. For instance, 3 yields a triangle.
$fn = 72; //[3:1:256]

/* [Render Control] */

render = "sieve"; // [sieve,holder,all]

/* [Hidden] */

zFite = $preview ? 0.1 : 0;
shift_abs = gap_size + strand_width;

if (render == "sieve" || render == "all")
    color("green") sieve(od_x = outer_diameter, od_y = outer_diameter, strand_width = strand_width,
                         strand_thick = strand_height, gap = gap_size, rim_thick = rim_thickness, rim_h = rim_height,
                         taper_scale = taper, do_offset = offset_strands, sh_x = shift_abs, sh_y = shift_abs);

if (render == "holder" || render == "all")
    color("blue") stackable_sieve_holder(od_x = outer_diameter, od_y = outer_diameter, rim_thick = rim_thickness,
                                         rim_h = rim_height, insert_allowance = holder_insert_allowance,
                                         holder_h_allowance = holder_height_allowance,
                                         holder_rim_allowance = holder_dia_allowance, taper_scale = taper);