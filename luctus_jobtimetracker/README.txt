# luctus_jobtimetracker

This is an extended version of my "sv_luctus_jobtimetracker.lua" script from my scprp-addons repo.  
It features user and serverwide tracking of job playtime and switches.  
It also features a clientside UI ingame to view your own (player) or the serverwide job playtimes.

If you used the standalone script beforehand please make sure you delete the database table before switching to this one.  
To do this execute the following serverside console command (WARNING: This will delete the jobtimes you have until now)

	lua_run sql.Query("DROP TABLE luctus_jobtimetracker")

This has to be done because this addon uses the same database name but a different table schema.
