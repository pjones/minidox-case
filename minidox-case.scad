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
// These are set from the command line:
print_side = "right";           /* right or left */
print_part = "case";            /* case, inset, or cover */

/******************************************************************************/
// Optional features:
feature_cover = false;           /* Will you use a cover? */

/******************************************************************************/
// Settings you may want to tweak:
inner_depth = 9.0;              /* How high the case will come up from the board upward. */
inner_spacing = 2.25;           /* Space under the board to hold it. */
outer_spacing = 1.0;            /* Extra space in the case for the board to fit in. */
board_to_caps = 22.0;           /* Total height from board up to the key caps. */
cover_inner_space = 10.0;       /* Extra space in the cover for cables, etc. */
bolt_size = [3.0, 16.0];        /* M3x16 */
bolt_inset = 2.5;               /* From wall to center of bolt. */
bolt_shaft_wall = 2.0;          /* Wall thickness of shaft bolt screws into. */
bolt_recess = 4.0;              /* How deep bolts go into the bottom. */

/******************************************************************************/
rounding = 2.25;                /* How much rounding to apply. */
thickness = 4;                  /* Wall thickness. */

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
            , 67.05
            , print_side == "right" ? 1.3 : 4.33
            ];

trrs = [ 12.0
       , 12.0
       , 5.23
       , 18.90
       , 2.16
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
// Other computed values:
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
module outer_case() {
  difference() {
    union() {
      // Outer wall:
      linear_extrude(height=outer_height + thickness)
        offset(delta=outer_spacing + thickness)
        offset(r=+rounding) offset(delta=-rounding)
        polygon(points=outline);

      // Lower outer wall for case to sit on:
      if (feature_cover) {
        linear_extrude(height=outer_height/2 + thickness)
          offset(delta=outer_spacing + thickness*2)
          offset(r=+rounding) offset(delta=-rounding)
          polygon(points=outline);
      }
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
  connector_z = 3.5;
  board_y = 3;
  board_z = 1.5;

  // Right-hand pro micro is upside down.
  board_z_offset = print_side == "right"
    ? -(connector_z/2)
    : connector_z/2;

  back_wall_device(pro_micro) {
    translate([0, -(wall_thickness/2), 0])
     cube([9, wall_thickness, connector_z], center=true);

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
}
