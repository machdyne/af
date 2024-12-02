/*
 * PnP Autofeeder
 * Copyright (c) 2024 Lone Dynamics Corporation. All rights reserved.
 * 
 */

tape_width = 8.2;
tape_thickness = 1.2;
tape_pitch = 4;

gear_spokes = 20;
gear_d = gear_spokes * tape_pitch / PI;

rotate([90,0,0]) {
	
	af();

	translate([0,11.75,0]) af_led_block();
	
	af_motor_lock();
	translate([0,0.85,0]) af_blade();
//	translate([0,0.85,0]) af_film_puller();
//	translate([0,0,10]) af_lid();
	
//	translate([-100,12,0.9]) af_tape();

	color([0,0,0,0.5]) rotate([270,0,0]) translate([-44.5,-5,0.5]) af_sprocket();
	
	rotate([270,180,0]) translate([-85,-7,-12]) af_pcb();
	rotate([90,0,180]) translate([22.75,-2,0.5]) af_tape_motor();

}

module af_tape() {
	color([1,1,1]) cube([200,1,8]);
	
}

module af_tape_motor(margin=0) {
	 
	 translate([8.75,0,-0]) color([1,1,0.7]) cube([34, 10+margin, 12+margin], center=true);


	 color([1,1,0]) translate([16.5+9-3.5,8.5,0]) rotate([90,0,0])
		cylinder(d=3, h=7.5, center=true, $fn=36);

}

module af_pcb() {
	color([0,1,0]) translate([40,0,0]) cube([50,15,1.6]);
	color([0,0,0]) translate([40,0,1.6]) cube([5,15,5]);
}

module af_sprocket() {
	gear_spokes = 20;
	difference() {
		union() {
			for (i = [0:gear_spokes-1]) {
				rotate([90,0,90]) translate([-2.75,0,0])
					rotate([i*(360/gear_spokes),0,0])
						translate([0,0,11])
							cylinder(d1=1.5, d2=1, h=2.25, $fn=36);
			}
			rotate([90,0,0]) translate([0,0,2]) cylinder(d=gear_d-2.5, h=1.5);
			rotate([90,0,0]) translate([0,0,-0.5]) cylinder(d=8, h=3.5, $fn=36);
			rotate([90,0,0]) translate([0,0,3]) cylinder(d=6, h=3.5, $fn=36);
			
		}
		rotate([90,0,0]) difference() {
			translate([0,0,2]) cylinder(d=3, h=20, center=true, $fn=36);
			translate([1.75,0,2]) cube([1,10,10], center=true);
		}
		
	}
}

module af_lid() {
	
	difference() {

		union() {
			translate([-126/2,-35/2-1.5,-2/2]) roundedcube(120,35,2,2.5);
		}
		
		// bolt holes
		translate([40,5,-20]) cylinder(d=3.5, h=50, $fn=36);
		translate([-20,-11,-20]) cylinder(d=3.5, h=50, $fn=36);
		translate([-58,11.5,-20]) cylinder(d=3.5, h=50, $fn=36);
		
		// flush mount bolt holes
		translate([40,5,0]) cylinder(d=5, h=50, $fn=36);
		translate([-20,-11,0]) cylinder(d=5, h=50, $fn=36);
		translate([-58,11.5,0]) cylinder(d=5, h=50, $fn=36);

		// axle
		translate([-44.75,0.5,-5]) cylinder(d=8, h=50, $fn=36);

		// logo
		translate([-15,-1.5,0.5])
				linear_extrude(5)
					text("/ / / A C H D Y N E", size=4, halign="center",
						font="Liberation Sans:style=Bold");		

		translate([20,-4,0.5])
				linear_extrude(5)
					text("AF", size=10, halign="center",
						font="Liberation Sans:style=Bold");		
		
	}
}

module af_blade() {
	
	union() {
	
		// blade mount
		difference() {
			translate([-10,16,-6.5]) cube([10,3,10.5]);
			translate([-5,20,-3.5]) rotate([90,0,0])
				cylinder(d=3.25, h=10, $fn=36);
		}
		
		rotate([0,0,-5]) {
			
			translate([-10,13.25,1]) cube([15,5,4]);

			// film blade
			translate([0,0,0]) rotate([0,0,0]) difference() {

				translate([-10,13,1]) cube([25,1,4]);
				translate([11,14.5,0.5]) rotate([0,0,-30]) cube([25,2,4]);
				translate([3,14,3]) rotate([30,0,0]) cube([25,2,4]);
				translate([5,14,10]) rotate([35,45,0]) cube([25,2,4]);

			}

		}
	
	}
}

module af_film_puller() {

			
	union() {
	
		// blade mount
		difference() {
			translate([-10,16,-6.5]) cube([30,19,12]);
			
			// bolt holes
			translate([-5,50,-3.5]) rotate([90,0,0])
				cylinder(d=3.25, h=100, $fn=36);
			translate([15,50,-3.5]) rotate([90,0,0])
				cylinder(d=3.25, h=100, $fn=36);
			
			translate([-5,36,-3.5]) rotate([90,0,0])
				cylinder(d=5, h=2, $fn=36);
			translate([15,36,-3.5]) rotate([90,0,0])
				cylinder(d=5, h=2, $fn=36);
			
			// motor cutout
			translate([5-(12.25/2),28,-5.75]) cube([12.25,50,10.25]);
			translate([5-(10.5/2),29,-5.75]) cube([10.5,50,15.5]);
			
			// gear axle
			translate([5,22,-10]) rotate([0,0,0])
				cylinder(d=3.5, h=50, $fn=36);
				//cylinder(d=3.25, h=50, $fn=36);


	
		}
		
	}


}
		
module af_motor_lock() {
	difference() {
		translate([-25+0.1,-7.25-5.9,3.4]) cube([9.8,17.5,5]);
		translate([-20,-11,-20]) cylinder(d=3.25, h=50, $fn=36);
	}
}

module af_led_block() {
	
	difference() {
		
		// LED block
		translate([25,25,-6.5]) rotate([90,0,0]) cube([15,15.5,20]);

		// LED mount
		translate([30,28,6.5]) rotate([90,0,0]) cylinder(d=4.5, h=15, $fn=36);
		translate([30,28,6.5]) rotate([90,0,0]) cylinder(d=3.2, h=25, $fn=36);
		
		// lead separator
		translate([27,26,-2]) rotate([90,0,0]) cube([2.25,8.5,5]);
		translate([30.75,26,-2]) rotate([90,0,0]) cube([2.25,8.5,5]);
		
		// LED block screw hole
		translate([36,20,-3]) rotate([90,0,0]) cylinder(d=4, h=35, center=true, 
			$fn=36);

		translate([36,24,-3]) rotate([90,0,0]) cylinder(d=6, h=5, center=true, 
			$fn=36);

		// rail mount hole
		translate([36,15,1.5]) rotate([0,90,0]) cylinder(d=3.75, h=35, center=true, $fn=36);

		// wire escape
		translate([30,10,-3]) rotate([90,0,0]) cylinder(d=6, h=35, center=true, 
			$fn=36);
	}

}

module af() {

// rail:
//	color([0,0,0]) translate([50,27,0]) cube([20,20,100], center=true);
	
	difference() {
		translate([40,5,-7.19]) cylinder(d=10, h=16);
		translate([40,5,-20]) cylinder(d=3.25, h=50, $fn=36);
		translate([40,5,-11]) cylinder(d=7, h=5, $fn=6);
	}
	
	translate([40,-9+7.5,-7.19]) cylinder(d=6, h=16);
		
	// blade lock
	translate([-13,19,-6.5]) rotate([90,0,0])
		cube([3,6.5,3]);

	// led block lock
	translate([20,19,-6.5]) rotate([90,0,0])
		cube([5,12,3]);

	// rear motor lock
	translate([-12,0,-8]) cylinder(d=5, h=5, $fn=36);

	difference() {
		translate([-44.5,0.5,0]) cylinder(d=gear_d-3.5, h=5);
		translate([-23.5,0.5,3.25]) {
			cube([50, 12.1, 20.5], center=true);
		}
		

	}
		
	// tape exit guide
	translate([-45.5,-5.55,-0]) rotate([90,0,-30.75]) cube([10.7,5,5]);
	
	// pcb mount notches
	translate([55-57.5,-10.25,-4.5]) rotate([90,0,0])
		cylinder(d=1.75, h=5, $fn=36);
	translate([55-57.5,-13.25,-4.5]) rotate([90,0,0])
		cylinder(d=3, h=1, $fn=36);
	translate([55-57.5,-10.25,-4.5+8]) rotate([90,0,0])
		cylinder(d=1.75, h=5, $fn=36);
	translate([55-57.5,-13.25,-4.5+8]) rotate([90,0,0])
		cylinder(d=3, h=1, $fn=36);

	difference() {
			
		union() {
			
			minkowski() {
				translate([-3,-2,0]) cube([120-5,37.5-5,18-5], center=true);
				sphere(2.6);
			}
			
			// LED block platform
			translate([25,16.81,-6.5]) rotate([90,0,0]) cube([10,15.5,3.75]);
				
		}
		
		// pick position
		translate([-35,12,-3]) cube([10,50,10]);
		
		// film guide
		translate([-50,12,7]) rotate([0,3,0]) cube([50,50,10]);
		translate([-10,12,0]) cube([30,50,20]);
		translate([1,13.1,0]) rotate([0,-30,25]) cube([5,5,5]);

		// film guide post pick
		translate([-50,12,4]) rotate([0,3,0]) cube([20,50,10]);
		
		// blade mount / film motor mount
		translate([-5,20,-3.5]) rotate([90,0,0])
			cylinder(d=3.25, h=15, $fn=36);

		translate([15,20,-3.5]) rotate([90,0,0])
			cylinder(d=3.25, h=15, $fn=36);
		
		// LED light channel
		translate([30,28,6.5]) rotate([90,0,0]) cylinder(d=3.2, h=20, $fn=36);
		translate([30,28,7.5]) rotate([90,0,0]) cylinder(d=3.2, h=20, $fn=36);
		translate([30,28,8.5]) rotate([90,0,0]) cylinder(d=3.2, h=20, $fn=36);
		
		// LED / motor wire escape
		translate([30,10,-3]) rotate([90,0,0]) cylinder(d=6, h=35, center=true, 
			$fn=36);

		// LED block screw hole
		translate([36,20,-3]) rotate([90,0,0]) cylinder(d=2.9, h=25, center=true, 
			$fn=36);

		// bolt holes
		translate([40,5,-20]) cylinder(d=3.5, h=50, $fn=36);
		translate([-20,-11,-20]) cylinder(d=3.5, h=50, $fn=36);
		translate([-58,11.5,-20]) cylinder(d=3.5, h=50, $fn=36);
		
		// nut holes
		translate([40,5,-11]) cylinder(d=7, h=5, $fn=6);
		translate([-20,-11,-11]) cylinder(d=7, h=5, $fn=6);
		translate([-58,11.5,-11]) rotate([0,0,30]) cylinder(d=7, h=5, $fn=6);
					
		// tape entrance cutout
		translate([-45,12,0.8]) cube([200,tape_thickness,tape_width]);
		translate([-45,12,0]) cube([12,tape_thickness,tape_width]);

		// tape exit cutout
		translate([-45,-17.5,0.0]) cube([200,tape_thickness+1,tape_width+1]);

		// motor cutout
		translate([-23.5,0.5,3.25]) {
			cube([50, 12.1, 20.5], center=true);
		}
		
		// motor lock cutout
		translate([-25,-7.25-6,3.4]) cube([10,10,5.6]);

		// sprocket cutout
		translate([-44,-1,0]) cylinder(d=gear_d+5, h=50);
		
		// pcb cutout
		translate([24,-2,1]) cube([70,22,16], center=true);
		
	}
	
}

// https://gist.github.com/tinkerology/ae257c5340a33ee2f149ff3ae97d9826
module roundedcube(xx, yy, height, radius)
{
    translate([0,0,height/2])
    hull()
    {
        translate([radius,radius,0])
        cylinder(height,radius,radius,true);

        translate([xx-radius,radius,0])
        cylinder(height,radius,radius,true);

        translate([xx-radius,yy-radius,0])
        cylinder(height,radius,radius,true);

        translate([radius,yy-radius,0])
        cylinder(height,radius,radius,true);
    }
}


