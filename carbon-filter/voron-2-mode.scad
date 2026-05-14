include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>; 

//space_width = 50;
//space_width = 65;
//space_height = 45;
space_width = 65;
space_height = 35;

magnet_diam = 6;
magnet_thickness = 3;
magnet_cavity_diam = magnet_diam+0.1;
magnet_cavity_height = magnet_thickness+0.2;
extrude_width = 0.4;
extrude_height = 0.2;

m3_thread_into_plastic = 2.8;
m3_head_cavity = 5.7+0.3;
m2_head_cavity = 4+0.3;
m2_thread_into_plastic = 1.8;
//fan_heatset_diam = 5;
fan_heatset_diam = m3_thread_into_plastic;
//fan_heatset_height = 3;
fan_heatset_height = 6;

tpu_diam = 1.75;
tpu_cavity_diam = tpu_diam+0.3;
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

// 4020 fan
//fan_height = 20;
//fan_side = 40;
// 5015 fan
fan_height = 15;
fan_side = 50;
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

// NEW STUFF

aluminum_extrusion_width = 20;

wall_thickness = 1.4;
floor_thickness = 2;
id = magnet_cavity_diam;
od = id+wall_thickness*2;

cavity_width = space_width-wall_thickness*2;
cavity_height = space_height-wall_thickness*2;
foam_lip_width = 4.5;
side_widths = foam_lip_width+magnet_cavity_diam+wall_thickness;
opening_width = space_width-side_widths*2;
opening_height = space_height-foam_lip_width*2;

magnet_area_body_height = magnet_cavity_height+floor_thickness;

//echo("full stack height: ", fan_stack_height+carbon_stack_height+lid_stack_height);

module seal_and_magnet_cavity(side=top,width=space_width,depth=space_height) {
  resolution = 16;
  rounded_diam = od;

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

      // m3 socket head screw registration pin
      //for(y=[front*0.5,rear*0.5]) {
      for(y=[0]) {
        translate([0,y*magnet_area_y,0]) {
          if (side > 0) {
            // top
            hole(m2_thread_into_plastic, 4*2, 16);
          } else {
            // bottom
            hole(m2_head_cavity, magnet_cavity_height*2, 16);
          }
        }
      }
    }
  }

  translate([0,0,side*1]) {
    % difference() {
      cube([opening_width+foam_lip_width*2,opening_height+foam_lip_width*2,1],center=true);
      cube([opening_width,opening_height,1.2],center=true);
    }
  }
}

module fan_4020() {
  // 52.82 - 46.16
  // 3.33
  //translate([0,0,7]) {
  //translate([0,0,-12.5]) {
  //translate([0,0,fan_height/2]) {
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
    translate([-51/2+x_adjust,-51/2+y_adjust,z_adjust]) {
      //color("blue") import("Radial_Fan_50x15 v8.stl", convexity=2);
      import("Radial_Fan_50x15 v8.stl", convexity=2);
    }
  }
}

charcoal_stack_length = 80;

screw_down_point_body_diam = m3_thread_into_plastic+wall_thickness*3;
fan_strap_hole_spacing = fan_side + screw_down_point_body_diam + 2;

half_cavity_height = (cavity_height-wall_thickness)/2;
internal_height = charcoal_stack_length-magnet_area_body_height*2;

full_width_internal_height = internal_height-(cavity_width-opening_width)/2;
half_opening_height = opening_height/2-wall_thickness/2;

module fan_stack() {
  plenum_height = 20+magnet_area_body_height;
  //depth = plenum_height;
  fan_area_height = space_height-fan_height-3;
  fan_area_width = fan_side-2;
  fan_cavity_height = fan_area_height-wall_thickness*2;
  fan_cavity_width = fan_area_width-wall_thickness*2;

  //fan_cavity_diam = fan_side+3*2;

  //fan_pos_x = 10;
  //fan_pos_x = 3;
  //fan_pos_x = space_width/2-fan_area_width/2;
  fan_pos_x = space_width/2-fan_area_width/2;
  fan_pos_z = - plenum_height - fan_side/2;
  //fan_hole_opening = 27.5; // 4020
  fan_hole_opening = 32;

  //fan_shroud_base_skew_x = fan_pos_x*0.7;
  //fan_shroud_base_skew_x = 0; //space_width/2-fan_area_width/2;
  fan_shroud_base_skew_x = space_width/2-fan_area_width/2;
  tip_cut_off = 4;

  extrusion_mount_length = 50;
  extrusion_mount_hole_spacing = 15;
  extrusion_mount_hole_diam = 3.4;

  module position_fan() {
    translate([fan_pos_x,space_height/2-fan_area_height-1-fan_height/2,fan_pos_z]) {
      rotate([-90,0,0]) {
        rotate([0,0,90]) {
          children();
        }
      }
    }
  }

  module skew_fan_hole_opening_relative_to_fan() {
    translate([1.5,-0.5,0]) {
      children();
    }
  }

  /*
  fan_screw_positions=[
    [[35/2,35/2,0],0],
    [[35/2,-35/2,0],0],
    [[-35/2,35/2,0],0], // alone opposite opening
  ];
  */
  fan_screw_positions=[
    [[43.5/2,-37/2,0],0],
    [[42.5/2,39/2,0],0],
    [[-42.5/2,39/2,0],0],
  ];
  module position_fan_screws_4020() {
    for(p=fan_screw_positions) {
      translate(p[0]) {
        rotate([0,0,p[1]]) {
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

  module position_fan_screws_5015() {
    for(p=fan_screw_positions) {
      translate(p[0]) {
        rotate([0,0,p[1]]) {
          children();
        }
      }
    }
  }

  module position_fan_screws() {
    if (fan_side == 40) {
      position_fan_screws_4020() {
        children();
      }
    }
    if (fan_side == 50) {
      position_fan_screws_5015() {
        children();
      }
    }
  }

  module old_fan_shroud(shrink_by=0) {
    hull() {
      translate([0,space_height/2-fan_area_height/2,0]) {
        translate([0,0,-plenum_height]) {
          rounded_cube(fan_area_width-shrink_by, fan_area_height-shrink_by, 0.2, od-shrink_by);
        }
        translate([0,0,fan_pos_z]) {
          rotate([90,0,0]) {
            rotate_extrude(angle = 360, convexity = 2) {
              hull() {
                translate([1,0,0]) {
                  square([2,fan_area_height-shrink_by],center=true);
                }
                diam = od - shrink_by;
                translate([fan_area_width/2-od/2,0,0]) {
                  rounded_square(diam,fan_area_height-shrink_by,diam);
                }
              }
            }
          }
          translate([0,0,-fan_area_width/2+1+shrink_by/2]) {
            rounded_cube(fan_area_width/3, fan_area_height-shrink_by, 2, od-shrink_by);
          }
        }
      }
    }
  }

  module fan_shroud(shrink_by=0) {
    //cavity_diam = fan_area_width;
    difference() {
      hull() {
        translate([0,space_height/2-fan_area_height/2,0]) {
          translate([fan_shroud_base_skew_x,0,-plenum_height]) {
            rounded_cube(fan_area_width-shrink_by, fan_area_height-shrink_by, 0.2, od-shrink_by);
          }
          //translate([fan_pos_x,0,fan_pos_z]) {
          translate([fan_pos_x,0,fan_pos_z]) {
            rounded_cube(fan_area_width-shrink_by, fan_area_height-shrink_by, fan_side+wall_thickness*2-shrink_by, od-shrink_by);
          }
          /*
          translate([fan_pos_x,0,fan_pos_z]) {
            rotate([90,0,0]) {
              n_sides = 8;
              rotate([0,0,180/n_sides]) {
                rotate_extrude(angle = 360, convexity = 2, $fn = n_sides) {
                  hull() {
                    translate([1,0,0]) {
                      square([2,fan_area_height-shrink_by],center=true);
                    }
                    diam = od - shrink_by;
                    translate([fan_cavity_diam/2-od/2,0,0]) {
                      rounded_square(diam,fan_area_height-shrink_by,diam);
                    }
                  }
                }
              }
            }
            translate([0,0,-fan_cavity_diam/2+1+shrink_by/2]) {
              rounded_cube(fan_cavity_diam/3, fan_area_height-shrink_by, 2, od-shrink_by);
            }
          }
          */
        }
      }
      union() {
        if (shrink_by > 0) {
          // FIXME: DRY UP
          position_fan() {
            post_diam = m3_thread_into_plastic+wall_thickness*3;
            position_fan_screws() {
              //hole(post_diam,100,8);
            }
            /*
            translate(fan_screw_positions[0][0]) {
              rotate([0,0,45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[1][0]) {
              rotate([0,0,-45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[2][0]) {
              hull() {
                hole(post_diam,100,8);
                translate([-post_diam/2,0,0]) {
                  cube([post_diam,0.2,100],center=true);
                }
              }
            }
            */
            // 5015
            translate(fan_screw_positions[0][0]) {
              rotate([0,0,-45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[1][0]) {
              rotate([0,0,45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[2][0]) {
              hull() {
                hole(post_diam,100,8);
                translate([-post_diam/2,0,0]) {
                  cube([post_diam,0.2,100],center=true);
                }
              }
            }
          }
          /*
          translate([fan_pos_x,space_height/2-fan_area_height/2,fan_pos_z-fan_cavity_diam/2]) {
          //cube([space_width*2,space_width*2,2*tip_cut_off+shrink_by],center=true);

          // attempt to improve printability
            for(y=[front,0,rear]) {
              translate([0,y*(fan_area_height*0.25),tip_cut_off]) {
                cube([space_width,wall_thickness,shrink_by*2-0.2*4],center=true);
              }
            }
            for(x=[left,right]) {
              for(i=[0:1:6]) {
                translate([x*i*(fan_area_height*0.3),0,tip_cut_off]) {
                  cube([wall_thickness,space_width,shrink_by*2],center=true);
                }
              }
            }
          }
          */
        }
      }
    }
  }

  screw_down_points = [
    // [fan_pos_x,space_height/2-fan_area_height-fan_height+5,fan_pos_z+fan_side/2],
    // [fan_pos_x,space_height/2-fan_area_height,fan_pos_z-fan_cavity_diam/2+tip_cut_off-screw_down_point_body_diam/2-2],
    //[fan_pos_x,space_height/2-fan_area_height-fan_height+5,fan_pos_z+ fan_strap_hole_spacing/2],
    //[fan_pos_x,space_height/2-fan_area_height,fan_pos_z- fan_strap_hole_spacing/2],
  ];

  module body() {
    translate([0,0,-magnet_area_body_height/2]) {
      rounded_cube(space_width, space_height, magnet_area_body_height, od);
    }
    hull() {
      translate([0,0,-magnet_area_body_height]) {
        rounded_cube(space_width, space_height, 0.2, od);
      }
      translate([fan_shroud_base_skew_x,space_height/2-fan_area_height/2,-plenum_height]) {
        rounded_cube(fan_area_width, fan_area_height, 0.2, od);
      }
    }
    fan_shroud();


    for (p=screw_down_points) {
      translate(p) {
        rotate([90,0,0]) {
          fill_y = fan_area_height-2;
          translate([0,plenum_height/2- screw_down_point_body_diam/2,-fill_y/2]) {
            rounded_cube(screw_down_point_body_diam,plenum_height,fill_y,screw_down_point_body_diam);
          }
        }
      }
    }

    position_fan() {
      position_fan_screws() {
        /*
        translate([0,0,0]) {
          fill_y = fan_area_height-2;
          translate([-plenum_height/2+screw_down_point_body_diam/2,0,fan_height/2+fill_y/2+1]) {
            rounded_cube(plenum_height,screw_down_point_body_diam,fill_y,screw_down_point_body_diam);
          }
        }
        //debug_axes(1);
        */
      }
    }

    // extrusion_mount
    translate([-space_width/2,-space_height/2,0]) {
      //mount_width = aluminum_extrusion_width-od/2+wall_thickness;
      //mount_width = aluminum_extrusion_width;
      mount_width = 8+wall_thickness*2;
      //debug_axes(1);
      translate([aluminum_extrusion_width/2,0,-extrusion_mount_length/2]) {
        //wall_thickness = 2;
        linear_extrude(height=extrusion_mount_length,center=true, convexity=4) {
          max_height = space_height-od;
          translate([0,wall_thickness/2,0]) {
            rounded_square(mount_width,wall_thickness,wall_thickness);
          }

          translate([right*(mount_width-wall_thickness),max_height-wall_thickness/2,0]) {
            rounded_square(mount_width,wall_thickness,wall_thickness);
          }
          /*
          for(x=[left,right]) {
            translate([aluminum_extrusion_width/2+x*(aluminum_extrusion_width/2-wall_thickness/2),brace_width/2,0]) {
              rounded_square(wall_thickness,brace_width,wall_thickness);
            }
          }
          */
          brace_width = 10;
          translate([left*(mount_width/2-wall_thickness/2),brace_width/2,0]) {
            rounded_square(wall_thickness,brace_width,wall_thickness);
          }
          translate([right*(mount_width/2-wall_thickness/2),max_height/2,0]) {
            rounded_square(wall_thickness,max_height,wall_thickness);
          }
        }
      }

      translate([aluminum_extrusion_width/2,0,0]) {
        tab_length = 20;
        tab_depth = 5+wall_thickness;
        slot_width = 5.8;
        for(x=[left,right]) {
          translate([x*(slot_width/2-wall_thickness/2),wall_thickness-tab_depth/2,-tab_length/2]) {
            rounded_cube(wall_thickness,tab_depth,tab_length,wall_thickness);
          }
        }
      }
    }



    // plenum screw down point
    //translate([fan_pos_x,space_height/2-fan_area_height-fan_height+5,fan_pos_z+fan_side/2]) {
    //  rotate([90,0,0]) {
    //    fill_y = fan_height+fan_area_height/2;
    //    translate([0,plenum_height/2,-fill_y/2]) {
    //      rounded_cube(screw_down_point_body_diam,plenum_height,fill_y,screw_down_point_body_diam);
    //    }
    //  }
    //}

    //// tip screw down point
    //translate([fan_pos_x,space_height/2-fan_area_height,fan_pos_z+fan_side/2]) {
    //  rotate([90,0,0]) {
    //    debug_axes(2);
    //    fill_y = fan_height+fan_area_height/2;
    //    translate([0,plenum_height/2,-fill_y/2]) {
    //      rounded_cube(screw_down_point_body_diam,plenum_height,fill_y,screw_down_point_body_diam);
    //    }
    //  }
    //}
  }

  module holes() {
    rounded_cube(opening_width, opening_height, (magnet_area_body_height+1)*2, id);

    // section view
    translate([0,space_height/2]) {
      // cube([200,fan_height,200],center=true);
    }

    difference() {
      hull() {
        translate([0,0,-magnet_area_body_height]) {
          rounded_cube(cavity_width, cavity_height, 0.2, id);
        }
        translate([fan_shroud_base_skew_x,space_height/2-fan_area_height/2,-plenum_height]) {
          rounded_cube(fan_cavity_width, fan_cavity_height, 0.2, id);
        }
      }
      // FIXME: DRY UP
      position_fan() {
        post_diam = m3_thread_into_plastic+wall_thickness*3;
        position_fan_screws() {
          //hole(post_diam,100,8);
        }
        /*
        translate(fan_screw_positions[0][0]) {
          rotate([0,0,45]) {
            translate([40/2-post_diam-1,0,0]) {
              cube([40,100,100],center=true);
            }
          }
        }
        translate(fan_screw_positions[1][0]) {
          rotate([0,0,-45]) {
            translate([40/2-post_diam-1,0,0]) {
              cube([40,100,100],center=true);
            }
          }
        }
        translate(fan_screw_positions[2][0]) {
          hull() {
            hole(post_diam,100,8);
            translate([-post_diam/2,0,0]) {
              cube([post_diam,0.2,100],center=true);
              debug_axes(1);
            }
          }
        }
        */
            // 5015
            translate(fan_screw_positions[0][0]) {
              rotate([0,0,-45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[1][0]) {
              rotate([0,0,45]) {
                translate([40/2-post_diam-1,0,0]) {
                  cube([40,100,100],center=true);
                }
              }
            }
            translate(fan_screw_positions[2][0]) {
              hull() {
                hole(post_diam,100,8);
                translate([-post_diam/2,0,0]) {
                  cube([post_diam,0.2,100],center=true);
                }
              }
            }
      }
    }

    position_fan() {
      //% fan_4020();
      % fan_5015();

      translate([0,0,fan_height/2]) {
        skew_fan_hole_opening_relative_to_fan() {
          hull() {
            hole(fan_hole_opening,10,resolution);
            translate([fan_hole_opening/2-3/2,0,0]) {
              cube([3,fan_hole_opening*0.3,10],center=true);
            }
          }
        }
      }

      translate([0,0,-fan_height/2-1]) {
        //% color("#777") fan_strap();
        //% fan_strap();
      }
      position_fan_screws() {
        hole_depth = fan_area_height-1;
        translate([0,0,fan_height/2]) {
          //debug_axes(1);
          hole(m3_thread_into_plastic,2*hole_depth,resolution);
        }
      }
    }

    seal_and_magnet_cavity(side = top);
    fan_shroud(wall_thickness*2);

    for (p=screw_down_points) {
      translate(p) {
        translate([0,0,0]) {
          rotate([90,0,0]) {
            hole_depth = 8;

            translate([0,0,0]) {
              hole(m3_thread_into_plastic,2*hole_depth,resolution);
            }
          }
        }
      }
    }

    // extrusion mounting
    translate([-space_width/2+aluminum_extrusion_width/2,-space_height/2+wall_thickness,-extrusion_mount_length+8+extrusion_mount_hole_spacing/2]) {
      for(z=[top,bottom]) {
        translate([0,0,z*(extrusion_mount_hole_spacing/2)]) {
          rotate([90,0,0]) {
            hole(extrusion_mount_hole_diam,20,resolution);
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

module filter_slots(height=floor_thickness*2+1) {
  // bottom slots 
  slot_fin_thickness = wall_thickness;
  min_slot_gap_width = 1.5;
  total_width = opening_width;
  num_gaps = floor((total_width)/(slot_fin_thickness+min_slot_gap_width));
  spacing = (total_width+slot_fin_thickness)/num_gaps;
  gap_width = spacing-slot_fin_thickness;

  linear_extrude(height=height,center=true, convexity=4) {
    for(x=[0:num_gaps-1]) {
      slot_depth = half_opening_height;
      translate([-total_width/2+slot_fin_thickness/2+x*spacing,0,0]) {
        //rounded_square(gap_width,slot_depth,gap_width);
        square([gap_width,slot_depth],center=true);
      }
    }
  }
}

module fan_strap() {
  hole_diam = 3.2;
  body_diam = hole_diam + wall_thickness*3;

  thickness = 2;

  module body() {
    hull() {
      for(x=[left,right]) {
        translate([x*(fan_strap_hole_spacing/2),0,0]) {
          hole(body_diam,thickness,resolution);
        }
      }
    }
    for(x=[left,right]) {
      translate([x*(fan_strap_hole_spacing/2),0,thickness]) {
        hole(body_diam,thickness*3,resolution);
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      translate([x*(fan_strap_hole_spacing/2),0,0]) {
        hole(3.2,100,resolution);
      }
    }
    translate([0,0,10/2+thickness/2]) {
      cube([fan_side+0.5,body_diam+1,10],center=true);
      //% cube([fan_side,fan_side,10],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

module charcoal_stack() {
  module body() {
    translate([0,0,charcoal_stack_length/2]) {
      rounded_cube(space_width, space_height, charcoal_stack_length, od);
    }

    // alignment tabs
    //for(z=[top,bottom]) {
    for(z=[top]) {
      translate([-space_width/2+aluminum_extrusion_width/2,-space_height/2,charcoal_stack_length/2+z*(charcoal_stack_length/2)]) {
        tab_length = 5;
        tab_depth = 5+wall_thickness;
        slot_width = 5.8;
        for(x=[left,right]) {
          hull() {
            translate([x*(slot_width/2-wall_thickness/2),wall_thickness-tab_depth/2,z*(-tab_length/2)]) {
              rounded_cube(wall_thickness,tab_depth,tab_length,wall_thickness);

              translate([0,tab_depth/2-wall_thickness/2,z*(-tab_depth-wall_thickness/2)]) {
                hole(wall_thickness,1,resolution);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([0,0,charcoal_stack_length/2]) {
      for(z=[top,bottom]) {
        translate([0,0,z*charcoal_stack_length/2]) {
          seal_and_magnet_cavity(side = z);
        }
      }
    }

    for(y=[front,rear]) {
      // or should we split it into three?

      mirror([0,y-1,0]) {
      //mirror([0,0,0]) {

        translate([0,wall_thickness/2,floor_thickness]) {
          translate([0,half_opening_height/2,charcoal_stack_length/2]) {
            rounded_cube(opening_width,half_opening_height,charcoal_stack_length,id);
          }
          translate([0,half_cavity_height/2,magnet_area_body_height]) {
            rounded_cube(space_width-od*2-wall_thickness,half_cavity_height,magnet_area_body_height*2,id);
          }
        }

        hull() {
          translate([0,0,magnet_area_body_height]) {
            translate([0,wall_thickness/2,0]) {
              translate([0,half_opening_height/2,internal_height/2]) {
                rounded_cube(opening_width,half_opening_height,internal_height,id);
              }
              translate([0,half_cavity_height/2,full_width_internal_height/2]) {
                rounded_cube(cavity_width,half_cavity_height,full_width_internal_height,id);
              }
            }
          }
        }

        translate([0,wall_thickness/2+half_opening_height/2,0]) {
          filter_slots();
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module lid_stack() {
  lid_height = magnet_area_body_height;
  module body() {
    translate([0,0,lid_height/2]) {
      rounded_cube(space_width, space_height, lid_height, od);
    }
  }

  module holes() {
    seal_and_magnet_cavity(side = bottom);

    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([0,wall_thickness/2+half_opening_height/2,lid_height/2]) {
          filter_slots(lid_height+1);
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
  rotate([90,0,0]) {
    spacing = 20;

    rotate([0,0,0]) {
      fan_stack();
    }

    translate([0,0,spacing]) {
      charcoal_stack();
    }

    translate([0,0,charcoal_stack_length + spacing * 2]) {
      //lid_stack();
    }

    translate([200,0,0]) {
      //fan_strap();
    }

    translate([100,0,0]) {
      //% fan_4020();
      % fan_5015();
    }

    translate([-space_width/2+20/2,-space_height/2-20/2,0]) {
      % extrusion(E2020t,300);
    }
  }
}

//assembly();
