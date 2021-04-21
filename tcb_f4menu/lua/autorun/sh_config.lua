/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/
print("AAAAAAAAAAAAAAAAA")
-- Variables
TCB_Settings = {}

-- Settings
TCB_Settings.ActivationKey1 = "ShowSpare2"		// F1 (ShowHelp), 	F2 (ShowTeam), 	F3 (ShowSpare1), 	F4 (ShowSpare2)
TCB_Settings.ActivationKey2	= KEY_F4			// F1 (KEY_F1), 	F2 (KEY_F2), 	F3 (KEY_F3), 		F4 (KEY_F4)

TCB_Settings.CheckVersion	= true

TCB_Settings.HideWrongJob	= true

TCB_Settings.TitleOne		= "Server Name"
TCB_Settings.TitleTwo		= "Subtitle Here!"

TCB_Settings.PrimaryColor	= Color( 52, 152, 219, 255 )
TCB_Settings.SecondaryColor	= Color( 41, 128, 185, 255 )

-- Custom Web Panels (If Enabled Below)
TCB_Settings.WebPanel_1		= "http://www.thecodingbeast.com"
TCB_Settings.WebPanel_2		= "http://www.thecodingbeast.com"
TCB_Settings.WebPanel_3		= "http://www.thecodingbeast.com"
TCB_Settings.WebPanel_4		= "http://www.thecodingbeast.com" 

-- Buttons
TCB_Settings.SidebarButtons = {
	
	{ text = "Commands", 	panel = "tcb_panel_commands", 	info = true, 	func = 6			},

	{ text = "Divider",		panel = "",						info = false,	func = 0 			},

	{ text = "Forum",		panel = "tcb_panel_custom1",	info = false,	func = 0 			},
	{ text = "Rules",		panel = "tcb_panel_custom2",	info = false,	func = 0 			},
	{ text = "Shop",		panel = "tcb_panel_custom3",	info = false,	func = 0 			},
	{ text = "Staff",		panel = "tcb_panel_custom4",	info = false,	func = 0 			},

	{ text = "Divider",		panel = "",						info = false,	func = 0 			},

	{ text = "Jobs", 		panel = "tcb_panel_jobs",		info = true,	func = "jobs"  		},
	{ text = "Entities",	panel = "tcb_panel_entities",	info = true,	func = "entities"	},
	{ text = "Weapons",		panel = "tcb_panel_guns",		info = true,	func = "weapons"	},
	{ text = "Shipments",	panel = "tcb_panel_shipments",	info = true,	func = "shipments" 	},
	{ text = "Ammo",		panel = "tcb_panel_ammo",		info = true,	func = "ammo" 		},
	{ text = "Vehicles",	panel = "tcb_panel_vehicles",	info = true,	func = "vehicles"	},

}

-- Version (Don't Change)
TCB_Settings.Version 		= "1.8"