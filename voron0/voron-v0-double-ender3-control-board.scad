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

//rpi = RPI3;
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
  0,
  0,
];

electronics_mounting_hole_pos_y = [
  // 22,
  // 85,
  22,
  100,
];

mcu_pos_x = [
  //mcu_x_offsets[0] - z_rail_spacing/2,
  //mcu_x_offsets[1] + z_rail_spacing/2,
  left*(200/2-mcu_width/2),
  right*(200/2-mcu_width/2),
];

room_under_boards = 15;

echo("pi_width: ", pi_width);

function cat(L1, L2) = [for (i=[0:len(L1)+len(L2)-1]) i < len(L1)? L1[i] : L2[i-len(L1)]] ;

module position_mounting_holes() {
  for(x=[left,right],y=electronics_mounting_hole_pos_y) {
    translate([x*(z_rail_spacing/2),y,0]) {
      children();
    }
  }
}

module buck_converter_clip_mount() {
  pcb_length = 47; // more like ~44
  pcb_width = 22; // more like ~22
  overall_width = pcb_width+wall_thickness*2;
  tolerance = 0.2;
  wall_thickness = extrude_width*2;
  depth_into_slot = 1.5;
  release_tab_depth_into_slot = 1.5;
  release_tab_overall_depth = wall_thickness*3+tolerance+release_tab_depth_into_slot;
  slot_width = 2.9;
  angle = 180;
  dist_from_extrusion = tolerance+wall_thickness;

  pcb_screw_hole_diam = 2.3;
  bevel_height = 4;
  post_id = pcb_screw_hole_diam;
  post_od = post_id + bevel_height*2;
  screw_support_thickness = 4;

  //pi_hole_spacing_x = 58;
  //pi_hole_spacing_y = 49;
  clip_width = 15;
  pi_hole_from_edge = 3.5;


  translate([15/2,15/2,0]) {
    % extrusion_makerbeam_xl(200);
  }

  module position_corner() {
    translate([-dist_from_extrusion,15-22,0]) {
      rotate([0,0,angle]) {
        debug_axes(1);
        children();
      }
    }
  }

  module pcb_cover_profile() {
    wall_thickness = extrude_width*2;
    contained_object_height = 15;
    overall_height = bevel_height+contained_object_height+wall_thickness;
    base_thickness = screw_support_thickness/2;
    //% debug_axes(1);
    module body() {
      for(x=[left,right]) {
        translate([x*(overall_width/2-wall_thickness/2),contained_object_height-overall_height/2,0]) {
          rounded_square(wall_thickness,overall_height,wall_thickness);
        }
        translate([0,-bevel_height-base_thickness/2,0]) {
          rounded_square(overall_width,base_thickness,wall_thickness);
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

  module clip_profile() {
    module body() {
      // horizontal tab
      trim_tab_by = 0.1;
      translate([15/2-trim_tab_by/2,depth_into_slot/2-wall_thickness,0]) {
        rounded_square(slot_width-trim_tab_by,depth_into_slot+wall_thickness*2,wall_thickness);
      }
      // horizontal
      hull() {
        // hull this with the rpi mount to make it thicker
        translate([-wall_thickness/2-tolerance,-wall_thickness,0]) {
          rounded_square(wall_thickness,wall_thickness*2,wall_thickness);
        }
        translate([15/2,-wall_thickness,0]) {
          rounded_square((slot_width/2+1)*2,wall_thickness*2,wall_thickness);
        }

        position_corner() {
          brace_height = bevel_height + screw_support_thickness-2;
          translate([wall_thickness/2+tolerance,-brace_height/2,0]) {
            //# rounded_square(wall_thickness,brace_height,wall_thickness);
          }
        }
      }

      position_corner() {
        anchor_length = 9;
        translate([-anchor_length/2+wall_thickness/2,-bevel_height-screw_support_thickness/2,0]) {
          //# rounded_square(anchor_length+wall_thickness,screw_support_thickness,wall_thickness);
        }
      }

      // vertical
      tab_cover = 15/2;
      translate([-wall_thickness/2-tolerance,-wall_thickness+tab_cover/2,0]) {
        rounded_square(wall_thickness,wall_thickness*2+tab_cover,wall_thickness);
      }
      translate([release_tab_depth_into_slot-release_tab_overall_depth/2,15/2,0]) {
        rounded_square(release_tab_overall_depth,slot_width,wall_thickness);
      }

      // release tab
      release_tab_length = 15/2+slot_width/2-1;
      release_tab_thickness = 2;
      translate([-release_tab_thickness-tolerance,15/2+release_tab_length/2-slot_width/2,0]) {
        rounded_square(wall_thickness*2,release_tab_length,wall_thickness);
      }
      translate([-release_tab_thickness-tolerance,15/2+release_tab_length/2-slot_width/2,0]) {
        rounded_square(wall_thickness*2,release_tab_length,wall_thickness);
      }
    }

    module holes() {
    }

    difference() {
      body();
      holes();
    }
  }

  translate([30,0,0]) {
    //clip_profile();
  }

  module position_pcb_profile() {
    room_between_extrusion_and_mount = 1;
    translate([-overall_width/2+15-0.5,-bevel_height-wall_thickness*2- room_between_extrusion_and_mount,0]) {
      rotate([0,0,180]) {
        children();
      }
    }
  }

  module position_pcb() {
    translate([0,0,pcb_length/2]) {
      position_pcb_profile() {
        rotate([-90,0,0]) {
          children();
        }
      }
    }
  }

  module body() {
    for(y=[front]) {
      //translate([0,pi_length/2-pi_hole_spacing_y/2-clip_width/2+y*(pi_hole_spacing_x)/2,0]) {
      translate([0,0,pcb_length/2]) {
        linear_extrude(height=pcb_length, center=true, convexity=10) {
          position_pcb_profile() {
            pcb_cover_profile();
          }
        }
      }
      translate([0,0,clip_width/2]) {
        //rotate([90,0,0]) {
          //rpi_clip_profile();
          linear_extrude(height=clip_width, center=true, convexity=10) {
            clip_profile();
            position_pcb_profile() {
              //pcb_cover_profile();
            }
          }
        //}
      }
    }
    position_pcb() {
      % buck_converter();
      intersection() {
        union() {
          for(x=[left,right]) {
            mirror([x-1,0,0]) {
              position_buck_converter_holes() {
                bevel(post_od, post_id+extrude_width*2*2, bevel_height);
              }
            }
          }
        }
        cube([overall_width-1,100,100],center=true);
      }
    }
  }

  module holes() {
    position_pcb() {
      for(x=[left,right]) {
        mirror([x-1,0,0]) {
          position_buck_converter_holes() {
            hole(post_id,2*(bevel_height+screw_support_thickness-wall_thickness*3),resolution);
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

module rpi_clip_mount() {
  tolerance = 0.2;
  wall_thickness = extrude_width*2;
  depth_into_slot = 1.5;
  release_tab_depth_into_slot = 1.5;
  release_tab_overall_depth = wall_thickness*3+tolerance+release_tab_depth_into_slot;
  slot_width = 2.9;
  rpi_angle = 8;
  rpi_dist_from_lid = 24;
  rpi_dist_from_extrusion = tolerance+wall_thickness;

  rpi_screw_hole_diam = 2.3;
  post_id = rpi_screw_hole_diam;
  post_od = post_id + 0.5*3*2*2;
  bevel_height = 2.5;
  screw_support_thickness = 4;

  pi_hole_spacing_x = 58;
  pi_hole_spacing_y = 49;
  clip_width = 15;
  pi_hole_from_edge = 3.5;

  module rpi_clip_profile() {
    module body() {
      module position_pi_corner() {
        translate([-rpi_dist_from_extrusion,15-rpi_dist_from_lid,0]) {
          rotate([0,0,rpi_angle]) {
            //% debug_axes(0.1);
            children();
          }
        }
      }

      // horizontal tab
      trim_tab_by = 0.1;
      translate([15/2-trim_tab_by/2,depth_into_slot/2-wall_thickness,0]) {
        rounded_square(slot_width-trim_tab_by,depth_into_slot+wall_thickness*2,wall_thickness);
      }
      // horizontal
      hull() {
        // hull this with the rpi mount to make it thicker
        translate([-wall_thickness/2-tolerance,-wall_thickness,0]) {
          rounded_square(wall_thickness,wall_thickness*2,wall_thickness);
        }
        translate([15/2,-wall_thickness,0]) {
          rounded_square((slot_width/2+1)*2,wall_thickness*2,wall_thickness);
        }
        translate([-wall_thickness/2+15/2/2-tolerance,-wall_thickness,0]) {
          //# rounded_square(wall_thickness+15/2,wall_thickness*2,wall_thickness);
        }
        position_pi_corner() {
          rpi_pcb_thickness = pcb_thickness(rpi)+0.5;
          brace_height = bevel_height + rpi_pcb_thickness + screw_support_thickness;
          translate([wall_thickness/2+tolerance,rpi_pcb_thickness-brace_height/2,0]) {
            rounded_square(wall_thickness,brace_height,wall_thickness);
          }
        }
      }

      position_pi_corner() {
        rpi_anchor_length = 9;
        translate([-rpi_anchor_length/2+wall_thickness/2,-bevel_height-screw_support_thickness/2,0]) {
          rounded_square(rpi_anchor_length+wall_thickness,screw_support_thickness,wall_thickness);
        }
      }

      // vertical
      tab_cover = 15/2;
      translate([-wall_thickness/2-tolerance,-wall_thickness+tab_cover/2,0]) {
        rounded_square(wall_thickness,wall_thickness*2+tab_cover,wall_thickness);
      }
      translate([release_tab_depth_into_slot-release_tab_overall_depth/2,15/2,0]) {
        rounded_square(release_tab_overall_depth,slot_width,wall_thickness);
      }

      // release tab
      release_tab_length = 15/2+slot_width/2-1;
      release_tab_thickness = 2;
      translate([-release_tab_thickness-tolerance,15/2+release_tab_length/2-slot_width/2,0]) {
        rounded_square(wall_thickness*2,release_tab_length,wall_thickness);
      }
      translate([-release_tab_thickness-tolerance,15/2+release_tab_length/2-slot_width/2,0]) {
        rounded_square(wall_thickness*2,release_tab_length,wall_thickness);
      }
    }

    module holes() {
    }

    difference() {
      body();
      holes();
    }
  }

  module position_rpi() {
    translate([-rpi_dist_from_extrusion,0,15-rpi_dist_from_lid]) {
      rotate([0,-rpi_angle,0]) {
        translate([-pi_width/2,0,0]) {
          rotate([0,0,-90]) {
            children();
          }
        }
      }
    }
  }

  module body() {
    for(y=[front]) {
      translate([0,pi_length/2-pi_hole_spacing_y/2-clip_width/2+y*(pi_hole_spacing_x)/2,0]) {
        rotate([90,0,0]) {
          //rpi_clip_profile();
          linear_extrude(height=clip_width, center=true, convexity=10) {
            rpi_clip_profile();
          }
        }
      }
    }
    position_rpi() {
      % pcb(rpi);
      translate([-pi_length/2+pi_hole_from_edge+pi_hole_spacing_x,pi_hole_spacing_y/2,-0.1]) {
        bevel(post_od, post_id+extrude_width*2*2, bevel_height);
      }
    }
  }

  module holes() {
    position_rpi() {
      pcb_hole_positions(rpi) {
        hole(post_id,2*(bevel_height+screw_support_thickness-wall_thickness),resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module mount_assembly() {
  translate([0,-200/2+15,0]) {
    //old_double_mcu_mount();
    new_double_mcu_mount(left);
    //mellow_fly_d5_on_right(right);
    new_double_mcu_mount(right);
    //double_mcu_mount();
  }

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
    //translate([x,-200/2+15+4+mcu_length/2,mcu_mount_thickness+mcu_bevel_height]) {
    //translate([x,-200/2+15,mcu_mount_thickness+mcu_bevel_height]) {
    for(x=mcu_pos_x) {
      //translate([x,-200/2+15+4+mcu_length/2,mcu_mount_thickness+mcu_bevel_height]) {
      //translate([x,-200/2+15,mcu_mount_thickness+mcu_bevel_height]) {
      translate([x,-200/2+15,0]) {
        //children();
      }
    }
  }

  mcu_angle = -10;

  // left
  translate([-200/2-15+5+mcu_width/2,-200/2+15+mcu_length/2+1,room_under_boards]) {
    rotate([0,0,0]) {
      rotate([0,0,90]) {
        rotate([mcu_angle,0,0]) {
          //% pcb(mcu);
        }
      }
    }
  }
  translate([-200/2+mcu_width/2,-200/2+15+mcu_length/2+20,dist_front_to_back-(4+2)]) {
    rotate([0,180,0]) {
      rotate([0,0,-90]) {
        //% pcb(mcu);
      }
    }
  }

  // right
  translate([8,-200/2+15+mcu_length/2+1,room_under_boards]) {
    rotate([0,0,90]) {
      rotate([mcu_angle,0,0]) {
        //% pcb(mcu);
      }
    }
  }
  //translate([200/2-mcu_length/2-10,-200/2+15+mcu_length/2+32,7]) {
  translate([z_rail_spacing/2,-200/2+15+mcu_width/2+1,room_under_boards]) {
    rotate([0,0,0]) {
      //% pcb(mcu);
    }
  }
  translate([0,-200/2+15+mcu_length/2+4,4+2]) {
    rotate([0,0,0]) {
      //% pcb(mcu);
    }
  }

  /*
  //translate([200/2-2,-200/2+15+pi_length/2+43,dist_front_to_back-18]) {
  translate([200/2-2,-200/2+pi_length/2,dist_front_to_back-18]) {
    rotate([0,0,0]) {
      rotate([0,-20,0]) {
        translate([-pi_width/2,0,0]) {
          rotate([0,0,-90]) {
            % pcb(rpi);
          }
        }
      }
    }
  }
  translate([200/2-pi_length/2,16,room_under_boards]) {
    rotate([0,0,0]) {
      rotate([0,0,180]) {
        //% pcb(rpi);
      }
    }
  }
  translate([200/2-pi_length/2,16,dist_front_to_back]) {
    rotate([180,0,0]) {
      rotate([0,0,180]) {
        //% pcb(rpi);
      }
    }
  }
  */

  module position_rpi_mount() {
    //translate([200/2+15,-200/2+15,0]) {
    translate([0,0,0]) {
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
    rpi_mount();
  }
  % translate([0,0,-15/2+dist_front_to_back]) {
    for(x=[left,right]) {
      translate([x*(200+15)/2,0,0]) {
        rotate([90,0,0]) {
          extrusion_makerbeam_xl(200);
        }

        for(z=[top,bottom]) {
          translate([0,z*(200/2-15/2),-15/2-200/2]) {
            extrusion_makerbeam_xl(200);
          }
        }
      }
    }
  }

  % for(y=[front,rear]) {
    translate([0,y*(200/2-15/2),15/2-sheet_thickness]) {
      rotate([0,90,0]) {
        extrusion_makerbeam_xl(200);
      }
    }
  }

  % for(x=[left,right]) {
    translate([x*vertical_extrusion_pos_x,0,-sheet_thickness-15/2]) {
      rotate([90,0,0]) {
        //extrusion_makerbeam_xl(200);
      }
    }
  }

  translate([0,148.5,-sheet_thickness/2]) {
    color("#999", 0.2) linear_extrude(height = sheet_thickness, center = true, convexity = 10) {
      import(file = "./Mid_Panel.dxf");
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

module old_double_mcu_mount() {
  mcu_angle = -10;
  min_room_under_boards = 13;
  m3_loose = 3.3;
  m3_thread_into = 2.7;
  post_id = m3_thread_into;
  post_od = post_id + extrude_width*2*2*2;
  post_thread_depth = 6;
  bevel_height = 2;

  base_height = 3;

  flat_ratio = cos(abs(mcu_angle));

  echo("flat_ratio: ", flat_ratio);

  //dist_from_extrusion = 10; // so that the mounting holes and mcu holes don't foul each other
  dist_from_extrusion = 60;

  mcu_offset = 0;

  left_mcu_hole_pos = [
    [mcu_length/2-5/2,-64.47/2,0],
    [-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
    [-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
    [-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
  ];

  right_mcu_hole_pos = [
    [mcu_length/2-5/2,-64.47/2,0],
    [-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
    [-mcu_length/2+20.3,mcu_width/2-5.58/2,0],
    [-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
    [-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
  ];

  all_hole_pos = cat(left_mcu_hole_pos,right_mcu_hole_pos);

  echo("all_hole_pos: ", all_hole_pos);

  module position_left_mcu() {
    // left
    translate([-mcu_length/2,mcu_width/2+dist_from_extrusion,min_room_under_boards]) {
      rotate([0,0,0]) {
        translate([0,mcu_width/2,0]) {
          rotate([0,-mcu_angle,0]) {
            translate([0,-mcu_width/2,0]) {
              children();
              //% pcb(mcu);
            }
          }
        }
      }
    }
  }

  for(x=[left,right],y=electronics_mounting_hole_pos_y) {
    translate([x*z_rail_spacing/2,y,0]) {
      % color("red") hole(3,500);
    }
  }

  module position_right_mcu() {
    // right
    translate([mcu_offset+mcu_length/2,mcu_width/2+dist_from_extrusion,min_room_under_boards]) {
      rotate([0,0,0]) {
        translate([0,mcu_width/2,0]) {
          rotate([0,-mcu_angle,0]) {
            translate([0,-mcu_width/2,0]) {
              children();
              //% pcb(mcu);
            }
          }
        }
      }
    }
  }

  module position_mcus() {
    position_left_mcu() {
      children();
    }
    position_right_mcu() {
      children();
    }
  }
  position_mcus() {
    % pcb(mcu);
  }

  module flat_position_for(hole_pos) {
    translate([hole_pos[0],mcu_width/2,0]) {
      rotate([-mcu_angle,0,0]) {
        translate([0,(-mcu_width/2+hole_pos[1])*flat_ratio,-min_room_under_boards]) {
          children();
        }
      }
    }
  }

  module position_mcu_holes() {
    position_left_mcu() {
      for(p=left_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }

    position_right_mcu() {
      for(p=right_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }
  }

  module board_position_for_hole(i) {
    if (i < len(left_mcu_hole_pos)) {
      position_left_mcu() {
        children();
      }
    } else {
      position_right_mcu() {
        children();
      }
    }
  }

  module base_for_hole(i) {
    board_position_for_hole(i) {
      flat_position_for(all_hole_pos[i]) {
        translate([0,0,base_height/2]) {
          scale([1,1.5,1]) {
            hole(post_od,base_height,resolution);
          }
        }
        // children();
      }
    }
  }
  module position_for_hole(i) {
    board_position_for_hole(i) {
      translate(all_hole_pos[i]) {
        children();
      }
    }
  }

  module body() {
    /*
    for (i=[0:len(all_hole_pos)-1]) {
      echo("i: ", i);
      hull() {
        position_for_hole(i) {
          translate([0,0,-bevel_height-post_thread_depth/2]) {
            hole(post_od,post_thread_depth+0.2,resolution);
          }
        }
        base_for_hole(i);
      }
    }

    // upper left mounting hole
    hull() {
      base_for_hole(0);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    hull() {
      base_for_hole(5);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    // lower left mounting hole
    hull() {
      base_for_hole(6);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    hull() {
      base_for_hole(2);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    // upper right mounting hole
    hull() {
      base_for_hole(4);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    // lower right mounting hole
    hull() {
      base_for_hole(7);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    hull() {
      base_for_hole(8);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    //hull() { base_for_hole(5); base_for_hole(6); } // join upper and lower

    hull() { base_for_hole(0); base_for_hole(3); } // upper left
    hull() { base_for_hole(1); base_for_hole(2); } // lower left

    hull() { base_for_hole(4); base_for_hole(5); } // upper right
    hull() { base_for_hole(6); base_for_hole(7); } // lower right

    position_mcu_holes() {
      bevel(post_od, post_id+extrude_width*2*2, bevel_height);
    }
    */
  }

  module holes() {
    position_mounting_holes() {
      hole(m3_loose,100,resolution);
    }
    position_mcu_holes() {
      hole(post_id,post_thread_depth*2,resolution);
    }
  }

  difference() {
    body();
    holes();
  }
}

module new_double_mcu_mount(side=left) {
  mcus = [
    BTT_SKR_MINI_E3_V2_0,
    BTT_SKR_MINI_E3_V2_0,
    MELLOW_FLY_D5,
  ];
  //mcu = mcus[side+1];
  left_mcu = mcus[left+1];
  right_mcu = mcus[right+1];

  mcu_angles = [-10,0,0];
  //mcu_angle = -10;
  left_mcu_angle = mcu_angles[left+1];
  right_mcu_angle = mcu_angles[right+1];
  min_room_under_board_for_side = [13,10,15];
  //min_room_under_boards = 13;
  //min_room_under_boards = min_room_under_board_for_side[side+1];
  left_min_room_under_board = min_room_under_board_for_side[left+1];
  right_min_room_under_board = min_room_under_board_for_side[right+1];
  m3_loose = 3.3;
  m3_thread_into = 2.7;
  post_id = m3_thread_into;
  //post_od = post_id + extrude_width*2*2*2; // FIXME: Too weak for ASA
  post_od = post_id + extrude_width*3*2*2;
  post_thread_depth = 6;
  bevel_height = 2;

  base_height = 3;

  pi_hole_spacing_x = 58;
  pi_hole_spacing_y = 49;
  pi_hole_from_edge = 3.5;
  pi_screw_hole_diam = 2.3;
  pi_post_id = pi_screw_hole_diam;

  //flat_ratio = cos(abs(mcu_angle));
  function get_flat_ratio(mcu_angle) = cos(abs(mcu_angle));

  //echo("flat_ratio: ", flat_ratio);

  dist_from_extrusion = 10; // so that the mounting holes and mcu holes don't foul each other

  left_mcu_hole_pos = [
    [mcu_length/2-5/2,-64.47/2,0],
    [-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
    [-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
    [-mcu_length/2+20.3,mcu_width/2-5.58/2,0],
    [-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
  ];

  right_mcu_hole_pos = [
    [left*83/2,rear*57/2,0],
    [right*83/2,rear*57/2,0],
    [right*83/2,front*57/2,0],
    [left*83/2,front*57/2,0],
    //[mcu_length/2-5/2,-64.47/2,0],
    //[-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
    //[-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
    //[-mcu_length/2+20.3,mcu_width/2-5.58/2,0],
    //[-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
  ];

  all_hole_pos = cat(left_mcu_hole_pos,right_mcu_hole_pos);
  //all_hole_pos = left_mcu_hole_pos;

  first_hole_of_right_mcu = len(left_mcu_hole_pos);

  echo("all_hole_pos: ", all_hole_pos);

  //pi_pos_y = mcu_pos_y;
  electronics_mounting_hole_spacing = electronics_mounting_hole_pos_y[1] - electronics_mounting_hole_pos_y[0];
  base_pos_y = electronics_mounting_hole_pos_y[0] + electronics_mounting_hole_spacing/2;
  pi_offset_x = 2;
  pi_pos_x = 200/2-30; // + side*5;
  pi_pos_y = base_pos_y+20; // + side*5;
  mcu_pos_y = base_pos_y;

  for(y=electronics_mounting_hole_pos_y) {
    translate([0,y,0]) {
      //% debug_axes(1);
    }
  }

  module position_left_mcu() {
    // left
    //translate([-200/2-15+8+mcu_width/2,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([left*(200/2-mcu_width/2+10-3)-1,mcu_pos_y,left_min_room_under_board]) {
      rotate([0,0,90]) {
        translate([0,mcu_width/2,0]) {
          rotate([left_mcu_angle,0,0]) {
            translate([0,-mcu_width/2,0]) {
              if (side == left) {
                children();
              }
            }
          }
        }
      }
    }
  }

  module old_position_rpi() {
    //translate([0,pi_length/2,min_room_under_boards]) {
    //translate([0,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([pi_offset_x,pi_pos_y-pi_length/2+pi_hole_spacing_x/2+pi_hole_from_edge,min_room_under_board_for_side[0]]) {
      rotate([0,0,-90]) {
        children();
      }
    }
  }

  module position_rpi() {
    //translate([0,pi_length/2,min_room_under_boards]) {
    //translate([0,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([200/2-30,pi_pos_y-pi_length/2+pi_hole_spacing_x/2+pi_hole_from_edge,min_room_under_board_for_side[0]]) {
      rotate([0,0,-90]) {
        children();
      }
    }
  }

  module position_rpi_holes() {
    pi_length = pcb_length(rpi);
    for(x=[left,right],y=[front,rear]) {
      translate([-pi_length/2+pi_hole_spacing_x/2+pi_hole_from_edge+x*pi_hole_spacing_x/2,y*pi_hole_spacing_y/2,0]) {
        children();
      }
    }
  }

  module position_right_mcu() {
    // right
    //translate([4,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    offset_from_bottom = 10;
    translate([0,offset_from_bottom+mcu_length/2+dist_from_extrusion,right_min_room_under_board]) {
      rotate([0,0,90]) {
        translate([0,-mcu_width/2,0]) {
          rotate([-right_mcu_angle,0,0]) {
            translate([0,mcu_width/2,0]) {
              rotate([0,0,180]) {
                //if (side == right) {
                  children();
                //}
              }
            }
          }
        }
      }
    }
  }

  module position_mcus() {
    position_left_mcu() {
      children();
    }
    position_right_mcu() {
      children();
    }
  }

  module flat_position_for_hole(i) {
    hole_pos = all_hole_pos[i];
    mcu_angle = (i < first_hole_of_right_mcu) ? left_mcu_angle : right_mcu_angle;
    min_room_under_boards = (i < first_hole_of_right_mcu) ? left_min_room_under_board : right_min_room_under_board;
    flat_ratio = get_flat_ratio(mcu_angle);
    translate([hole_pos[0],mcu_width/2,0]) {
      rotate([-mcu_angle,0,0]) {
        translate([0,(-mcu_width/2+hole_pos[1])*flat_ratio,-min_room_under_boards]) {
          children();
        }
      }
    }
  }

  module flat_position_for(hole_pos) {
    translate([hole_pos[0],mcu_width/2,0]) {
      rotate([-mcu_angle,0,0]) {
        translate([0,(-mcu_width/2+hole_pos[1])*flat_ratio,-min_room_under_boards]) {
          children();
        }
      }
    }
  }

  module position_mcu_holes() {
    position_left_mcu() {
      for(p=left_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }

    position_right_mcu() {
      for(p=right_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }
  }

  module board_position_for_hole(i) {
    if (i < len(left_mcu_hole_pos)) {
      position_left_mcu() {
        children();
      }
    } else {
      position_right_mcu() {
        children();
      }
    }
  }

  module base_for_hole(i) {
    board_position_for_hole(i) {
      flat_position_for_hole(i) {
        translate([0,0,base_height/2]) {
          scale([1,1.5,1]) {
            hole(post_od,base_height,resolution);
          }
        }
        // children();
      }
    }
  }
  module position_for_hole(i) {
    board_position_for_hole(i) {
      translate(all_hole_pos[i]) {
        children();
      }
    }
  }

  module body() {
    for (i=[0:len(all_hole_pos)-1]) {
      echo("i: ", i);
      hull() {
        position_for_hole(i) {
          translate([0,0,-bevel_height-post_thread_depth/2]) {
            hole(post_od,post_thread_depth+0.2,resolution);
          }
        }
        base_for_hole(i);
      }
    }

    // FIXME: rpi mounts
    for(x=[left,right],y=[front,rear]) {
      min_room_under_boards = min_room_under_board_for_side[0];
      translate([pi_pos_x+x*pi_hole_spacing_y/2,pi_pos_y+y*pi_hole_spacing_x/2,0]) {
        hull() {
          translate([0,0,base_height/2]) {
            hole(post_od,base_height,resolution);
          }
          translate([0,0,min_room_under_boards-bevel_height-0.1]) {
            hole(post_od,0.2,resolution);
          }
        }

        translate([0,0,min_room_under_boards]) {
          bevel(post_od, pi_post_id+extrude_width*2*2, bevel_height);
        }
      }
    }
    /*
    */

    position_rpi() {
      //% pcb(rpi);
    }
    position_left_mcu() {
      %pcb(left_mcu);
    }
    position_right_mcu() {
      rotate([0,0,180]) {
        %pcb(right_mcu);
      }
    }

    /*
    // join top to bottom
    hull() {
      translate([pi_offset_x+side*pi_hole_spacing_y/2,pi_pos_y+pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
      translate([pi_offset_x+side*pi_hole_spacing_y/2,pi_pos_y-pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
    }

    // lower left mounting hole to bottom left of pi
    hull() {
      translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
      translate([pi_offset_x+side*pi_hole_spacing_y/2,pi_pos_y-pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
    }

    // upper left mounting hole to top left of pi
    hull() {
      translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
      translate([pi_offset_x+side*pi_hole_spacing_y/2,pi_pos_y+pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
    }
    */

    if (side == left) {
      /*
      // top left of left mcu to top mounting hole
      hull() {
        base_for_hole(4);
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }
      */

      // top left of left mcu to top right of left mcu
      hull() {
        base_for_hole(4);
        base_for_hole(0);
      }

      // upper mounting hole to top right of left mcu
      hull() {
        base_for_hole(0);
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // upper right of left mcu to upper left of of right mcu
      hull() {
        base_for_hole(0);
        base_for_hole(3+first_hole_of_right_mcu); // 3 == upper left
      }

      // upper mounting hole to lower left of right mcu
      hull() {
        base_for_hole(2+first_hole_of_right_mcu); // 2 == lower left
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // lower left of right mcu to lower mounting hole
      hull() {
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
        base_for_hole(2+first_hole_of_right_mcu); // 2 == lower left
      }

      // lower mounting hole to bottom right of left mcu
      hull() {
        base_for_hole(2);
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // lower right of left mcu to lower middle of left mcu
      hull() {
        base_for_hole(1);
        base_for_hole(2);
      }
      // lower middle of left mcu to lower left of left mcu
      hull() {
        base_for_hole(3);
        base_for_hole(1);
      }
    } else {
      // upper mounting hole to top right of right mcu
      hull() {
        base_for_hole(0+first_hole_of_right_mcu);
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // upper mounting hole to bottom left of pi
      hull() {
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
        translate([pi_pos_x- pi_hole_spacing_y/2,pi_pos_y - pi_hole_spacing_x/2,base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // bottom left of pi to bottom right of right mcu
      hull() {
        translate([pi_pos_x- pi_hole_spacing_y/2,pi_pos_y - pi_hole_spacing_x/2,base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
        base_for_hole(1+first_hole_of_right_mcu); // 1 == lower right
      }

      // bottom right of right mcu to lower mounting hole
      hull() {
        base_for_hole(1+first_hole_of_right_mcu); // 1 == lower right
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // upper mounting hole to top left of pi
      hull() {
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
        translate([pi_pos_x-pi_hole_spacing_y/2,pi_pos_y+pi_hole_spacing_x/2,base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // bottom left of pi to bottom right of pi
      // top left of pi to top right of pi
      for(y=[front,rear]) {
        hull() {
          for(x=[left,right]) {
            translate([pi_pos_x+x*pi_hole_spacing_y/2,pi_pos_y+y*pi_hole_spacing_x/2,base_height/2]) {
              hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
            }
          }
        }
      }

      /*

      // lower mounting hole to lower right of mcu
      hull() {
        base_for_hole(2+first_hole_of_right_mcu);
        translate([side*z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
          hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
        }
      }

      // lower left mcu to lower right of mcu
      hull() {
        base_for_hole(2+first_hole_of_right_mcu); // 2 == lower left
        base_for_hole(1+first_hole_of_right_mcu); // 1 == lower right
      }

      // upper left mcu to upper right of mcu
      hull() {
        //base_for_hole(3+first_hole_of_right_mcu); // 3 == upper left
        //base_for_hole(0+first_hole_of_right_mcu); // 0 == upper right
      }
      */
    }

    /*
    // upper right mounting hole
    hull() {
      base_for_hole(4);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    // lower right mounting hole
    hull() {
      base_for_hole(7);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    //hull() { base_for_hole(5); base_for_hole(6); } // join upper and lower

    hull() { base_for_hole(0); base_for_hole(3); } // upper left
    hull() { base_for_hole(1); base_for_hole(2); } // lower left

    hull() { base_for_hole(4); base_for_hole(5); } // upper right
    hull() { base_for_hole(6); base_for_hole(7); } // lower right
    */

    position_mcu_holes() {
      bevel(post_od, post_id+extrude_width*4*2, bevel_height);
    }
  }

  module holes() {
    position_mounting_holes() {
      hole(m3_loose,100,resolution);
    }
    position_mcu_holes() {
      hole(post_id,post_thread_depth*2,resolution);
    }
    position_rpi() {
      % pcb(rpi);
      position_rpi_holes() {
        hole(pi_post_id,post_thread_depth*2,resolution);
      }
    }

    translate([-pi_hole_spacing_y/2+10+side*10,pi_pos_y,0]) {
      // hole(pi_post_id,post_thread_depth*2,resolution);
    }
  }

  difference() {
    body();
    holes();
  }
}

module double_mcu_mount() {
  mcu_angle = -10;
  min_room_under_boards = 13;
  m3_loose = 3.3;
  m3_thread_into = 2.7;
  post_id = m3_thread_into;
  post_od = post_id + extrude_width*2*2*2;
  post_thread_depth = 6;
  bevel_height = 2;

  base_height = 3;

  pi_hole_spacing_x = 58;
  pi_hole_spacing_y = 49;
  pi_hole_from_edge = 3.5;
  pi_screw_hole_diam = 2.3;
  pi_post_id = pi_screw_hole_diam;

  flat_ratio = cos(abs(mcu_angle));

  echo("flat_ratio: ", flat_ratio);

  dist_from_extrusion = 10; // so that the mounting holes and mcu holes don't foul each other

  left_mcu_hole_pos = [
    [mcu_length/2-5/2,-64.47/2,0],
    [-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
    [-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
    [-mcu_length/2+20.3,mcu_width/2-5.58/2,0],
    [-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
  ];

  right_mcu_hole_pos = [
    [mcu_length/2-5/2,-64.47/2,0],
    [-mcu_length/2+20.3+62.15,mcu_width/2-5.58/2,0],
    [-mcu_length/2+post_id/2,-mcu_width/2+post_id,0], // screwless posts to stabilize since we only have two screw posts
    [-mcu_length/2+20.3,mcu_width/2-5.58/2,0],
    [-mcu_length/2+5/2,mcu_width/2-34.98-5.58/2,0],
  ];

  //all_hole_pos = cat(left_mcu_hole_pos,right_mcu_hole_pos);
  all_hole_pos = left_mcu_hole_pos;

  echo("all_hole_pos: ", all_hole_pos);

  //pi_pos_y = mcu_pos_y;
  electronics_mounting_hole_spacing = electronics_mounting_hole_pos_y[1] - electronics_mounting_hole_pos_y[0];
  pi_pos_y = electronics_mounting_hole_pos_y[0] + electronics_mounting_hole_spacing/2;
  mcu_pos_y = pi_pos_y;

  for(y=electronics_mounting_hole_pos_y) {
    translate([0,y,0]) {
      //% debug_axes(1);
      
    }
  }

  module position_left_mcu() {
    // left
    //translate([-200/2-15+8+mcu_width/2,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([left*(200/2-mcu_width/2),mcu_pos_y,min_room_under_boards]) {
      rotate([0,0,90]) {
        translate([0,mcu_width/2,0]) {
          rotate([mcu_angle,0,0]) {
            translate([0,-mcu_width/2,0]) {
              children();
            }
          }
        }
      }
    }
  }

  module position_rpi() {
    //translate([0,pi_length/2,min_room_under_boards]) {
    //translate([0,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([0,pi_pos_y-pi_length/2+pi_hole_spacing_x/2+pi_hole_from_edge,min_room_under_boards]) {
      rotate([0,0,-90]) {
        children();
      }
    }
  }

  module position_right_mcu() {
    // right
    //translate([4,mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
    translate([right*(200/2-mcu_width/2),mcu_length/2+dist_from_extrusion,min_room_under_boards]) {
      rotate([0,0,90]) {
        translate([0,-mcu_width/2,0]) {
          rotate([-mcu_angle,0,0]) {
            translate([0,mcu_width/2,0]) {
              rotate([0,0,180]) {
                //children();
              }
            }
          }
        }
      }
    }
  }

  module position_mcus() {
    position_left_mcu() {
      children();
    }
    position_right_mcu() {
      children();
    }
  }

  module flat_position_for(hole_pos) {
    translate([hole_pos[0],mcu_width/2,0]) {
      rotate([-mcu_angle,0,0]) {
        translate([0,(-mcu_width/2+hole_pos[1])*flat_ratio,-min_room_under_boards]) {
          children();
        }
      }
    }
  }

  module position_mcu_holes() {
    position_left_mcu() {
      for(p=left_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }

    position_right_mcu() {
      for(p=right_mcu_hole_pos) {
        translate(p) {
          children();
        }
      }
    }
  }

  module board_position_for_hole(i) {
    if (i < len(left_mcu_hole_pos)) {
      position_left_mcu() {
        children();
      }
    } else {
      position_right_mcu() {
        children();
      }
    }
  }

  module base_for_hole(i) {
    board_position_for_hole(i) {
      flat_position_for(all_hole_pos[i]) {
        translate([0,0,base_height/2]) {
          scale([1,1.5,1]) {
            hole(post_od,base_height,resolution);
          }
        }
        // children();
      }
    }
  }
  module position_for_hole(i) {
    board_position_for_hole(i) {
      translate(all_hole_pos[i]) {
        children();
      }
    }
  }

  module body() {
    for (i=[0:len(all_hole_pos)-1]) {
      echo("i: ", i);
      hull() {
        position_for_hole(i) {
          translate([0,0,-bevel_height-post_thread_depth/2]) {
            hole(post_od,post_thread_depth+0.2,resolution);
          }
        }
        base_for_hole(i);
      }
    }

    for(y=[front,rear]) {
      translate([-pi_hole_spacing_y/2,pi_pos_y+y*pi_hole_spacing_x/2,0]) {
        hull() {
          translate([0,0,base_height/2]) {
            hole(post_od,base_height,resolution);
          }
          translate([0,0,min_room_under_boards-bevel_height-0.1]) {
            hole(post_od,0.2,resolution);
          }
        }

        translate([0,0,min_room_under_boards]) {
          bevel(post_od, pi_post_id+extrude_width*2*2, bevel_height);
        }
      }
    }

    position_rpi() {
      % pcb(rpi);
    }
    position_left_mcu() {
      %pcb(mcu);
    }
    position_right_mcu() {
      //%pcb(mcu);
    }

    // upper mounting hole to top right of mcu
    hull() {
      base_for_hole(0);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    // upper mounting hole to top left of mcu
    hull() {
      base_for_hole(4);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    // upper left mounting hole to top left of pi
    hull() {
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
      translate([-pi_hole_spacing_y/2,pi_pos_y+pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
    }

    // lower left mounting hole to bottom left of pi
    hull() {
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
      translate([-pi_hole_spacing_y/2,pi_pos_y-pi_hole_spacing_x/2,base_height/2]) {
        hole(post_od,base_height,resolution);
      }
    }
    // lower left mounting hole to bottom right of mcu
    hull() {
      base_for_hole(2);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    // lower left mounting hole to bottom middle of mcu
    hull() {
      base_for_hole(1);
      translate([-z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }
    // lower left of mcu to bottom middle of mcu
    hull() {
      base_for_hole(3);
      base_for_hole(1);
    }

    /*
    // upper right mounting hole
    hull() {
      base_for_hole(4);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[1],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    // lower right mounting hole
    hull() {
      base_for_hole(7);
      translate([z_rail_spacing/2,electronics_mounting_hole_pos_y[0],base_height/2]) {
        hole(m3_loose+extrude_width*3*2*2,base_height,resolution);
      }
    }

    //hull() { base_for_hole(5); base_for_hole(6); } // join upper and lower

    hull() { base_for_hole(0); base_for_hole(3); } // upper left
    hull() { base_for_hole(1); base_for_hole(2); } // lower left

    hull() { base_for_hole(4); base_for_hole(5); } // upper right
    hull() { base_for_hole(6); base_for_hole(7); } // lower right
    */

    position_mcu_holes() {
      bevel(post_od, post_id+extrude_width*2*2, bevel_height);
    }
  }

  module holes() {
    position_mounting_holes() {
      hole(m3_loose,100,resolution);
    }
    position_mcu_holes() {
      hole(post_id,post_thread_depth*2,resolution);
    }

    for(y=[front,rear]) {
      translate([-pi_hole_spacing_y/2,pi_pos_y+y*pi_hole_spacing_x/2,min_room_under_boards]) {
        hole(pi_post_id,post_thread_depth*2,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module mcu_mount(side=0) {
  dist_from_extrusion = 3;

  mount_thickness = 4;
  mcu_post_id = 2.8; // thread into m3
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
  mount_plate_center_pos_x = (-mcu_x_offsets[0]-mcu_x_offsets[1])/2;
  mount_plate_center_pos_y = electronics_mounting_hole_pos_y[0]+mount_plate_spacing_y/2;
  mount_plate_outer_x = mount_plate_spacing_x+mcu_post_od;
  mount_plate_outer_y = mount_plate_spacing_y+mcu_post_od;
  mount_plate_inner_x = mount_plate_outer_x-mcu_post_od*2;
  mount_plate_inner_y = mount_plate_outer_y-mcu_post_od*2;

  mount_screw_head_od = 6;
  mount_screw_body_od = mount_screw_head_od+extrude_width*2*2*2;

  module position_mounting_holes() {
    for(x=mcu_x_offsets,y=electronics_mounting_hole_pos_y) {
      translate([-x,y,0]) {
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
        translate([-mcu_x_offsets[0],electronics_mounting_hole_pos_y[1],0]) {
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
        translate([-mcu_x_offsets[1],dist_from_extrusion+mcu_length/2+mcu_hole_pos[1][y],0]) {
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
        translate([-mcu_x_offsets[1],dist_from_extrusion+mcu_length/2+mcu_hole_pos[2][y],0]) {
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
  pi_dist_from_extrusion = 20;
  post_height = 10; // reach over PoE header
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
  extrusion_mount_hole_spacing = pi_length + 14;
  extrusion_mount_length = extrusion_mount_hole_spacing + 12;
  extrusion_mount_offset = -pi_hole_spacing_x/2+pi_length/2-pi_hole_from_edge;

  extrusion_mount_thickness = extrude_width*3*2;
  bevel_tip = post_id + 0.4*2*2;

  extrusion_mount_hole_diam = 3+0.2;
  extrusion_mount_nut_side = 6.2+0.2; // allow for a hex nut to fit (rather than ~5.5 flat to flat square nut)

  overall_height = pi_dist_from_back+pcb_thickness(rpi)+post_height+arm_thickness;


  module position_rpi() {
    translate([0,-200/2+pi_width/2,15]) {
      rotate([0,0,0]) {
        children();
      }
    }
    /*
    // right side the rightmost mcu
    translate([left*(pi_width/2+10),pi_length/2+15,15-sheet_thickness-2]) {
      rotate([0,0,-90]) {
        children();
      }
    }
    */
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
    /*
    for(y=[front,rear]) {
      translate([extrusion_mount_thickness,extrusion_mount_offset+y*extrusion_mount_hole_spacing/2,-15/2]) {
        rotate([0,90,0]) {
          children();
        }
      }
    }
    */
  }

  module body() {
    translate([extrusion_mount_thickness/2,extrusion_mount_offset,-overall_height/2]) {
      //rounded_cube(extrusion_mount_thickness,extrusion_mount_length,overall_height, extrusion_mount_thickness);
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

    /*
    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([0,pi_hole_spacing_x/2,-overall_height]) {
          post_remaining = post_height-bevel_height;
          for(x=[left,right]) {
            translate([pi_dist_from_extrusion+pi_hole_from_edge+pi_hole_spacing_y/2+x*(pi_hole_spacing_y/2),0,arm_thickness]) {
              translate([0,0,post_remaining/2]) {
                hull() {
                  hole(post_od,post_remaining,resolution);
                  translate([-post_od/4,post_od/2+arm_support_thickness/2,0]) {
                    //# cube([post_od,arm_support_thickness,post_remaining],center=true);
                    rounded_cube(post_od/2,arm_support_thickness,post_remaining,arm_support_thickness);
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
              translate([pi_dist_from_extrusion+pi_hole_from_edge+pi_hole_spacing_y-arm_support_thickness/2,0,0]) {
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
                translate([-post_od/4,post_od/2+arm_support_thickness/2,0]) {
                  rounded_cube(post_od/2,arm_support_thickness,arm_thickness,arm_support_thickness);
                }
              }
            }
          }
        }
      }
    }
    */
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
      //% pcb(rpi);
    }
  }
}

translate([200/2,-200/2+15+pi_length/2+42,dist_front_to_back-15]) {
//translate([200/2,-200/2+pi_length/2-24,dist_front_to_back-15]) {
  //rpi_clip_mount();
}


dist_from_extrusion = 3;
mcu_pos_y = mcu_length/2+dist_from_extrusion;
electronics_mounting_hole_spacing = electronics_mounting_hole_pos_y[1] - electronics_mounting_hole_pos_y[0];
pi_pos_y = electronics_mounting_hole_pos_y[0] + electronics_mounting_hole_spacing/2;
translate([0,-pi_pos_y,0]) {
  rotate([0,0,180]) {
    translate([0,-200/2+2,0]) {
      //new_double_mcu_mount(right);
    }
  }
}
translate([0,-200/2+15+pi_pos_y,12]) {
  pi_hole_spacing_y = 49;
  pi_hole_spacing_x = 58;
  pi_hole_from_edge = 3.5;
  translate([0,-pi_length/2+pi_hole_spacing_x/2+pi_hole_from_edge,0]) {
    rotate([0,0,-90]) {
      //% pcb(rpi);
    }
  }
}
//double_mcu_mount();

mount_assembly();
//new_double_mcu_mount(left);
//new_double_mcu_mount(right);

//buck_converter_clip_mount();

translate([0,0,200]) {
  // rpi_mount();
}
