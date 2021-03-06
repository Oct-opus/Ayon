echo(version=version());

//Display casing
casing_width     = 30;
casing_depth     = 22;
casing_height    = 7;
casing_thiccness = 0.4;

//Display hole
display_width  = 24.7;
display_depth  = 16.2;
display_height = 1.6;

//Display bezel
bezel_size      = 1.6;
bezel_thiccness = 0.2;

//Keyboard
keyboard_angle       = -15;
keyboard_depth_ratio = 0.9;

//Separator
separator_diameter = 1;
separator_depth = 5;
separator_segments = 8;

module rotate_about_pt(x, z, y, pt){
    translate(pt)
    rotate([x, y, z])
    translate(-pt)
    children();
}

module display_casing(hollow){
  if (hollow == false) {
    difference(){
      //Body
      color("gray")
      cube([casing_width, casing_depth, casing_height], center= false);
    }
  }
  else {
    union(){
      //Display hole
      display_width_offset = (casing_width - display_width) / 2;
      display_depth_offset = (casing_depth - display_depth) / 2;
      display_height_offset = casing_height - display_height;
      color("red")
      translate([display_width_offset, display_depth_offset, display_height_offset])
      cube([display_width, display_depth, display_height], center= false);

      //Display bezel
      bezel_width_offset = (casing_width - display_width - bezel_size) / 2;
      bezel_depth_offset = (casing_depth - display_depth - bezel_size) / 2;
      bezel_height_offset = casing_height - bezel_thiccness;
      color("blue")
      translate([bezel_width_offset, bezel_depth_offset, bezel_height_offset])
      cube([display_width + bezel_size, display_depth + bezel_size, bezel_thiccness], center= false);

      //Cavity
      translate([casing_thiccness, casing_thiccness, casing_thiccness])
      cube([casing_width - casing_thiccness * 2,
        casing_depth - casing_thiccness * 2 + casing_thiccness,
        casing_height - casing_thiccness * 2],
        center= false);
    }
  }
}

module keyboard(hollow){
  //Apply ration to every element in keyboard modue
  translate([0, casing_depth, 0])
  rotate_about_pt(keyboard_angle, 0, 0, [0, 0, casing_height])

  if (hollow == false){
    cube([casing_width, casing_depth * keyboard_depth_ratio, casing_height], center= false);
  }
  else {
    translate([casing_thiccness, 0, casing_thiccness])
    cube([casing_width - casing_thiccness * 2,
      casing_depth * keyboard_depth_ratio - casing_thiccness,
      casing_height - casing_thiccness * 2],
      center= false);
  }
}

module separator(hollow){
  diameter= hollow ? separator_diameter - casing_thiccness : separator_diameter;
  e=.02;
  color("purple")
  translate([casing_width, casing_depth, casing_height])
  rotate([0, -90, 0])
  if (hollow == false) {
    difference(){
        cylinder($fn= separator_segments,
        h= casing_width,
        r= diameter,
        center= false);
      translate([0, -diameter, -e])
      rotate_about_pt(0, -keyboard_angle * 0.8,  0, [0, 0, casing_height])
      cube([diameter * 2, diameter * 2, casing_width + 2 * e]);
    }
  }
  else {
    cylinder($fn= separator_segments,
      h= casing_width,
      r= diameter,
      center= false);
  }
}

module main_body(){
  difference(){
    union (){
      difference(){
        union(){
          display_casing(false);
          keyboard(false);
        }
        keyboard(true);
        display_casing(true);
      }
      separator(false);
    }
    separator(true);
  }
}

//minkowski() {
main_body();
//  sphere(1);
//}
