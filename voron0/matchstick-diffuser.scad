include <lumpyscad/lib.scad>;

extrude_width = 0.4;

module matchstick_diffuser() {
  wall_thickness = extrude_width*3;
  num_leds = 10;
  led_spacing = 14.152;
  led_spacer = 1;
  led_side = 5;
  led_height = 1.7;
  height_above_led = 2; // increase for more diffusion
  cavity_height = led_height+height_above_led;
  hole_spacing = 85;

  diffuser_thickness = 0.6;
  led_cooling_air_gap = 1;

  //width = 11; // doesn't need to be so wide, though
  width = led_side+2*(led_spacer+wall_thickness); // doesn't need to be so wide, though
  //length = 158; // maybe shorter to fit on v0?
  length = (num_leds-1)*(led_spacing)+led_side+width;
  echo("length: ", length);
  height = cavity_height+diffuser_thickness;

  screw_hole_diam = 3.3;
  screw_head_diam = 5.9;
  screw_delta = screw_head_diam-screw_hole_diam;
  meat_for_screw_area = screw_head_diam+2*(extrude_width*2);
  echo("meat_for_screw_area: ", meat_for_screw_area);
  echo("wall_thickness: ", wall_thickness);

  module body() {
    translate([0,0,height/2]) {
      rounded_cube(length,width,height,width);
    }
    for(x=[left,right]) {
      translate([x*hole_spacing/2,0,height]) {
        hole(meat_for_screw_area,led_cooling_air_gap*2,resolution);
      }
    }
    translate([0,0,height+led_cooling_air_gap-led_height/2]) {
      for(x=[left,right],i=[0:4]) {
        translate([x*((i+0.5)*led_spacing),0]) {
          % cube([led_side,led_side,led_height],center=true);
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      translate([x*hole_spacing/2,0,0]) {
        hole(screw_hole_diam,height*3,resolution);
        screw_head_recess_by = 1.2;

        hull() {
          hole(screw_hole_diam,screw_delta+screw_head_recess_by*2,resolution);
          hole(screw_hole_diam+screw_delta,screw_head_recess_by*2,resolution);
        }
      }
    }

    translate([0,0,height]) {
      difference() {
        rounded_cube(length-wall_thickness*2,width-wall_thickness*2,cavity_height*2,width-wall_thickness*2);
        for(x=[left,right]) {
          translate([x*hole_spacing/2,0,0]) {
            cube([meat_for_screw_area,width*2,height*5],center=true);
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

matchstick_diffuser();
