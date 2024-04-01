include <./main.scad>;

space_between = 5;

/*
*/
translate([right*(stack_width+space_between)/2,rear*(stack_depth+space_between)/2,fan_stack_height/2]) {
  rotate([0,180,0]) {
    fan_stack();
  }
}

translate([left*(stack_width+space_between)/2,front*(stack_depth+space_between)/2,carbon_hepa_stack_height/2]) {
  //carbon_stack();
  carbon_hepa_stack();
}

translate([left*(stack_width+space_between)/2,rear*(stack_depth+space_between)/2,hepa_stack_height/2]) {
  //hepa_stack();
}

translate([right*(stack_width+space_between)/2,front*(stack_depth+space_between)/2,lid_stack_height/2]) {
  rotate([0,180,0]) {
    lid_stack();
  }
}

/*
spacing = stack_depth+space_between;

translate([0,rear*(spacing*1.5),fan_stack_height/2]) {
  rotate([0,180,0]) {
    fan_stack();
  }
}

translate([0,rear*(spacing/2),carbon_stack_height/2]) {
  carbon_stack();
}

translate([0,front*(spacing/2),hepa_stack_height/2]) {
  hepa_stack();
}

translate([0,front*(spacing*1.5),lid_stack_height/2]) {
  rotate([0,180,0]) {
    lid_stack();
  }
}
*/
