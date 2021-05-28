/*

*/


-- Please DO NOT re-upload this addon you can edit the config settings here


PEX = PEX or {};
PEX.Settings = {};

// Stungun
PEX.Settings.taserDistance = 450;
PEX.Settings.knockoutTime = 3;
PEX.Settings.freezeTime = 4;



PEX.Settings.repTotazer = {


};



--PEX.Settings.beanKnockoutTime = 5;
--PEX.Settings.beanFreezeTime = 2;




 



if( SERVER ) then
	

	local materials = {

	};
	for i, v in pairs( materials ) do
		resource.AddFile( "materials/pex/" .. v .. ".png" );
	end


else
	for i, v in pairs( PEX.Settings.repTotazer ) do
		PEX.Settings.repTotazer[ i ] = Material( "pex/crosshair.png" );
	end




	

	PEX.Settings.Taser = {
		x = ScrW() / 2,
		y = ScrH() / 2 + 120,
		boxMargin = 5,
		boxW = 30,
		boxH = 15,
		boxBg = Color( 0, 0, 0, 90 ),
		boxBorder = Color( 0, 0, 0 ),
		boxPaint = Color( 0, 168, 0, 125 ),
		validTarget = Color( 0, 168, 0, 255 ),
		invalidTarget = Color( 255, 255, 255, 40 ),
		iconSize = 64,
		mat = Material( "pex/crosshair.png" ),
	};


end