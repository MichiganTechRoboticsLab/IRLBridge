IRLBridge and Sensor Fusion Post Process
--
This is the directory I used for the MDOT code, there is some extra code in
here that could also be used for viewing the fusion code from a more general
scale.

-------------------------
*disclosure, I did not actually use version control before this (as it is obvious based
 on the organization of the files below.  I just wanted to get everything in one spot
 so that I can organize it better in the future.

-------------------------
testviewsets
	The codesets in this folder allow you to view the post-processed datasets

File			| Description
------------------------|--------------
testview.m		| first iteration of the testview code
testview2_1.m		| testview code husam modified to create 3d models of the dataset we collected outdoors
testview2.m		| second iteration of the testview code
testviewv3_base.m	| third iteration of the testview code, this is the first one to actually convert gps to meters

-------------------------
utils
	various utilities I use for the viewbridge sets and the testviewsets

File		| Description
----------------|--------------
find_diff.m	| Takes two point clouds with matching points lined up and calculates displacement.
manICP.m	| really terrible and brute force way of finding close points between two clouds.
parsepicname.m	| parses out the name of the saved image file
parseVNRow.m	| parses out the vector nav row
parseLdrRow.m	| parses out the lidar row
rotation.m	| matlab function for generalized rotation matrix ypr
findoes.m	| finds the longest string of ones in a matrix and returns indicies (not actually used)

-------------------------
viewbridgesets
	Specialized cdoe from the testviewsets which I used for
creating the bridge for MDOT.  The bridge code that was used
for the MDOT presentation is view_bridge_v3.m

link to the google drive where the bridge data is stored,
https://drive.google.com/file/d/0B2Fx5zzCPnftSVdKNUJXQzBWNEk/edit?usp=sharing

File				| Description
--------------------------------|--------------
view_bridge_icp.m		| tried to run the bridge through my bad icp algorithm
view_bridge.m			| first rendition of viewing the bridge
view_bridge_v3_base.m		| succesful bridge viewer without any algorithms or changes 
view_bridge_v3_base_square.m	| tries to match the center of masses
view_bridge_v3_linear_interp.m	| linearly interps the path
view_bridge_v3.m		| does everything together, final output submitted to MDOT

-------------------------
