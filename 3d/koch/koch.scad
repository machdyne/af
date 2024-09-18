/*
 * Koch Case
 * Copyright (c) 2024 Lone Dynamics Corporation. All rights reserved.
 *
 * required hardware:
 *  - 4 x M3 x 20mm countersunk bolts
 *  - 4 x M3 nuts
 *
 */

$fn = 100;

board_width = 30;
board_thickness = 1.5;
board_length = 50;
board_height = 1.6;
board_spacing = 2;

wall = 1.5;

top_height = 14;
bottom_height = 6;

translate([wall,wall,0]) afc_board();

translate([0,0,15])
	afc_case_top();

translate([0,0,-15])
	afc_case_bottom();

module afc_board() {
	
	difference() {
		color([0,0.5,0])
			roundedcube(board_width,board_length,board_thickness,5);
		translate([5, 5, -1]) cylinder(d=3.2, h=10);
		translate([5, 45, -1]) cylinder(d=3.2, h=10);
		translate([25, 5, -1]) cylinder(d=3.2, h=10);
		translate([25, 45, -1]) cylinder(d=3.2, h=10);
	}	
	
}

module afc_case_top() {
	

	difference() {
				
		color([0.5,0.5,0.5])
			roundedcube(board_width+(wall*2),board_length+(wall*2),top_height,5);

		// cutouts
			
		translate([1.5,9.5,-2])
			roundedcube(board_width,board_length-16,14.5,5);

		translate([9.5,2,-2])
			roundedcube(board_width-16,board_length,10.25,5);			
	
		translate([wall, wall, 0]) {

			// vents
			translate([25-(15/2),25,0]) rotate([0,0,-10]) cube([10,1,20]);
			translate([25-(15/2),20,0]) rotate([0,0,-10]) cube([10,1,20]);
			translate([25-(15/2),30,0]) rotate([0,0,-10]) cube([10,1,20]);			

			// POWER JACK
			translate([15-(9.5/2),30,-2]) cube([9.5,30,11.25+1.75]);

			// BOOT BUTTON
			translate([15-(7.6/2),-2,-2]) cube([7.6,30,7+1.75]);

			// USBC
			translate([-2,50-15-(10.5/2),-2]) cube([30,10.5,3.5+1.75]);

			// PNP CHAIN CONNECTOR
			translate([-2,50-34.2-(11/2),-2]) cube([30,11,3+1.75]);


			// bolt holes
			translate([5, 5, -21]) cylinder(d=3.5, h=40);
			translate([5, 45, -21]) cylinder(d=3.5, h=40);
			translate([25, 5, -20]) cylinder(d=3.5, h=40);
			translate([25, 45, -21]) cylinder(d=3.5, h=40);

			// flush mount bolt holes
			translate([5, 5, top_height-1.5]) cylinder(d=5.25, h=4);
			translate([5, 45, top_height-1.5]) cylinder(d=5.25, h=4);
			translate([25, 5, top_height-1.5]) cylinder(d=5.25, h=4);
			translate([25, 45, top_height-1.5]) cylinder(d=5.25, h=4);

			// koch text
			rotate(270)
				translate([-25,3.5,top_height-0.5])
					linear_extrude(1)
						text("K O C H", size=4, halign="center",
							font="Ubuntu:style=Bold");

		}
		
	}	
}

module afc_case_bottom() {
	
	difference() {
		color([0.5,0.5,0.5])
			roundedcube(board_width+(wall*2),board_length+(wall*2),bottom_height,5);
		
		// cutouts
		translate([3,10,1.5])
			roundedcube(board_width-3,board_length-17,10,5);
				
		translate([10.5,2.5,1.5])
			roundedcube(board_width-17.5,board_length-2,10,5);

		translate([wall, wall, 0]) {
			
		// board cutout
		translate([0,0,bottom_height-board_height])
			roundedcube(board_width+0.2,board_length+0.2,board_height+1,2.5);

		translate([wall, wall, 0]) {

			// USBC
			translate([30.5,43,5]) cube([10.20,15,10.5+1]);

		}

		// bolt holes
		translate([5, 5, -11]) cylinder(d=3.2, h=25);
		translate([5, 45, -11]) cylinder(d=3.2, h=25);
		translate([25, 5, -11]) cylinder(d=3.2, h=25);
		translate([25, 45, -11]) cylinder(d=3.2, h=25);

		// nut holes
		translate([5, 5, -1]) cylinder(d=7, h=4, $fn=6);
		translate([5, 45, -1]) cylinder(d=7, h=4, $fn=6);
		translate([25, 5, -1]) cylinder(d=7, h=4, $fn=6);
		translate([25, 45, -1]) cylinder(d=7, h=4, $fn=6);

		}
		
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
