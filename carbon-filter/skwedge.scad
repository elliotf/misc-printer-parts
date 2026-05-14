include <lumpyscad/lib.scad>;

module skwedge(side) {
  difference() {
    translate([0,0,side/2]) {
      hole(side, side, 128);
    }
    for(y=[front,rear]) {
      hull() {
        translate([0, y*(side/2+1), side/2]) {
          cube([side+1,2,side],center=true);
        }
        translate([0,y*(side/2),side+1]) {
          cube([side+1,side,2],center=true);
        }
      }
    }
  }
}

skwedge(100);
