include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>; 

magnet_diam = 6;
magnet_thickness = 3;
magnet_cavity_diam = magnet_diam+0.1;
magnet_cavity_height = magnet_thickness+0.2;
extrude_width = 0.5;
extrude_height = 0.2;

m2_head_cavity = 3.3+0.3; // 0.3 is allowance
m2_thread_into_plastic = 1.8;
m3_thread_into_plastic = 2.8;
//fan_heatset_diam = 5;
fan_heatset_diam = m3_thread_into_plastic;
//fan_heatset_height = 3;
fan_heatset_height = 6;

tpu_diam = 1.75;
tpu_cavity_diam = tpu_diam+0.3;
squish_pct = 0.2;
submerge_pct = 0.7;

xy_seal_overhead = 4.5;
magnet_overhead_x = magnet_diam + extrude_width*2;

hepa_filter_height_tolerance = 4;
hepa_filter_xy_tolerance = 1;
// filter is advertised as 80x40, but is actually ~81.5x~40.8
// the filter has some foam that seems okay to compress a little
hepa_width = 81+hepa_filter_xy_tolerance;
hepa_depth = 40+hepa_filter_xy_tolerance;
hepa_thickness = 15+hepa_filter_height_tolerance;

//rounded_diam = xy_seal_overhead*2;
//rounded_diam = magnet_cavity_diam+extrude_width*3*2;
rounded_diam = magnet_cavity_diam+extrude_width*4*2+0.3;
echo("rounded_diam: ", rounded_diam);

stack_width = 105;
stack_depth = 50; //hepa_depth + rounded_diam;

cavity_rounded = 4;

//extrusion_mount_depth = 20; // larger size
extrusion_mount_stickout = 10; // v0 size
extrusion_mount_depth = 15; // v0 size
extrusion_mount_offset_y = 0; // rear*3.5; // if not mounted flush with outside of extrusion, not supported yet
extrusion_mount_offset_z = top*5.6; // if not mounted flush with top of extrusion
extrusion_mount_thickness = 3;
extrusion_mount_wall_thickness = extrude_width*3*2;

//integrated_filter_fan_height = 0;
integrated_filter_fan_height = hepa_thickness+hepa_filter_height_tolerance;

fan_side = 40;
fan_height = 20;
space_below_fans = max(3,extrusion_mount_offset_z+3); // make room for fan screw heads
plenum_height = 20;
hepa_filter_lip_height = 1;
hepa_filter_lip_width = 1.5;
hepa_stack_height = hepa_thickness + hepa_filter_lip_height + hepa_filter_height_tolerance;
lid_stack_height = magnet_thickness+1;
//fan_stack_height = fan_height+plenum_height+space_below_fans+hepa_thickness+hepa_filter_height_tolerance;
fan_stack_height = fan_height+plenum_height+space_below_fans+integrated_filter_fan_height;
carbon_stack_height = 45+hepa_filter_lip_height;
carbon_hepa_stack_height = 45+hepa_thickness+hepa_filter_height_tolerance+hepa_filter_lip_height;
carbon_cannister_gap = 0.4;
carbon_cannister_container_height = carbon_stack_height-hepa_filter_lip_height-carbon_cannister_gap;
carbon_cannister_container_width = hepa_width-carbon_cannister_gap;
carbon_cannister_container_depth = hepa_depth-carbon_cannister_gap;

echo("stack_width: ", stack_width);
echo("stack_depth: ", stack_depth);
echo("full stack height: ", fan_stack_height+carbon_stack_height+hepa_stack_height+lid_stack_height);
echo("hepa_stack_height: ", hepa_stack_height);
echo("simplified stack height: ", fan_stack_height + carbon_hepa_stack_height + lid_stack_height);

//echo("full stack height: ", fan_stack_height+carbon_stack_height+lid_stack_height);

module seal_and_magnet_cavity(side=top,width=stack_width,depth=stack_depth) {
  resolution = 16;
  squish_pct = 0.2;

  // how to retain the TPU filament?
  // * make the cavity ovular?
  // * make the cavity n* the diameter?

  module corner_curve_max_xy() {
    rotate([0,0,-45]) {
      translate([0,xy_seal_overhead/2,0]) {
        cube([0.1,tpu_cavity_diam*0.2,tpu_cavity_diam+0.2*2],center=true);
      }
    }
    difference() {
      rotate_extrude($fn=resolution*2,convexity=3) {
        translate([xy_seal_overhead/2,0,0]) {
          scale([1-squish_pct,1,1]) {
            accurate_circle(tpu_cavity_diam,resolution);
          }
        }
      }
      translate([-xy_seal_overhead/2,0,0]) {
        cube([xy_seal_overhead,xy_seal_overhead*2,tpu_cavity_diam*3],center=true);
      }
      translate([xy_seal_overhead/2,-xy_seal_overhead/2,0]) {
        cube([xy_seal_overhead,xy_seal_overhead,tpu_cavity_diam*3],center=true);
      }
    }
  }

  /*
  rotate_extrude($fn=resolution*2,convexity=3) {
    translate([fan_hole_opening/2+xy_seal_overhead/2,-tpu_cavity_diam/2+tpu_cavity_diam*0.65,0]) {
      scale([1-squish_pct,1,1]) {
        accurate_circle(tpu_cavity_diam,resolution);
      }
    }
  }
  */

  seal_depth = depth-xy_seal_overhead*2;
  seal_width = width-xy_seal_overhead*2;
  for(x=[left,right]) {
    magnet_area_y = depth/2-rounded_diam/2;
    magnet_area_x = width/2-rounded_diam/2;
    //translate([x*(width/2-magnet_cavity_diam/2-extrude_width*3),0,0]) {
    translate([x*(magnet_area_x),0,0]) {
      // magnets
      for(y=[front,front*0.45,rear*0.45,rear]) {
        translate([0,y*magnet_area_y,0]) {
          hole(magnet_cavity_diam,magnet_cavity_height*2,resolution);
        }
      }

      // m2 socket head screw registration pin
      //for(y=[front*0.5,rear*0.5]) {
      for(y=[0]) {
        translate([0,y*magnet_area_y,0]) {
          if (side > 0) {
            // top
            hole(m2_thread_into_plastic, 6*2, 16);
          } else {
            // bottom
            hole(m2_head_cavity, 3*2, 16);
          }
        }
      }
    }
  }
  //if (side==top) {
  if (0) {
    submerge_by = (side == top) ? tpu_cavity_diam*submerge_pct : extrude_height;
    echo("submerge_by: ", submerge_by);
    translate([0,0,side*(tpu_cavity_diam/2-submerge_by)]) {
      for(x=[left,right]) {
        translate([x*(width/2-xy_seal_overhead/2),0,0]) {
          rotate([90,0,0]) {
            scale([1-squish_pct,1,1]) {
              hole(tpu_cavity_diam,seal_depth+0.1,resolution);
            }
          }
        }
      }
      for(y=[front,rear]) {
        translate([0,y*(depth/2-xy_seal_overhead/2),0]) {
          rotate([0,90,0]) {
            scale([1,1-squish_pct,1]) {
              hole(tpu_cavity_diam,seal_width+0.1,resolution);
            }
          }
        }
      }
      for(x=[left,right],y=[front,rear]) {
        mirror([x-1,0,0]) {
          mirror([0,y-1,0]) {
            translate([seal_width/2,seal_depth/2,0]) {
              //translate([0,0,-side*0.2]) {
                corner_curve_max_xy();
              //}
              //corner_curve_max_xy();
              intersection() {
                translate([xy_seal_overhead,xy_seal_overhead,0]) {
                  //cube([xy_seal_overhead*2,xy_seal_overhead*2,tpu_cavity_diam*3],center=true);
                }
                //translate([x*xy_seal_overhead,-y*xy_seal_overhead,0]) {
                //}
              }
            }
          }
        }
      }
    }
  }

  translate([0,0,side*1]) {
    % difference() {
      cube([hepa_width+10,hepa_depth+10,1],center=true);
      cube([hepa_width,hepa_depth,1.1],center=true);
    }
  }
}

module beveled_cavity(height,bottom_thickness) {
  rounded_diam = 2;
  wall_thickness = extrude_width*3*2;

  cavity_depth = stack_depth-wall_thickness*2;
  delta = cavity_depth-hepa_depth;

  cavity_width = hepa_width+delta;

  wide_height = height-(delta)*2;
  narrow_height = height-bottom_thickness*2;

  module body() {
    translate([0,0,height/2]) {
      rounded_cube(hepa_width,hepa_depth,height,rounded_diam);
    }

    hull() {
      translate([0,0,-height/2+bottom_thickness]) {
        translate([0,0,wide_height/2]) {
          rounded_cube(cavity_width,cavity_depth,wide_height,rounded_diam);
        }
        translate([0,0,narrow_height/2]) {
          rounded_cube(hepa_width,hepa_depth,narrow_height,rounded_diam);
        }
      }
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

// thought I could save some filament but it looks like it doesn't help much
// also, it looks goofy
/*
module base_stack(height) {
  wall_thickness = extrude_width*3*2;
  width = hepa_width+wall_thickness*2;
  depth = hepa_depth+wall_thickness*2;

  magnet_area_height = magnet_cavity_height+3;
  delta = max(stack_width-width,stack_depth-depth);
  narrow_height = magnet_area_height+delta*0.65;

  module body() {
    translate([0,0,0]) {
      rounded_cube(width,depth,height,rounded_diam);
    }

    for(z=[top,bottom]) {
      translate([0,0,z*height/2]) {
        hull() {
          translate([0,0,-z*magnet_area_height/2]) {
            rounded_cube(stack_width,stack_depth,magnet_area_height,rounded_diam);
          }
          translate([0,0,-z*narrow_height/2]) {
            rounded_cube(width,depth,narrow_height,rounded_diam);
          }
        }
      }
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}
*/

module fan_4020() {
  // 52.82 - 46.16
  // 3.33
  //translate([0,0,7]) {
  //translate([0,0,-12.5]) {
  translate([0,0,fan_height/2]) {
    x_adjust = 0;
    y_adjust = 0;
    z_adjust = 0;
    translate([x_adjust,y_adjust,z_adjust]) {
      import("turbo_fan_35x18.stl", convexity=2);
    }
  }
}

module fan_5015() {
  translate([0,0,-15/2]) {
    x_adjust = -44.25;
    y_adjust = 5.4;
    z_adjust = 100+15/2-0.44;
    translate([0,0,15]) {
      //import("5015_Blower_Fan.stl", convexity=0);
    }
    translate([x_adjust,y_adjust,z_adjust]) {
      //color("blue") import("Radial_Fan_50x15 v8.stl", convexity=2);
      import("Radial_Fan_50x15 v8.stl", convexity=2);
    }
  }
}

translate([120,0,0]) {
  //fan_4020();
}

module fan_stack() {
  fan_spacing = 3+40;
  fan_pos_z = -fan_stack_height/2+fan_height/2+space_below_fans;
  top_height = fan_stack_height/2-fan_pos_z-fan_height/2;
  //hepa_area_height = hepa_thickness+hepa_filter_height_tolerance;
  hepa_area_height = integrated_filter_fan_height;
  plenum_area_height = fan_stack_height/2-fan_pos_z-fan_height/2;
  fan_area_height = fan_pos_z+fan_height/2;

  cable_clearance = 3;

  fan_channel_height = 2;
  fan_hole_opening = 29;
  //fan_post_diam = 3.4+extrude_width*2*2*2;
  fan_post_diam = fan_heatset_diam+extrude_width*4*2;
  fan_post_height = 6.3;

  surround_wall_thickness = extrude_width*3*2;
  plenum_width = hepa_width-hepa_filter_lip_width*2;
  plenum_depth = hepa_depth-hepa_filter_lip_width*2;

  //shift_fan_x = -0.5;
  shift_fan_x = -1;

  module position_fan() {
    for(x=[left,right]) {
      translate([shift_fan_x+x*fan_spacing/2,0,fan_pos_z]) {
        children();
      }
    }
  }

  module position_extrusion_mount() {
    for(x=[left,right]) {
      mirror([x-1,0,0]) {
        translate([stack_width/2,stack_depth/2+extrusion_mount_offset_y,-fan_stack_height/2+extrusion_mount_offset_z]) {
          children();
        }
      }
    }
  }

  module position_fan_screws() {
    positions=[
      [[-35/2,35/2,0],0],
      [[35/2,35/2,0],0],
      [[35/2,-35/2,0],180],
    ];
    for(p=positions) {
      translate(p[0]) {
        rotate([0,0,p[1]]) {
          //debug_axes(1);
          children();
        }
      }
    }
    for(r=[225,315,45]) {
      rotate([0,0,r]) {
        translate([0,49.5/2,0]) {
          //children();
        }
      }
    }
  }

  module body() {
    translate([0,0,fan_stack_height/2-top_height/2]) {
      rounded_cube(stack_width,stack_depth,top_height,rounded_diam);
    }
    // rounded_cube(stack_width,stack_depth,fan_stack_height,rounded_diam);

    //% rounded_cube(stack_width,stack_depth,fan_stack_height,rounded_diam);
    position_fan() {
      position_fan_screws() {
        translate([0,0,fan_height/2-fan_post_height/2+1]) {
          hole(fan_post_diam,fan_post_height+1,resolution);
          translate([0,fan_post_diam/2,0]) {
            cube([extrude_width*3*2,fan_post_diam,fan_post_height+1],center=true);
          }
        }
      }
    }

    surround_height = fan_stack_height - top_height;
    difference() {
      union() {
        translate([0,0,-fan_stack_height/2+surround_height/2+1]) {
          rounded_cube(stack_width,stack_depth,surround_height+2,rounded_diam);
        }
        position_extrusion_mount() {
          translate([0,front*extrusion_mount_depth/2,extrusion_mount_thickness/2]) {
            // flat
            hull() {
              translate([-extrusion_mount_stickout,0,0]) {
                rounded_cube(extrusion_mount_wall_thickness,extrusion_mount_depth,extrusion_mount_thickness,extrusion_mount_wall_thickness);
              }
              translate([extrusion_mount_stickout/2,0,0]) {
                rounded_cube(extrusion_mount_stickout,extrusion_mount_depth,extrusion_mount_thickness,extrusion_mount_wall_thickness);
              }
            }
            // braces
            for(y=[front,rear]) {
              hull() {
                translate([0,y*(extrusion_mount_depth/2-extrusion_mount_wall_thickness/2),0]) {
                  translate([extrusion_mount_stickout/2,0,0]) {
                    rounded_cube(extrusion_mount_stickout,extrusion_mount_wall_thickness,extrusion_mount_thickness,extrusion_mount_wall_thickness);
                  }
                  translate([-extrusion_mount_stickout,0,extrusion_mount_stickout-extrusion_mount_thickness/2]) {
                    hole(extrusion_mount_wall_thickness,extrusion_mount_depth*2,resolution);
                  }
                }
              }
            }
          }
          translate([0,front*extrusion_mount_depth/2,-15/2]) {
            rotate([0,90,0]) {
              % extrusion_makerbeam_xl(stack_width*0.25);
            }
          }
        }
      }
      union() {
        translate([0,0,-fan_stack_height/2+surround_height/2+1]) {
          rounded_cube(stack_width-surround_wall_thickness*2,stack_depth-surround_wall_thickness*2,surround_height+4,rounded_diam-surround_wall_thickness*2);
        }
      }
    }

  }

  module bottom_of_hepa(side) {
    width_minus_lip = hepa_width/2-hepa_filter_lip_width;
    
    translate([side*(width_minus_lip/2),0,fan_stack_height/2]) {
      rounded_cube(width_minus_lip,hepa_depth-hepa_filter_lip_width*2,(hepa_area_height+hepa_filter_lip_width)*2,2);
    }
  }

  module holes() {
    // reduce bridging between
    hull() {
      bottom_of_hepa(left);
      bottom_of_hepa(right);
      translate([0,0,fan_stack_height/2-hepa_area_height]) {
        //rounded_cube(plenum_width,plenum_depth,1,rounded_diam,8);

        bridge_width = 0.01;
        translate([0,0,-plenum_height+fan_channel_height+1]) {
          cube([fan_spacing,bridge_width,2],center=true);
        }
      }
    }
    for(x=[left,right]) {
      // suction hole and TPU seal cavity
      translate([x*(fan_spacing/2),0,fan_pos_z+fan_height/2]) {
        hole(fan_hole_opening,fan_channel_height*2+1,resolution*2);

        rotate_extrude($fn=resolution*2,convexity=3) {
          translate([fan_hole_opening/2+xy_seal_overhead/2,-tpu_cavity_diam/2+tpu_cavity_diam*0.65,0]) {
            scale([1-squish_pct,1,1]) {
              accurate_circle(tpu_cavity_diam,resolution);
            }
          }
        }
      }
      // plenum
      hull() {
        bottom_of_hepa(x);
        translate([x*(plenum_width/4),0,fan_stack_height/2-hepa_area_height]) {
          //rounded_cube(plenum_width/2,plenum_depth,1,rounded_diam,8);
        }
        /*
        overlap_amount = 0;
        overlap_dummy_width = 20;
        translate([x*(overlap_dummy_width/2-overlap_amount),0,fan_stack_height/2]) {
          //rounded_cube(overlap_dummy_width,plenum_depth,1,rounded_diam,8);
          cube([overlap_dummy_width,plenum_depth,1],center=true);
        }
        */
        translate([x*(fan_spacing/2),0,fan_pos_z]) {
          translate([0,0,fan_height/2+1+fan_channel_height]) {
            hole(fan_hole_opening,2,resolution*2);
          }
        }
      }
    }
    //hepa room
    hull() {
      translate([0,0,fan_stack_height/2]) {
        rounded_cube(hepa_width,hepa_depth,hepa_area_height*2,2);
        //rounded_cube(hepa_width-hepa_filter_lip_width*2,hepa_depth-hepa_filter_lip_width*2,(hepa_area_height+hepa_filter_lip_width*2)*2,2);
      }
      bottom_of_hepa(left);
      bottom_of_hepa(right);
    }
    position_fan() {
      //% color("#555") fan_4020();
      //% fan_4020();
      
      position_fan_screws() {
        translate([0,0,fan_height/2-20]) {
          hole(fan_heatset_diam,fan_heatset_height*2+40,resolution);
          //hole(fan_heatset_diam-1.5,fan_heatset_height*4+40,resolution);
        }
      }

      fan_hole_opening_width = 29;
      fan_hole_opening_offset = 1;
      fan_hole_opening_height = 40;
      fan_hole_opening_top = fan_height/2-1;
      translate([-40/2+fan_hole_opening_width/2+fan_hole_opening_offset,front*40/2,fan_hole_opening_top-fan_hole_opening_height/2]) {
        cube([fan_hole_opening_width,surround_wall_thickness*4,fan_hole_opening_height],center=true);
      }
    }
    translate([0,0,fan_stack_height/2]) {
      seal_and_magnet_cavity(top);
    }

    position_extrusion_mount() {
      translate([0,0,-15/2]) {
        cube([stack_width,(extrusion_mount_depth+cable_clearance)*2,extrusion_mount_depth],center=true);
      }
      translate([extrusion_mount_stickout/2,front*extrusion_mount_depth/2,extrusion_mount_thickness]) {
        extrusion_mount_hole_diam = 3.2;
        span_width = extrusion_mount_depth-extrusion_mount_wall_thickness*2;
        cube([extrusion_mount_hole_diam,span_width,extrude_height*2],center=true);
        cube([extrusion_mount_hole_diam,extrusion_mount_hole_diam,extrude_height*4],center=true);
        hole(extrusion_mount_hole_diam,extrude_height*6,8);
        hole(extrusion_mount_hole_diam,extrusion_mount_thickness*2+1,resolution);
        //% debug_axes(1);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

/*
module carbon_cartridge() {
  module body() {
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module carbon_cannister_container() {
  module body() {
    rounded_cube(carbon_cannister_container_width,carbon_cannister_container_depth,carbon_cannister_container_height,cavity_rounded+2,8);
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module carbon_cannister_lid() {
  module body() {
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}
*/

module carbon_hepa_stack() {
  carbon_bottom_height = 2;
  bottom_thickness = carbon_bottom_height;

  module body() {
    rounded_cube(stack_width,stack_depth,carbon_hepa_stack_height,rounded_diam);
  }

  module holes() {
    // debugging overhangs, etc
    translate([0,front*stack_depth/2,0]) {
      // cube([stack_width*2,stack_depth,carbon_hepa_stack_height*3],center=true);
    }
    translate([0,0,carbon_hepa_stack_height/2]) {
      rounded_cube(hepa_width,hepa_depth,(hepa_stack_height-hepa_filter_lip_height)*2,2);
      rounded_cube(hepa_width-hepa_filter_lip_width*2,hepa_depth-hepa_filter_lip_width*2,hepa_stack_height*3,3);
    }
    translate([0,0,-carbon_hepa_stack_height/2+carbon_stack_height/2]) {
      height = carbon_stack_height;
      rounded_diam = 2;
      wall_thickness = extrude_width*3*2;

      narrow_width = hepa_width-hepa_filter_lip_width*2;
      narrow_depth = hepa_depth-hepa_filter_lip_width*2;

      cavity_depth = stack_depth-wall_thickness*2;
      delta = cavity_depth-hepa_depth;

      cavity_width = hepa_width+delta;

      wide_height = height-(delta)*2-hepa_filter_lip_width;
      narrow_height = height-bottom_thickness*2;

      hull() {
        translate([0,0,-height/2+bottom_thickness]) {
          translate([0,0,wide_height/2]) {
            rounded_cube(cavity_width,cavity_depth,wide_height,rounded_diam);
          }
          translate([0,0,narrow_height/2]) {
            rounded_cube(narrow_width,narrow_depth,narrow_height,rounded_diam);
          }
        }
      }
    }
    translate([0,0,carbon_hepa_stack_height/2]) {
      seal_and_magnet_cavity(top);
    }
    translate([0,0,-carbon_hepa_stack_height/2]) {
      seal_and_magnet_cavity(bottom);

      slot_fin_thickness = 0.6*2;
      min_slot_gap_width = 2.5;
      total_width = hepa_width+slot_fin_thickness;
      num_gaps = floor((total_width)/(slot_fin_thickness+min_slot_gap_width));
      spacing = (total_width)/num_gaps;
      gap_width = spacing-slot_fin_thickness;

      //echo("num_gaps: ", num_gaps);
      //echo("spacing: ", spacing);
      linear_extrude(height=carbon_bottom_height*2+1,center=true) {
        for(x=[0:num_gaps-1],y=[front,0,rear]) {
          slot_depth = (hepa_depth-slot_fin_thickness*2)/3;
          //translate([-total_width/2+gap_width/2+slot_fin_thickness/2+x*spacing,y*(slot_fin_thickness/2+slot_depth/2),0]) {
          translate([-total_width/2+gap_width/2+slot_fin_thickness/2+x*spacing,y*(slot_depth+slot_fin_thickness),0]) {
            //rounded_cube(gap_width,slot_depth,carbon_stack_height*2,gap_width);
            square([gap_width,slot_depth],center=true);
          }
        }
      }
      /*
      */
    }
  }

  difference() {
    body();
    holes();
  }
}

module carbon_stack() {
  carbon_bottom_height = 2;
  module body() {
    rounded_cube(stack_width,stack_depth,carbon_stack_height,rounded_diam);
  }

  module holes() {
    beveled_cavity(carbon_stack_height,carbon_bottom_height);
    translate([0,0,carbon_stack_height/2]) {
      //rounded_cube(hepa_width-hepa_filter_lip_width*2,hepa_depth-hepa_filter_lip_width*2,carbon_stack_height*2+1,cavity_rounded);
      //rounded_cube(hepa_width,hepa_depth,(carbon_stack_height-carbon_bottom_height)*2,cavity_rounded);

      seal_and_magnet_cavity(top);
    }
    translate([0,0,-carbon_stack_height/2]) {
      seal_and_magnet_cavity(bottom);

      slot_fin_thickness = 0.6*2;
      min_slot_gap_width = 2.5;
      total_width = hepa_width+slot_fin_thickness;
      num_gaps = floor((total_width)/(slot_fin_thickness+min_slot_gap_width));
      spacing = (total_width)/num_gaps;
      gap_width = spacing-slot_fin_thickness;

      //echo("num_gaps: ", num_gaps);
      //echo("spacing: ", spacing);
      linear_extrude(height=carbon_bottom_height*2+1,center=true) {
        for(x=[0:num_gaps-1],y=[front,0,rear]) {
          slot_depth = (hepa_depth-slot_fin_thickness*2)/3;
          //translate([-total_width/2+gap_width/2+slot_fin_thickness/2+x*spacing,y*(slot_fin_thickness/2+slot_depth/2),0]) {
          translate([-total_width/2+gap_width/2+slot_fin_thickness/2+x*spacing,y*(slot_depth+slot_fin_thickness),0]) {
            //rounded_cube(gap_width,slot_depth,carbon_stack_height*2,gap_width);
            square([gap_width,slot_depth],center=true);
          }
        }
      }
      /*
      */
    }
  }

  difference() {
    body();
    holes();
  }
}

module hepa_stack() {
  module body() {
    rounded_cube(stack_width,stack_depth,hepa_stack_height,rounded_diam);
  }

  module holes() {
    translate([0,0,hepa_stack_height/2]) {
      rounded_cube(hepa_width,hepa_depth,(hepa_stack_height-hepa_filter_lip_height)*2,2);
      rounded_cube(hepa_width-hepa_filter_lip_width*2,hepa_depth-hepa_filter_lip_width*2,hepa_stack_height*2+1,3);

      seal_and_magnet_cavity(top);
    }
    translate([0,0,-hepa_stack_height/2]) {
      seal_and_magnet_cavity(bottom);
    }
  }

  difference() {
    body();
    holes();
  }
}

module lid_stack() {
  module body() {
    rounded_cube(stack_width,stack_depth,lid_stack_height,rounded_diam);
  }

  module holes() {
    lid_top_thickness = 2;
    translate([0,0,-lid_stack_height/2]) {
      seal_and_magnet_cavity(bottom);

      translate([0,0,-lid_top_thickness]) {
        rounded_cube(hepa_width,hepa_depth,lid_stack_height*2,2);
      }
    }

    slot_fin_thickness = 0.6*2;
    min_slot_gap_width = 3;
    num_gaps = floor((hepa_width+slot_fin_thickness)/(slot_fin_thickness+min_slot_gap_width));
    spacing = (hepa_width+slot_fin_thickness)/num_gaps;
    gap_width = spacing-slot_fin_thickness;

    //echo("num_gaps: ", num_gaps);
    //echo("spacing: ", spacing);
    linear_extrude(height=lid_stack_height*2,center=true) {
      for(x=[0:num_gaps-1],y=[front,rear]) {
        slot_length = hepa_depth/2-slot_fin_thickness/2;
        translate([-hepa_width/2+gap_width/2+x*spacing,y*(slot_fin_thickness/2+slot_length/2),0]) {
          hull() {
            translate([0,-y*(slot_length*0.25),0]) {
              square([gap_width,slot_length/2],center=true);
            }
            translate([0,y*(slot_length*0.25),0]) {
              rounded_square(gap_width,slot_length/2,2);
            }
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module assembly() {
  space_between = 50;
  translate([0,0,fan_stack_height]) {
    translate([0,0,-fan_stack_height/2]) {
      fan_stack();
    }

    translate([0,0,carbon_stack_height+space_between]) {
      translate([0,0,-carbon_stack_height/2]) {
        carbon_stack();
      }
      translate([0,0,carbon_stack_height/2+carbon_cannister_container_depth]) {
        //carbon_cannister_container();
      }

      translate([0,0,lid_stack_height+space_between]) {
        translate([0,0,-lid_stack_height/2]) {
          //lid_stack();
        }
      }

      translate([0,0,hepa_stack_height+space_between]) {
        translate([0,0,-hepa_stack_height/2]) {
          hepa_stack();
        }

        translate([0,0,lid_stack_height+space_between]) {
          translate([0,0,-lid_stack_height/2]) {
            lid_stack();
          }
        }
      }
    }
  }
}
