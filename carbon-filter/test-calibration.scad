include <./main.scad>;

test_height = fan_height+20;
top_height = 4;

hepa_width = 40;
hepa_depth = 40;

stack_width = hepa_width + rounded_diam+1;
stack_depth = hepa_depth + rounded_diam;

plenum_height = 0;
integrated_filter_fan_height = 14;

fan_stack_height = fan_height+plenum_height+space_below_fans+integrated_filter_fan_height-11;

module fan_test_piece() {
  fan_spacing = 0;
  fan_pos_z = -fan_stack_height/2+fan_height/2+space_below_fans;
  top_height = fan_stack_height/2-fan_pos_z-fan_height/2;
  //hepa_area_height = hepa_thickness+hepa_filter_height_tolerance;
  hepa_area_height = 0;
  fan_area_height = fan_pos_z+fan_height/2;

  fan_channel_height = 2;
  fan_hole_opening = 29;
  //fan_post_diam = 3.4+extrude_width*2*2*2;
  fan_post_diam = fan_heatset_diam+extrude_width*4*2;
  fan_post_height = 6.2;

  surround_height = 2;
  surround_wall_thickness = extrude_width*3*2;
  plenum_width = hepa_width-hepa_filter_lip_width*2;
  plenum_depth = hepa_depth-hepa_filter_lip_width*2;

  fan_offset_x = -1;

  module position_fan() {
    for(x=[left,right]) {
      translate([fan_offset_x+x*fan_spacing/2,0,fan_pos_z]) {
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
      [-40/2+3,40/2-3,0],
      [40/2-3,40/2-3,0],
      [40/2-3,-40/2+3,0],
    ];
    for(p=positions) {
      translate(p) {
        //children();
      }
    }
    for(r=[225,315,45]) {
      rotate([0,0,r]) {
        translate([0,49.5/2,0]) {
          children();
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
        }
      }
    }

    translate([0,0,fan_pos_z+fan_height/2-surround_height/2+1]) {
      difference() {
        rounded_cube(stack_width,stack_depth,surround_height+2,rounded_diam);
        rounded_cube(stack_width-surround_wall_thickness*2,stack_depth-surround_wall_thickness*2,surround_height+4,rounded_diam-surround_wall_thickness*2);
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
    // suction hole and TPU seal cavity
    translate([0,0,fan_pos_z+fan_height/2]) {
      hole(fan_hole_opening,fan_stack_height*2+1,resolution*2);

      /*
      rotate_extrude($fn=resolution*2,convexity=3) {
        translate([fan_hole_opening/2+seal_body_overhead/2,0,0]) {
          accurate_circle(seal_cavity_diam,resolution);
        }
      }
      */
      tpu_cavity_diam = 1.75+0.3;
      squish_pct = 0.2;
      # rotate_extrude($fn=resolution*2,convexity=3) {
        translate([fan_hole_opening/2+xy_seal_overhead/2,-tpu_cavity_diam/2+tpu_cavity_diam*0.65,0]) {
          scale([1-squish_pct,1,1]) {
            accurate_circle(tpu_cavity_diam,resolution);
          }
        }
      }
    }
    // plenum
    /*
    hull() {
      translate([0,0,fan_stack_height/2]) {
        rounded_cube(hepa_width,hepa_depth,(hepa_area_height+hepa_filter_lip_width)*2,2);
      }
      translate([x*(fan_spacing/2),0,fan_pos_z]) {
        translate([0,0,fan_height/2+1+fan_channel_height]) {
          hole(fan_hole_opening,2,resolution);
        }
      }
    }
    */
    position_fan() {
      //% color("#555") fan_4020();
      //% fan_4020();
      
      position_fan_screws() {
        translate([0,0,fan_height/2-20]) {
          hole(fan_heatset_diam,fan_heatset_height*2+40,resolution);
          //hole(fan_heatset_diam-1.5,fan_heatset_height*4+40,resolution);
        }
      }

      fan_hole_opening_width = 28;
      fan_hole_opening_offset = 0.5;
      fan_hole_opening_height = 40;
      fan_hole_opening_top = fan_height/2-1;
      translate([-40/2+fan_hole_opening_width/2+fan_hole_opening_offset,front*40/2,fan_hole_opening_top-fan_hole_opening_height/2]) {
        cube([fan_hole_opening_width,surround_wall_thickness*4,fan_hole_opening_height],center=true);
      }
    }
    translate([0,0,fan_stack_height/2]) {
      //seal_and_magnet_cavity(top);
    }
  }

  difference() {
    body();
    holes();
  }
}

module filter_test_piece() {
  height = 20;
  module body() {
    rounded_cube(stack_width,stack_depth,height,rounded_diam);
  }

  module holes() {
    rounded_cube(hepa_width,hepa_depth,height+1,rounded_diam);

    for(z=[top,bottom]) {
      translate([0,0,z*(height/2)]) {
        seal_and_magnet_cavity(z);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module round_tpu_channel_test() {
  test_length = 20;
  test_spacing = 8;
  bend_diam = 6;
  resolution = 16;
  //pct_submerge = 0.85; // was okay, but didn't stick up much
  pct_submerge = 0.8; //
  num_tests = 4;
  base_thickness = 3;
  base_length = test_spacing*(num_tests+2)+10;
  squish_pct = 0.2; // worked pretty well

  // black tpu seems to be much firmer than clear-ish TPU
  // clear-ish TPU worked with 0.1+, slid out of 0.3+ pretty easily though
  // black TPU worked with 0.3+, but 0.3 was pretty tight

  module tpu_channel(diam) {
    module corner_curve_max_xy() {
      difference() {
        rotate_extrude($fn=16,convexity=3) {
          translate([bend_diam/2,0,0]) {
            scale([1-squish_pct,1,1]) {
              accurate_circle(diam,resolution);
            }
          }
        }
        translate([-bend_diam/2,0,0]) {
          cube([bend_diam,bend_diam*2,bend_diam*3],center=true);
        }
        translate([bend_diam/2,-bend_diam/2,0]) {
          cube([bend_diam+1,bend_diam,bend_diam*3],center=true);
        }
      }
    }

    translate([-test_length/2-bend_diam/2,0,0]) {
      rotate([0,90,0]) {
        scale([1,1-squish_pct,1]) {
          hole(diam,test_length+0.1,resolution);
        }
      }
    }
    translate([0,-test_length/2-bend_diam/2,0]) {
      rotate([90,0,0]) {
        scale([1-squish_pct,1,1]) {
          hole(diam,test_length+0.1,resolution);
        }
      }
    }
    translate([-bend_diam/2,-bend_diam/2,0]) {
      corner_curve_max_xy();
    }
  }

  module body() {
    translate([-5,-18+base_length/2,-base_thickness/2]) {
      cube([30,base_length,base_thickness],center=true);
    }
  }

  module holes() {
    for(i=[1:num_tests+1]) {
      diam = 1.75+i*0.1;
      echo("diam: ", diam);
      translate([0,test_spacing*(i-0.5),-base_thickness+bottom*(diam/2-diam*pct_submerge)]) {
        rotate([0,0,45]) {
          # tpu_channel(diam);
        }
      }
      translate([0,test_spacing*(i-1),top*(diam/2-diam*pct_submerge)]) {
        rotate([0,0,45]) {
          # tpu_channel(diam);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module square_tpu_channel_test() {
  test_length = 20;
  test_spacing = 8;
  bend_diam = 6;
  resolution = 16;
  //pct_submerge = 0.85; // was okay, but didn't stick up much
  pct_submerge = 0.8; //
  num_tests = 4;
  base_thickness = 3;
  base_length = test_spacing*(num_tests+2)+10;
  squish_pct = 0.2; // worked pretty well

  // black tpu seems to be much firmer than clear-ish TPU
  // clear-ish TPU worked with 0.1+, slid out of 0.3+ pretty easily though
  // black TPU worked with 0.3+, but 0.3 was pretty tight

  module channel_profile(width) {
    depth = 1;
    hooked_width = width-0.5;
    hooked_height = 0.4;

    square([hooked_width,0.2],center=true);
    hull() {
      straight_height = depth - hooked_height;
      translate([0,-0.01]) {
        square([hooked_width,0.02],center=true);
      }
      translate([0,-depth+straight_height/2]) {
        square([width,straight_height],center=true);
      }
    }
  }

  translate([50,0,0]) {
    // channel_profile(2);
  }

  module tpu_channel(width) {
    module corner_curve_max_xy() {
      difference() {
        rotate_extrude($fn=16,convexity=3) {
          translate([bend_diam/2,0,0]) {
            channel_profile(width);
          }
        }
        translate([-bend_diam/2,0,0]) {
          cube([bend_diam,bend_diam*2,bend_diam*3],center=true);
        }
        translate([bend_diam/2,-bend_diam/2,0]) {
          cube([bend_diam+1,bend_diam,bend_diam*3],center=true);
        }
      }
    }

    translate([-test_length/2-bend_diam/2,0,0]) {
      rotate([0,90,0]) {
        rotate([0,0,90]) {
          linear_extrude(height=test_length+0.1,center=true) {
            channel_profile(width);
          }
        }
      }
    }
    translate([0,-test_length/2-bend_diam/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(height=test_length+0.1,center=true) {
          channel_profile(width);
        }
      }
    }
    translate([-bend_diam/2,-bend_diam/2,0]) {
      corner_curve_max_xy();
    }
  }

  module body() {
    translate([-5,-18+base_length/2,0]) {
      cube([30,base_length,base_thickness],center=true);
    }
  }

  module holes() {
    for(i=[1:num_tests+1]) {
      diam = 1.75+i*0.1;
      echo("diam: ", diam);
      translate([0,test_spacing*(i-1),top*(base_thickness/2)]) {
        rotate([0,0,45]) {
          tpu_channel(diam);
        }
      }
      mirror([0,0,1]) {
        translate([0,test_spacing*(i-0.5),top*(base_thickness/2)]) {
          rotate([0,0,45]) {
            tpu_channel(diam);
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

module magnet_cavity_diam_test() {
  num_tests_x = 4;
  num_tests_y = 4;
  test_buffer = 2;
  spacing = magnet_diam+test_buffer*2;

  test_width = num_tests_x*(spacing);
  test_depth = num_tests_y*(spacing);
  test_thickness = magnet_thickness+2;

  module body() {
    translate([0,0,-test_thickness/2]) {
      rotate([0,0,45]) {
        rounded_cube(test_width/2,spacing,test_thickness,spacing);
      }
    }
    translate([test_width/2-spacing/2,test_depth/2-spacing/2,-test_thickness/2]) {
      rounded_cube(test_width,test_depth,test_thickness,spacing);
    }
  }

  module holes() {
    for(x=[0:num_tests_x-1],y=[0:num_tests_y-1]) {
      translate([x*spacing,y*spacing,0]) {
        cavity_diam = magnet_diam-0.1+x*0.1;
        cavity_depth = magnet_thickness-0.1+y*0.1;
        hole(cavity_diam,cavity_depth*2,resolution);
      }
    }
  }

  difference() {
    body();
    # holes();
  }
}

//magnet_cavity_diam_test();

//square_tpu_channel_test();

//filter_test_piece();

fan_test_piece();
rotate([0,180,0]) {
  //fan_test_piece();
}
