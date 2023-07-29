include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;

extrude_width = 0.5;
extrude_height = 0.2;
wall_thickness = extrude_width*3;

screw_post_id = 2.9; // screw an m3 into
screw_post_od = screw_post_id + wall_thickness*2*2;
screw_post_height = 6;

vertical_extrusion_pos_x = 200/2-58-15/2;
echo("vertical_extrusion_pos_x: ", vertical_extrusion_pos_x);

sheet_thickness = 5;
dist_front_to_back = 37+15-sheet_thickness;

echo("dist_front_to_back: ", dist_front_to_back);

rpi = RPI3;
mcu = BTT_SKR_MINI_E3_V2_0;

pi_width = pcb_width(rpi);
pi_length = pcb_length(rpi);

mcu_width = pcb_width(mcu);
mcu_length = pcb_length(mcu);

z_rail_spacing = 200-58*2-15;
//mcu_mount_offset = 0;
//mcu_mount_difference_x = 25;
//mcu_spacing = z_rail_spacing + mcu_mount_difference_x;

mcu_x_offsets = [
  -12,
  12,
];

electronics_mounting_hole_pos_y = [
  // 22,
  // 85,
  22,
  100,
];

mcu_pos_x = [
  mcu_x_offsets[0] - z_rail_spacing/2,
  mcu_x_offsets[1] + z_rail_spacing/2,
];

echo("pi_width: ", pi_width);

module mount_assembly() {
  module position_mcus() {
    //for(x=[50,-40]) {
    //for(x=[mcu_mount_offset-mcu_spacing/2,mcu_mount_offset+mcu_spacing/2]) {
    //  translate([x,-200/2+15+4+mcu_length/2,mcu_mount_thickness+mcu_bevel_height]) {
    //    rotate([0,0,90]) {
    //      rotate([0,0,0]) {
    //        children();
    //      }
    //    }
    //  }
    //}
    for(x=mcu_pos_x) {
      //translate([x,-200/2+15+4+mcu_length/2,mcu_mount_thickness+mcu_bevel_height]) {
      //translate([x,-200/2+15,mcu_mount_thickness+mcu_bevel_height]) {
      translate([x,-200/2+15,0]) {
        children();
      }
    }
    /*
    for(x=[75,-75]) {
      translate([x,-20,0]) {
        rotate([0,0,90]) {
          children();
        }
      }
    }
    */
  }

  module position_rpi_mount() {
    translate([-200/2,-200/2+pi_length/2,dist_front_to_back]) {
      children();
    }
  }

  module position_mcu_screw_holes() {
    for(pos=hole_pos) {
      translate(pos) {
        children();
      }
    }
  }

  // mock out back of v0
  % color("#444") for(x=[left,right]) {
    nema14_side = 36;
    nema14_len = 52;
    translate([x*(200/2-nema14_side/2),200/2-nema14_len/2,dist_front_to_back-nema14_side/2]) {
      cube([nema14_side,nema14_len,nema14_side],center=true);
    }
  }

  position_mcus() {
    mcu_mount();
  }

  position_rpi_mount() {
    //% pcb(rpi);
  }

  position_rpi_mount() {
    rpi_mount();
  }
  % translate([0,0,-15/2+dist_front_to_back]) {
    for(x=[left,right]) {
      translate([x*(200+15)/2,0,0]) {
        rotate([90,0,0]) {
          extrusion(E1515, 200);
        }

        for(z=[top,bottom]) {
          translate([0,z*(200/2-15/2),-15/2-200/2]) {
            extrusion(E1515, 200);
          }
        }
      }
    }
  }

  % for(y=[front,rear]) {
    translate([0,y*(200/2-15/2),15/2-sheet_thickness]) {
      rotate([0,90,0]) {
        extrusion(E1515, 200);
      }
    }
  }

  % for(x=[left,right]) {
    translate([x*vertical_extrusion_pos_x,0,-sheet_thickness-15/2]) {
      rotate([90,0,0]) {
        extrusion(E1515, 200);
      }
    }
  }

  translate([0,148.5,-sheet_thickness/2]) {
    color("#999", 0.2) linear_extrude(height = sheet_thickness, center = true, convexity = 10) {
      // import(file = "./Mid_Panel.dxf");
    }
  }
  % color("#999", 0.2) translate([0,0,-sheet_thickness/2]) {
    // cube([200+15*2,200-15*2,sheet_thickness],center=true);
  }

  module body() {
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module mcu_mount(side=0) {
  dist_from_extrusion = 6;

  mount_thickness = 4;
  mcu_post_id = 3;
  mcu_post_od = mcu_post_id + extrude_width*2*2*2;
  mcu_post_height = 8;
  mcu_post_bevel_height = 2;

  mcu_hole_pos = [
    [64.47/2,mcu_length/2-5/2,0],
    [-mcu_width/2+5.58/2,-mcu_length/2+20.3+62.15,0],
    [-mcu_width/2+5.58/2,-mcu_length/2+20.3,0],
    [-mcu_width/2+34.98+5.58/2,-mcu_length/2+5/2,0],
  ];

  mount_plate_spacing_x = mcu_x_offsets[1]-mcu_x_offsets[0];
  mount_plate_spacing_y = electronics_mounting_hole_pos_y[1]-electronics_mounting_hole_pos_y[0];
  mount_plate_center_pos_x = 0;
  mount_plate_center_pos_y = electronics_mounting_hole_pos_y[0]+mount_plate_spacing_y/2;
  mount_plate_outer_x = mount_plate_spacing_x+mcu_post_od;
  mount_plate_outer_y = mount_plate_spacing_y+mcu_post_od;
  mount_plate_inner_x = mount_plate_outer_x-mcu_post_od*2;
  mount_plate_inner_y = mount_plate_outer_y-mcu_post_od*2;

  mount_screw_head_od = 6;
  mount_screw_body_od = mount_screw_head_od+extrude_width*2*2*2;

  module position_mounting_holes() {
    for(x=mcu_x_offsets,y=electronics_mounting_hole_pos_y) {
      translate([x,y,0]) {
        children();
      }
    }
  }

  module position_mcu_holes() {
    position_mcu() {
      for(p=mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }
  }

  module position_mcu() {
    translate([0,mcu_length/2+dist_from_extrusion,0]) {
      children();
    }
  }

  position_mcu() {
    translate([0,0,mcu_post_height]) {
      rotate([0,0,90]) {
        % pcb(mcu);
      }
    }
  }

  module body() {
    hull() {
      translate([0,0,mount_thickness/2]) {
        position_mcu() {
          translate(mcu_hole_pos[0]) {
            hole(mcu_post_od,mount_thickness,resolution);
          }
        }
        translate([mcu_x_offsets[1],electronics_mounting_hole_pos_y[1],0]) {
          hole(mcu_post_od,mount_thickness,resolution);
        }
      }
    }
    hull() {
      translate([0,0,mount_thickness/2]) {
        position_mcu() {
          translate(mcu_hole_pos[1]) {
            hole(mcu_post_od,mount_thickness,resolution);
          }
        }
        //translate([mcu_x_offsets[0],electronics_mounting_hole_pos_y[1],0]) {
        translate([mcu_x_offsets[0],dist_from_extrusion+mcu_length/2+mcu_hole_pos[1][y],0]) {
          hole(mcu_post_od,mount_thickness,resolution);
        }
      }
    }
    hull() {
      translate([0,0,mount_thickness/2]) {
        position_mcu() {
          translate(mcu_hole_pos[2]) {
            hole(mcu_post_od,mount_thickness,resolution);
          }
        }
        translate([mcu_x_offsets[0],dist_from_extrusion+mcu_length/2+mcu_hole_pos[2][y],0]) {
          hole(mcu_post_od,mount_thickness,resolution);
        }
      }
    }
    hull() {
      translate([0,0,mount_thickness/2]) {
        position_mcu() {
          translate(mcu_hole_pos[3]) {
            hole(mcu_post_od,mount_thickness,resolution);
          }
        }
        translate([mcu_hole_pos[3][x],electronics_mounting_hole_pos_y[0],0]) {
          hole(mcu_post_od,mount_thickness,resolution);
        }
      }
    }
    translate([mount_plate_center_pos_x,mount_plate_center_pos_y,mount_thickness/2]) {
      rounded_cube(mount_plate_outer_x,mount_plate_outer_y,mount_thickness,mcu_post_od);
    }
    position_mounting_holes() {
      translate([0,0,mount_thickness/2]) {
        hole(mount_screw_body_od,mount_thickness,resolution);
      }
    }
    position_mcu_holes() {
      post_straight_height = mcu_post_height-mcu_post_bevel_height;
      translate([0,0,post_straight_height/2]) {
        hole(mcu_post_od,post_straight_height,resolution);
      }
      translate([0,0,mcu_post_height]) {
        bevel(mcu_post_od, mcu_post_id+extrude_width*2*2, mcu_post_bevel_height);
      }
    }
  }

  module holes() {
    position_mounting_holes() {
      hole(3.2,30,resolution);
      translate([0,0,3+10]) {
        hole(mount_screw_head_od,20,resolution);
      }
    }
    position_mcu_holes() {
      hole(mcu_post_id,30,resolution);
    }
    translate([mount_plate_center_pos_x,mount_plate_center_pos_y,mount_thickness/2]) {
      rounded_cube(mount_plate_inner_x,mount_plate_inner_y,mount_thickness+1,2);
    }
  }

  difference() {
    body();
    holes();
  }
}

module rpi_mount() {
  //pi_dist_from_back = 15/2;
  pi_dist_from_back = 3;
  pi_dist_from_extrusion = 15;
  post_height = 6;
  bevel_height = 1.6;
  arm_thickness = 3;

  pi_hole_spacing_x = 58;
  pi_hole_spacing_y = 49;
  pi_hole_from_edge = 3.5;
  pi_hole_center_pos_x = -pi_length/2+pi_hole_from_edge+pi_hole_spacing_x/2;
  rpi_screw_hole_diam = 2.4;

  post_id = rpi_screw_hole_diam;
  post_od = post_id + 0.5*2*2*2;

  arm_support_thickness = 0.5*2;
  extrusion_mount_length = pi_hole_spacing_x+post_od+arm_support_thickness*2;

  extrusion_mount_thickness = extrude_width*3*2;
  bevel_tip = post_id + 0.4*2*2;

  extrusion_mount_hole_diam = 3+0.2;
  extrusion_mount_nut_side = 6.2+0.2; // allow for a hex nut to fit (rather than ~5.5 flat to flat square nut)

  overall_height = pi_dist_from_back+pcb_thickness(rpi)+post_height+arm_thickness;

  extrusion_mount_hole_spacing = pi_hole_spacing_x-post_od*2;

  module position_rpi() {
    translate([pi_width/2+pi_dist_from_extrusion,pi_length/2-pi_hole_spacing_x/2-pi_hole_from_edge,-pi_dist_from_back]) {
      rotate([0,0,90]) {
        rotate([180,0,0]) {
          children();
        }
      }
    }
  }

  module position_rpi_screw_holes() {
    position_rpi() {
      pcb_hole_positions(rpi) {
        translate([0,0,pcb_thickness(rpi)]) {
          rotate([180,0,0]) {
            children();
          }
        }
      }
    }
  }

  module position_extrusion_mount_holes() {
    for(y=[front,rear]) {
      translate([extrusion_mount_thickness,y*extrusion_mount_hole_spacing/2,-15/2]) {
        rotate([0,90,0]) {
          children();
        }
      }
    }
  }

  module body() {
    translate([extrusion_mount_thickness/2,0,-overall_height/2]) {
      rounded_cube(extrusion_mount_thickness,extrusion_mount_length,overall_height, extrusion_mount_thickness);
    }

    // be able to locate the mount against the extrusion
    extrusion_lip_width = 1;
    extrusion_lip_thickness = 2;
    extrusion_lip_length = 5;
    tab_locations_y = [
      extrusion_mount_hole_spacing/2+extrusion_mount_nut_side/2+extrusion_lip_length/2,
      extrusion_mount_hole_spacing/2-extrusion_mount_nut_side/2-extrusion_lip_length/2,
      -extrusion_mount_hole_spacing/2+extrusion_mount_nut_side/2+extrusion_lip_length/2,
      -extrusion_mount_hole_spacing/2-extrusion_mount_nut_side/2-extrusion_lip_length/2,
    ];
    /*
    for(y=tab_locations_y) {
      translate([0,y,-15/2+3/2-extrusion_lip_thickness/2-0.1]) {
        hull() {
          translate([extrusion_mount_thickness/2-extrusion_lip_width,0,0]) {
            rounded_cube(extrusion_mount_thickness,extrusion_lip_length,extrusion_lip_thickness, extrusion_lip_width);
          }
          translate([extrusion_mount_thickness/2,0,-extrusion_lip_width]) {
            rounded_cube(extrusion_mount_thickness,extrusion_lip_length,extrusion_lip_thickness, extrusion_lip_width);
          }
        }
      }
    }
    */
    /*
    for(y=[front,rear]) {
      extrusion_lip_width = 1.5;
      extrusion_lip_thickness = 2;
      extrusion_lip_length = 10;
      translate([0,y*extrusion_mount_hole_spacing/2,0]) {
        hull() {
          translate([extrusion_mount_thickness/2-extrusion_lip_width,0,-15-extrusion_lip_thickness/2-0.2]) {
            rounded_cube(extrusion_mount_thickness,extrusion_lip_length,extrusion_lip_thickness, extrusion_mount_thickness);
          }
          translate([extrusion_mount_thickness/2,0,-overall_height+extrusion_lip_thickness/2]) {
            rounded_cube(extrusion_mount_thickness,extrusion_lip_length,extrusion_lip_thickness, extrusion_mount_thickness);
          }
        }
      }
    }
    */

    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([0,pi_hole_spacing_x/2,-overall_height]) {
          post_remaining = post_height-bevel_height;
          for(x=[left,right]) {
            translate([pi_dist_from_extrusion+pi_hole_from_edge+pi_hole_spacing_y/2+x*(pi_hole_spacing_y/2),0,arm_thickness]) {
              translate([0,0,post_remaining/2]) {
                hull() {
                  hole(post_od,post_remaining,resolution);
                  translate([0,post_od/2+arm_support_thickness/2,0]) {
                    cube([post_od,arm_support_thickness,post_remaining],center=true);
                  }
                }
              }
              translate([0,0,post_height]) {
                bevel(post_od, bevel_tip, bevel_height);
              }
            }
          }
          translate([0,post_od/2+arm_support_thickness/2,arm_thickness+post_remaining/2]) {
            hull() {
              translate([extrusion_mount_thickness/2,0,0]) {
                cube([0.1,arm_support_thickness,post_remaining],center=true);
              }
              translate([pi_dist_from_extrusion+pi_hole_from_edge+pi_hole_spacing_y+post_od/2+arm_support_thickness/2,0,0]) {
                hole(arm_support_thickness,post_remaining,resolution);
              }
            }
          }
          translate([0,0,arm_thickness/2]) {
            hull() {
              translate([extrusion_mount_thickness/2,arm_support_thickness/2,0]) {
                cube([0.1,post_od+arm_support_thickness,arm_thickness],center=true);
              }
              translate([pi_dist_from_extrusion+pi_hole_from_edge+pi_hole_spacing_y,0,0]) {
                hole(post_od,arm_thickness,resolution);
                translate([0,post_od/2+arm_support_thickness/2,0]) {
                  rounded_cube(post_od+arm_support_thickness*2,arm_support_thickness,arm_thickness,arm_support_thickness);
                }
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    position_rpi_screw_holes() {
      hole(post_id,40,resolution);
    }
    position_extrusion_mount_holes() {
      hole(extrusion_mount_hole_diam,extrusion_mount_thickness*4,8);

      translate([0,0,-5]) {
        % hole(5.5,3,6);
        % hole(5.5,3,4);
      }
    }
  }

  difference() {
    body();
    holes();
  }

  position_rpi() {
    translate([0,0,-0.2]) {
      % pcb(rpi);
    }
  }
}

mount_assembly();

translate([0,0,200]) {
  // rpi_mount();
}
