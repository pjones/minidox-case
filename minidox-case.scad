/******************************************************************************/
/*
  This file is part of the package minidox-case. It is subject to the
  license terms in the LICENSE file found in the top-level directory
  of this distribution and at:

    https://github.com/pjones/helping-mic

  No part of this package, including this file, may be copied, modified,
  propagated, or distributed except according to the terms contained in
  the LICENSE file.
*/

/******************************************************************************/
$fa = 1.0;
$fs = 0.5;

/******************************************************************************/
/*
  Note: All of the measurements in this file are for the RIGHT side.
  To generate the left side the model is mirrored in the X axis.
*/

/******************************************************************************/
// These are set from the command line:
print_side = "right";           /* right or left */
print_part = "case";            /* case, top, or cover */

/******************************************************************************/
// Optional features:
feature_cover = false;           /* Will you use a cover? */
feature_magnets = false;         /* Add holes to hold magnets? */

/******************************************************************************/
// Settings you may want to tweak:
inner_depth = 9.0;              /* How high the case will come up from the board upward. */
inner_spacing = 2.25;           /* Space under the board to hold it. */
outer_spacing = 1.0;            /* Extra space in the case for the board to fit in. */
cover_inner_space = 2.0;        /* Extra space in the cover for cables, etc. */
board_thickness = 1.6;          /* Thickness of circuit board. */
switch_height = 11.75;          /* Space between top of board and bottom of key cap */
cap_height = 7.90;              /* Height of keycap. */
bolt_size = [3.0, 16.0];        /* M3x16 */
bolt_inset = 2.5;               /* From wall to center of bolt. */
bolt_shaft_wall = 2.0;          /* Wall thickness of shaft bolt screws into. */
bolt_recess = 2.0;              /* How deep bolts go into the bottom. */

/******************************************************************************/
// If using magnets to hold the cover on, fill these out and add a
// small amount of extra so the magnet can go in easily.
//
// The exact measurements of the magnets I'm using are:
//   7.95mm x 2.80mm;
magnet_diameter = 8.25;         /* Magnet diameter. */
magnet_depth = 3.00;            /* Magnet depth. */

/******************************************************************************/
// I don't recommend changing these:
rounding = 2.25;                /* How much rounding to apply. */
thickness = 4;                  /* Wall thickness. */
board_overlap = 1.8;            /* Space around the board the top can sit on */

/******************************************************************************/
// Points that outline the desired case shape:
outline = [
  [0.00,     0.00],
  [95.30,    0.00],
  [95.30,  -64.30],
  [51.00,  -81.00],
  [12.00,  -85.00],
  [-4.40,  -96.00],
  [-21.00, -67.50],
  [0.00,   -54.25],
];

/******************************************************************************/
// Points that outline the shape to cut out of the top so the key caps
// can poke through:
cap_1U = [18.25, 18.25, 0.85, 0.80];
cap_2U = [cap_1U[0], 35.00, 2.00, 1.00];
thumb_1U = [cap_1U[0], cap_1U[1], 2.50, 2.50];

rows = 3;
columns = 5;

function cap_over(keys) =
  /* Size of keycaps + Size of space between them */
  (cap_1U[0] * keys) + (cap_1U[2] * keys);

function cap_back(keys) =
  cap_over(columns) - (cap_over(keys - 1) + (keys == 1 ? 0 : cap_1U[2]));

function column_over(column, base) = lookup(column, [
    [ 1, -4.00 ],
    [ 2, -2.00 ],
    [ 3, -0.00 ],
    [ 4, -2.00 ],
    [ 5, -7.00 ],
  ]) + base;

// Position the entire cut out by placing the center of column in the
// center of the inner case.
cap_x_start =
  (max([for (i = outline) i[0] + outer_spacing])/2) -
  (cap_over(3) - cap_1U[0]/2 - cap_1U[2]/2);

cap_y_upper = -0.50;
cap_y_lower = cap_y_upper + -(cap_1U[1] * rows + cap_1U[3] * (rows + 1));

top_cut = [
  // Upper half:
  [cap_x_start, column_over(1, cap_y_upper)], // Left of Y
  [cap_over(1), column_over(1, cap_y_upper)], // Left of U
  [cap_over(1), column_over(2, cap_y_upper)], // Left of U (moved up)
  [cap_over(2), column_over(2, cap_y_upper)], // Left of I
  [cap_over(2), column_over(3, cap_y_upper)], // Left of I (moved up)
  [cap_over(3), column_over(3, cap_y_upper)], // Left of O
  [cap_over(3), column_over(4, cap_y_upper)], // Left of O (moved down)
  [cap_over(4), column_over(4, cap_y_upper)], // Left of P
  [cap_over(4), column_over(5, cap_y_upper)], // Left of P (moved down)
  [cap_over(5), column_over(5, cap_y_upper)], // Right of P

  // Lower half:
  [cap_back(1), column_over(5, cap_y_lower)], // Right of /
  [cap_back(2), column_over(5, cap_y_lower)], // Left of /
  [cap_back(2), column_over(4, cap_y_lower)], // Left of / (moved up)
  [cap_back(3), column_over(4, cap_y_lower)], // Left of .
  [cap_back(3), column_over(3, cap_y_lower)], // Left of . (moved up)
  [cap_back(4), column_over(3, cap_y_lower)], // Right of M
  [cap_back(4), column_over(2, cap_y_lower)], // Right of M (moved down)
  [cap_back(5), column_over(2, cap_y_lower)], // Right of N
  [cap_back(5), column_over(1, cap_y_lower)], // Right of N (moved down)
  [cap_x_start, column_over(1, cap_y_lower)], // Left of N
];

// Now the three thumb keys:
// These measurements are for the center of the cap and the
// rotation.
thumb_1 = [-5.00, 77.50, 30.0];
thumb_2 = [18.25, 74.75, 15.00];
thumb_3 = [40.00, 72.75, 0.00];

/******************************************************************************/
// Size of the pro micro body and TRRS jack.
//
// Elements:
//  - x size
//  - y size
//  - z size
//  - x offset to center of device
//  - z offset to center of device's opening measured from the bottom
//    of the circuit board to the center of the opening.
//
pro_micro = [ 20.0
            , 34.0
            , 6.0 // Used to set the inner height of the case.
            , 66.75
            , print_side == "right" ? 1.3 : 4.5
            ];

trrs = [ 13.0
       , 13.0
       , 5.23
       , 18.90
       , 2.16
       ];

/******************************************************************************/
// Other computed values:
board_to_caps = switch_height + cap_height;
wall_thickness_no_padding = feature_cover ? thickness * 2 : thickness;
wall_thickness = wall_thickness_no_padding + outer_spacing/2;
bolt_shaft = bolt_size[0] + bolt_shaft_wall;
shelf_width = inner_spacing + outer_spacing + rounding;

/******************************************************************************/
reset_button = [ 5.2            /* x */
               , shelf_width    /* y */
               , 2              /* z */
               , 36.6           /* center of x */
               , 3.25           /* center of y */
               , 2.25           /* diameter of reset hole */
               ];

/******************************************************************************/
// How high to make the shelf that the board sits on:
inner_height = pro_micro[2] + 2.0;
echo("INNER HEIGHT: ", inner_height);

/******************************************************************************/
// Full case height:
outer_height = inner_height + inner_depth;
echo("OUTER HEIGHT:", outer_height);

/******************************************************************************/
// How big the cover needs to be to enclose everything:
cover_inner_height = board_to_caps + cover_inner_space - inner_depth;
echo("COVER INNER HEIGHT:", cover_inner_height);

/******************************************************************************/
// How big is the cover on the outside:
cover_outer_height = max(outer_height, cover_inner_height) +
  thickness + outer_height/2;
echo("COVER OUTER HEIGHT:", cover_outer_height);

/******************************************************************************/
case_width = max([ for (i = outline) i[0] ]) +
  ((outer_spacing + thickness)*2) +
  (feature_cover ? thickness*2 : 0);

cover_wall_height = outer_height/2 + thickness;

/******************************************************************************/
module cover_wall(height) {
  difference() {
    // The outer wall the case sits on.
    linear_extrude(height=height)
      offset(delta=outer_spacing + thickness*2)
      offset(r=+rounding) offset(delta=-rounding)
      polygon(points=outline);

    // Cut the wall off the back so device access isn't limited.
    translate([ case_width/2
              , thickness + outer_spacing + thickness/2
              , height/2
              ])
      cube([case_width*2, thickness, height+2], center=true);
  }
}

/******************************************************************************/
module outer_case() {
  difference() {
    union() {
      // Outer wall:
      linear_extrude(height=outer_height + thickness)
        offset(delta=outer_spacing + thickness)
        offset(r=+rounding) offset(delta=-rounding)
        polygon(points=outline);

      // Lower outer wall for case to sit on:
      if (feature_cover) cover_wall(cover_wall_height);
    }

    // Inner wall cutaway:
    translate([0, 0, thickness])
      linear_extrude(height=outer_height + thickness)
      offset(delta=outer_spacing)
      polygon(points=outline);
  }
}

/******************************************************************************/
module inner_case() {
  difference() {
    // Inside shelf:
    translate([0, 0, thickness])
      linear_extrude(height=inner_height)
      offset(delta=outer_spacing)
      polygon(points=outline);

    // Cut out most of the floor leaving the shelf:
    translate([0, 0, thickness])
      linear_extrude(height=inner_height)
      offset(delta=-inner_spacing)
      offset(r=-rounding)
      polygon(points=outline);
  }
}

/******************************************************************************/
// Carve out space for a device and its opening.
//
//  The opening shape should come in as a child and should have its
//  center on the z axis.  This assumes the opening is in the center
//  of the device.
module back_wall_device(dims) {
  center_x_offset = wall_thickness + dims[3];

  translate([ center_x_offset - dims[0]/2
            , -(dims[1] + wall_thickness_no_padding)
            , thickness
            ])
  cube([ dims[0]
       , dims[1]
       , outer_height
       ]);

  // Cutout for the connector.
  translate([ center_x_offset
            , 0
            , thickness + inner_height - dims[4]
            ]) children();
}

/******************************************************************************/
module pro_micro_cutout() {
  connector_z = 4.0;
  connector_x = 9.0;
  board_y = 3;
  board_z = 1.5;

  // Right-hand pro micro is upside down.
  board_z_offset = print_side == "right"
    ? -(connector_z/2)
    : connector_z/2;

  back_wall_device(pro_micro) {
    translate([0, -(wall_thickness/2), 0])
      rotate([90, 0, 0])
      hull() {
        translate([-(connector_x/2 - connector_z/2), 0, 0])
        cylinder(d=connector_z, h=wall_thickness, center=true);
        translate([(connector_x/2 - connector_z/2), 0, 0])
        cylinder(d=connector_z, h=wall_thickness, center=true);
      }

    hull() { // This hull should allow printing without supports.
      translate([0, -(wall_thickness_no_padding), 0])
        cube([pro_micro[0]/2, wall_thickness_no_padding/2, connector_z], center=true);
      translate([0, board_y/2 - wall_thickness_no_padding, board_z_offset])
        cube([pro_micro[0], board_y, board_z], center=true);
    }
  }
}

/******************************************************************************/
  // Cut out for the TRRS jack:
module trrs_cutout() {
  back_wall_device(trrs) {
    translate([0, -(wall_thickness/2), 0])
      rotate([90, 0, 0])
      cylinder(d=6.5, h=wall_thickness, center=true);
  }
}

/******************************************************************************/
// Extra material to support the reset hole.
module reset_extra_material() {
  translate([ wall_thickness + reset_button[3]
            , -(wall_thickness + reset_button[4])
            , thickness
            ])
    cylinder(d=reset_button[5]*2, h=inner_height - reset_button[2]);
}

/******************************************************************************/
// Cut out a hole for the reset pin.
module reset_cutout() {
  translate([wall_thickness + reset_button[3], 0, 0])
    union() {
      // Thin hole so you can push the rest button:
      translate([0, -(wall_thickness + reset_button[4]), 0])
        cylinder(d=reset_button[5], h=outer_height);

      // Hole for the reset to rest in:
      translate([ 0
                , -(wall_thickness_no_padding + reset_button[1]/2)
                , thickness + inner_height - reset_button[2]/2
                ])
        cube([ reset_button[0]
             , reset_button[1]
             , reset_button[2]
             ], center=true);
  }
}

/******************************************************************************/
// There's one diode that's along the edge of the board that we need
// to account for:
module edge_diode_cutout() {
  diode_cutout_x = 12.75;
  diode_cutout_y = shelf_width;

  translate([ 19.0 + (diode_cutout_x/2)
            , -85 // FIXME: this should come from the outline array.
            , thickness + inner_height - 0.5
            ])
     rotate([0, 0, 6])
     cube([ diode_cutout_x
          , diode_cutout_y
          , 2
          ], center=true);
}

/******************************************************************************/
module bolts() {
  locations = [
    // Upper-left corner:
    [bolt_inset, -bolt_inset],

    // Upper-right corner:
    [outline[1][0] - bolt_inset, -bolt_inset],

    // Lower-right corner:
    [ outline[3][0] + (outline[2][0] - outline[3][0])/2,
    , outline[3][1] + (outline[2][1] - outline[3][1])/2 + 1.0,
    ],
  ];

  translate([wall_thickness, -wall_thickness , 0]) union() {
    for (i = locations) {
      translate(i) children();
    }
  }
}

/******************************************************************************/
// These are the cutouts.
module case_bolt_holes() {
  hole_height = thickness + inner_height;

  bolts() hull() {
    translate([0, 0, hole_height/2])
      cylinder(d=bolt_shaft, h=hole_height, center=true);
    translate([0, 0, bolt_recess/2])
      cylinder(d=bolt_size[0] + 4.5, h=bolt_recess, center=true);
  }
}

/******************************************************************************/
// Add a little material around the bolt holes so the bolt holes are
// completely encased in material.
module case_bolt_extra_material() {
  height = thickness + inner_height;

  bolts() {
    translate([0, 0, 0])
      cylinder(d=bolt_shaft*1.75, h=height);
  }
}

/******************************************************************************/
module magnet(depth) {
  cylinder(d=magnet_diameter,
           h=max(depth, magnet_depth),
           center=true);
}

/******************************************************************************/
module magnet_holes(width=case_width, extra_move=0) {
  length = thickness;
  middle = width/2;
  x_move = width/2 - length/2 - thickness*2 + extra_move + magnet_depth;

  translate([ 0
            , -35.00
            , (magnet_diameter/2) + (outer_height - (outer_height/4)) - 1.0
            ])
    union() {
    translate([middle + x_move, 0, 0])
      rotate([0, 90, 0])
      magnet(length);

    translate([middle - x_move, 0, 0])
      rotate([0, 90, 0])
      magnet(length);
  }
}

/******************************************************************************/
module case() {
  difference() {
    union() {
      // Put the case back on the origin.  All the offsets above moved
      // it around a bit.
      translate([ outer_spacing + wall_thickness_no_padding
                , -(outer_spacing + wall_thickness_no_padding)
                , 0
                ]) { outer_case();
                     inner_case();
                   }

      // Extra material:
      case_bolt_extra_material();
      reset_extra_material();
    }

    // Now cut out some material for various devices:
    pro_micro_cutout();
    trrs_cutout();
    reset_cutout();
    edge_diode_cutout();
    case_bolt_holes();

    // Optional holes for magnets.
    if (feature_magnets)
      magnet_holes(case_width);
  }
}

/******************************************************************************/
module top_studs(cutout=false) {
  height = outer_height + thickness - bolt_recess - 1.0;

  if (cutout) {
    bolts() translate([0, 0, thickness/2])
            cylinder(d=bolt_size[0] - 0.25, h=height + 1.0);
  } else {
    bolts() cylinder(d=bolt_shaft-0.15, h=height);
  }
}

/******************************************************************************/
module thumb_key_cutout(key_shape, key_dims, depth) {
 translate([ key_dims[0]
           , -key_dims[1]
           , depth/2
           ])
    rotate([0, 0, key_dims[2]])
    cube([ key_shape[0] + key_shape[2]
         , key_shape[1] + key_shape[3]
         , depth
         ], center=true);
}

/******************************************************************************/
module top_plate() {
  depth = inner_depth - board_thickness - 0.5;
  cut_depth = switch_height;

  // This translate means all measurements made outside the union will
  // be relative to the circuit board.  This makes it easier to make
  // measurements.
  translate([ outer_spacing + wall_thickness_no_padding
            , -(outer_spacing + wall_thickness_no_padding)
            , 0
            ])
    difference() {
      union() {
        // Main plate for the top:
        linear_extrude(height=thickness)
          offset(delta=outer_spacing + thickness)
          offset(r=+rounding) offset(delta=-rounding)
          polygon(points=outline);

        // Ledge that holds the board down.
        difference() {
          translate([0, 0, thickness])
            linear_extrude(height=depth)
            offset(delta=outer_spacing/2)
            polygon(points=outline);

          translate([0, 0, thickness])
            linear_extrude(height=depth)
            offset(delta=-board_overlap)
            polygon(points=outline);
        }
      }

      // Most of the keys:
      linear_extrude(height=cut_depth)
      offset(delta=0.75) // Give some breathing room.
      offset(r=-rounding/2) offset(delta=+rounding/2)
      offset(r=+rounding/2) offset(delta=-rounding/2)
      polygon(points=top_cut);

      // And then the thumb keys:
      thumb_key_cutout(cap_2U,   thumb_1, cut_depth);
      thumb_key_cutout(thumb_1U, thumb_2, cut_depth);
      thumb_key_cutout(thumb_1U, thumb_3, cut_depth);
    }
}

/******************************************************************************/
module top() {
  difference() {
    union() {
      top_plate();
      top_studs();
    }

    top_studs(true);
  }
}

/******************************************************************************/
module cover_base() {
  // This translate means all measurements made outside the union will
  // be relative to the circuit board.  This makes it easier to make
  // measurements.
  translate([ outer_spacing + wall_thickness_no_padding*2
            , -(outer_spacing + wall_thickness_no_padding)
            , 0
            ])
    difference() {
      cover_wall(cover_outer_height);

      translate([0, 0, thickness])
        linear_extrude(height=cover_outer_height)
        offset(delta=outer_spacing)
        offset(r=+rounding) offset(delta=-rounding)
        polygon(points=outline);

      translate([0, 0, cover_outer_height - cover_wall_height - 0.25])
        linear_extrude(height=cover_wall_height+1.0)
        offset(delta=outer_spacing+thickness+0.25)
        offset(r=+rounding) offset(delta=-rounding)
        polygon(points=outline);
  }
}

/******************************************************************************/
module cover() {
  cover_width = max([ for (i = outline) i[0] ]) +
    (outer_spacing + thickness*2)*2;

  difference() {
    cover_base();

    if (feature_magnets) {
      translate([0, 0, cover_wall_height/2])
      magnet_holes(cover_width, thickness);
    }
  }
}

/******************************************************************************/
// For test fitting:
module board() {
  board_height = 1.6;

  color("ForestGreen")
    translate([0, 0, board_height + inner_height + thickness])
    linear_extrude(height=board_height)
    polygon(points=outline);
}

/******************************************************************************/
if (print_part == "case") {
  if (print_side == "right") {case();}
  else {mirror([1, 0, 0]) case();}
} else if (print_part == "top") {
  if (print_side == "right") {mirror([1, 0, 0]) top();}
  else {top();}
} else if (print_part == "cover") {
  if (print_side == "right") {mirror([1, 0, 0]) cover();}
  else {cover();}
}
