//Decompiled code. Please respect the original copyright.
void() SelectTeam;

void(float thisteam, string say1) sprint_team =
{
	local entity u;

	u = find(world, classname, "player");
	while ((u != world))
	{
		if (((u.vteam == thisteam) && MAX_TEAMS))
		{
			sprint(u, PRINT_HIGH, say1);
		}
		u = find(u, classname, "player");
	}
};

void(float thisteam) award_frags =
{
	local float k;
	local entity u;

	k = stof(infokey(world, "award"));
	u = find(world, classname, "player");
	while ((u != world))
	{
		if ((u.vteam == thisteam))
		{
			u.frags = (u.frags + k);
			logfrag(u, u.follow_item);
		}
		u = find(u, classname, "player");
	}
};

void(float thisteam, string say1) centerprint_team =
{
	local entity u;

	u = find(world, classname, "player");
	while ((u != world))
	{
		if ((u.vteam == thisteam))
		{
			centerprint3(u, say1, "\n\n", self.netname);
		}
		u = find(u, classname, "player");
	}
};

void(float thisteam, string say1) centerprint_noteam =
{
	local entity u;

	u = find(world, classname, "player");
	while ((u != world))
	{
		if (((u.vteam != thisteam) && (u.vteam != STATE_HOME)))
		{
			centerprint3(u, say1, "\n\n", self.netname);
		}
		u = find(u, classname, "player");
	}
};

void() NextMenu =
{
	self.aflag = (self.aflag - (self.aflag & FL_MOTD));
	SelectTeam();
};

void() ShowMOTD =
{
	self.count = MAP_TF;
	self.th_menu = NextMenu;
	self.aflag = ((self.aflag | FL_MOTD) | FL_MENU);
	if ((MAX_TEAMS != STATE_HOME))
	{
		stuffcmd(self, "color 0\nteam \"\"\n");
	}
};

string(float t) NameForClass =
{
	if ((t == CLASS_OBSERVER))
	{
		return ("observer");
	}
	if ((t == CLASS_ARCHER))
	{
		return ("archer");
	}
	if ((t == CLASS_ALCH))
	{
		return ("alchemist");
	}
	if ((t == CLASS_BARREL))
	{
		return ("barrel man");
	}
	if ((t == CLASS_THIEF))
	{
		return ("thief");
	}
	if ((t == CLASS_WIZARD))
	{
		return ("wizard");
	}
	if ((t == CLASS_KNIGHT))
	{
		return ("knight");
	}
	if ((t == CLASS_BSMITH))
	{
		return ("blacksmith");
	}
};

void() SetClass =
{
	local string h;

	if (((self.impulse > WEAPON_BIG) || !self.impulse))
	{
		return;
	}
	if ((self.impulse == WEAPON_BIG))
	{
		self.random_class = (random() * CLASS_BSMITH);
		self.random_class = floor(self.random_class);
		self.newclass = (self.random_class + WEAPON_SHOTGUN);
	}
	if (((self.impulse > STATE_HOME) && (self.impulse < WEAPON_BIG)))
	{
		self.newclass = self.impulse;
	}
	self.aflag = (self.aflag - FL_MENU);
	h = self.netname;
	sprint_team(self.vteam, h);
	sprint_team(self.vteam, " is playing as a ");
	h = NameForClass(self.newclass);
	sprint_team(self.vteam, h);
	sprint_team(self.vteam, ".\n");
	SetNewParms();
	PutClientInServer();
};

void() SelectClass =
{
	self.message = "\n Choose Your Class ‘\n\n\n1‘ Archer    \n2‘ Alchemist \n3‘ Barrel Man\n4‘ Knight    \n5‘ Thief     \n6‘ Wizard    \n7‘ Blacksmith\n8‘ Random    \n";
	self.th_menu = SetClass;
	self.aflag = (self.aflag | FL_MENU);
};

float(float thisteam) CountMembers =
{
	local entity u;
	local float counts;

	counts = STATE_HOME;
	u = find(world, classname, "player");
	while ((u != world))
	{
		if ((u.vteam == thisteam))
		{
			counts = (counts + WEAPON_SHOTGUN);
		}
		u = find(u, classname, "player");
	}
	if ((infokey(world, "stc") == "all"))
	{
		counts = (counts + WEAPON_SHOTGUN);
	}
	return (counts);
};

float() autoteam =
{
	local float low;
	local float best;
	local float chal;

	best = CountMembers(WEAPON_SHOTGUN);
	low = WEAPON_SHOTGUN;
	chal = CountMembers(WEAPON_ROCKET);
	if ((chal < best))
	{
		low = WEAPON_ROCKET;
		best = chal;
	}
	if ((MAX_TEAMS == WEAPON_ROCKET))
	{
		return (low);
	}
	chal = CountMembers(MAP_TF);
	if ((chal < best))
	{
		low = MAP_TF;
		best = chal;
	}
	if ((MAX_TEAMS == MAP_TF))
	{
		return (low);
	}
	chal = CountMembers(WEAPON_SPIKES);
	if ((chal < best))
	{
		low = WEAPON_SPIKES;
		best = chal;
	}
	return (low);
};

void(float which) ChangeTeam =
{
	if ((which == WEAPON_SHOTGUN))
	{
		stuffcmd(self, "color 13\nteam \"blue\"\n");
		self.vteam = WEAPON_SHOTGUN;
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " has joined the blue team.\n");
	}
	if ((which == WEAPON_ROCKET))
	{
		stuffcmd(self, "color 4\nteam \"red\"\n");
		self.vteam = WEAPON_ROCKET;
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " has joined the red team.\n");
	}
	if ((which == MAP_TF))
	{
		stuffcmd(self, "color 12\nteam \"yellow\"\n");
		self.vteam = MAP_TF;
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " has joined the yellow team.\n");
	}
	if ((which == WEAPON_SPIKES))
	{
		stuffcmd(self, "color 3\nteam \"green\"\n");
		self.vteam = WEAPON_SPIKES;
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " has joined the green team.\n");
	}
};

void() SetTeam =
{
	local float lowest;

	if ((self.impulse == WEAPON_SHOTGUN))
	{
		ChangeTeam(WEAPON_SHOTGUN);
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			ChangeTeam(WEAPON_ROCKET);
		}
		else
		{
			if (((self.impulse == MAP_TF) && (MAX_TEAMS > WEAPON_ROCKET)))
			{
				ChangeTeam(MAP_TF);
			}
			else
			{
				if (((self.impulse == WEAPON_SPIKES) && (MAX_TEAMS == WEAPON_SPIKES)))
				{
					ChangeTeam(WEAPON_SPIKES);
				}
				else
				{
					if ((self.impulse == CLASS_THIEF))
					{
						lowest = autoteam();
						ChangeTeam(lowest);
					}
				}
			}
		}
	}
	SelectClass();
};

void() SelectTeam =
{
	if ((MAX_TEAMS < WEAPON_ROCKET))
	{
		self.vteam = WEAPON_SHOTGUN;
		SelectClass();
		return;
	}
	if ((MAX_TEAMS == WEAPON_ROCKET))
	{
		self.message = "\n Choose Your Team ‘\n\n\n1‘ Blue Team  \n2‘ Red Team   \n\n\n\n5‘ Auto Team  \n";
	}
	if ((MAX_TEAMS == MAP_TF))
	{
		self.message = "\n Choose Your Team ‘\n\n\n1‘ Blue Team  \n2‘ Red Team   \n3‘ Yellow Team\n\n\n5‘ Auto Team  \n";
	}
	if ((MAX_TEAMS == WEAPON_SPIKES))
	{
		self.message = "\n Choose Your Team ‘\n\n\n1‘ Blue Team  \n2‘ Red Team   \n3‘ Yellow Team\n4‘ Green Team \n\n5‘ Auto Team  \n";
	}
	self.th_menu = SetTeam;
	self.aflag = (self.aflag | FL_MENU);
};
void() Abort_Build;

void() SetAbort =
{
	if ((self.impulse == WEAPON_SHOTGUN))
	{
		Abort_Build();
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			self.build_finished = (self.saved_time + time);
		}
	}
	self.saved_time = STATE_HOME;
	self.aflag = (self.aflag - FL_MENU);
};

void() AbortDialog =
{
	self.saved_time = (self.build_finished - time);
	self.build_finished = (time + 99999);
	self.message = "\n Abort building? ‘\n\n\n1‘ Yes  \n2‘ No   \n\n";
	self.th_menu = SetAbort;
	self.aflag = (self.aflag | FL_MENU);
};
void() DestroyIt;

void() SetDestroy =
{
	if ((self.impulse == WEAPON_SHOTGUN))
	{
		if ((self.destroy != world))
		{
			DestroyIt();
			return;
		}
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			self.destroy = world;
		}
	}
	self.aflag = (self.aflag - FL_MENU);
	self.aflag = (self.aflag - FL_DIALOG);
};

void(string object) DestroyDialog =
{
	self.message = "";
	self.msg1 = "\n Destroy ";
	self.msg2 = object;
	self.msg3 = " ? ‘\n\n\n1‘ Yes  \n2‘ No   \n\n";
	self.th_menu = SetDestroy;
	self.aflag = (self.aflag | FL_MENU);
	self.aflag = (self.aflag | FL_DIALOG);
};
