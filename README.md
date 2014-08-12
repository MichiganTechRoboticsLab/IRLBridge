IRLBridge and Sensor Fusion Post Process
--

This is a link to download the data if you so choose
https://drive.google.com/file/d/0B2Fx5zzCPnftSVdKNUJXQzBWNEk/edit?usp=sharing

This is the directory I used for the MDOT code, there is some extra code in
here that could also be used for viewing the fusion code from a more general
scale.

-------------------------
testviewsets
	The codesets in this folder allow you to view the post-processed datasets

File			| Description
------------------------|--------------
testview.m		| Content Cell
testview2_1.m		| Content Cell
testview2.m		| Content Cell
testviewv3_base.m	| Content Cell

-------------------------
utils
	various utilities I use for the viewbridge sets and the testviewsets

File		| Description
----------------|--------------
find_diff.m	| Content Cell
manICP.m	| Content Cell
parsepicname.m	| Content Cell
parseVNRow.m	| Content Cell
parseLdrRow.m	| Content Cell
rotation.m	| Content Cell
findoes.m	| Content Cell

-------------------------
viewbridgesets
	Specialized cdoe from the testviewsets which I used for
creating the bridge for MDOT.  The bridge code that was used
for the MDOT presentation is view_bridge_v3.m

File				| Description
--------------------------------|--------------
view_bridge_icp.m		| Content Cell
view_bridge.m			| Content Cell
view_bridge_v3_base.m		| Content Cell
view_bridge_v3_base_square.m	| Content Cell
view_bridge_v3_linear_interp.m	| Content Cell
view_bridge_v3.m		| Content Cell

-------------------------



