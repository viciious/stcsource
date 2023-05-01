//Decompiled code. Please respect the original copyright.

void() item_tfgoal =
{
	self.spawnflags = STATE_HOME;
	if (self.team_no == 1)
		item_flag_team1();
	else if (self.team_no == 2)
		item_flag_team2();
	else if (self.team_no == 3)
		item_flag_team3();
	else if (self.team_no == 4)
		item_flag_team4();
	else
		remove(self);
};

void() info_tfgoal =
{
	remove(self);
};

void() info_player_teamspawn =
{
	if (self.team_no == 1)
		self.classname = "info_player_team2";
	else if (self.team_no == 2)
		self.classname = "info_player_team1";
	else if (self.team_no == 3)
		self.classname = "info_player_team3";
	else if (self.team_no == 4)
		self.classname = "info_player_team4";
};

void() i_p_t =
{
	if (self.team_no == 1)
		self.classname = "info_player_team2";
	else if (self.team_no == 2)
		self.classname = "info_player_team1";
	else if (self.team_no == 3)
		self.classname = "info_player_team3";
	else if (self.team_no == 4)
		self.classname = "info_player_team4";
};

void() info_tfdetect =
{
	MAPTYPE = MAP_TF;
	remove(self);
};
