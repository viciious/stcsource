//Decompiled code. Please respect the original copyright.
void() flag_touch;

void() flaghome =
{
	local string h;

	setorigin(self, self.dest);
	self.movetype = MOVETYPE_TOSS;
	self.model = self.mdl;
	self.solid = SOLID_TRIGGER;
	self.velocity = VEC_ORIGIN;
	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	spawn_tfog(self.origin);
	self.touch = flag_touch;

	if (self.state == STATE_AWAY)
	{
		centerprint_team(self.vteam, "Your flag has returned\nto base");
		centerprint_noteam(self.vteam, "The enemy flag has returned\nto base");
		bprint(PRINT_HIGH, "The ");
		h = NameForTeam(self.vteam);
		bprint(PRINT_HIGH, h);
		bprint(PRINT_HIGH, " flag has returned to base.\n");
	}
	self.state = STATE_HOME;
};

void() Drop_Flag =
{
	local entity oself;
	local string h;

	if (self.follow_item == world)
		return;

	oself = self;
	self = self.follow_item;
	self.touch = flag_touch;
	setorigin(self, self.origin);
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.think = flaghome;
	self.nextthink = (time + 20);
	self.velocity_z = (self.velocity_z + 60);
	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	self.state = STATE_AWAY;
	self = oself;
	self.follow_item = world;
	centerprint_team(oself.vteam, "The enemy dropped your flag!");
	centerprint_team(self.vteam, "Your team dropped the enemy's flag!");

	h = self.netname;
	if (h != string_null)
	{
		bprint(PRINT_HIGH, h);
		bprint(PRINT_HIGH, " has dropped the ");
		h = NameForTeam(oself.vteam);
		bprint(PRINT_HIGH, h);
		bprint(PRINT_HIGH, " flag!\n");
	}
	return;
};

void() follow_enemy =
{
	local entity oself;

	if (self.enemy != world)
	{
		if (self.enemy.health <= STATE_HOME)
		{
			oself = self;
			self = self.enemy;
			Drop_Flag();
			self = oself;
			return;
		}
		self.nextthink = time + 0.1;
	}
};

void() flag_touch =
{
	local entity oself;
	local string h;

	if (other.classname != "player")
		return;
	if (other.health <= STATE_HOME)
		return;
	if (other.vteam == self.vteam)
		return;
	if (other.follow_item != world)
		return;

	self.state = STATE_CARRIED;
	oself = self;
	self = other;
	self.follow_item = oself;
	centerprint_team(oself.vteam, "Your flag has been taken!");
	centerprint_team(self.vteam, "Your team has the enemy flag!");
	sound(other, CHAN_AUTO, "shambler/ssight.wav", WEAPON_SHOTGUN, ATTN_NORM);
	h = self.netname;
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " of the ");
	h = NameForTeam(self.vteam);
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " team has taken the ");
	h = NameForTeam(oself.vteam);
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " flag!\n");
	self = oself;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.touch = SUB_Null;
	self.enemy = other;
	self.think = follow_enemy;
	self.nextthink = (time + 0.2);
};

void() flag_trigger_touch =
{
	local entity oself;
	local string h;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.vteam != self.vteam)
		return;
	if (other.follow_item == world)
		return;
	if ((MAPTYPE == MAP_CTF) && (self.owner.state != 0))
		return;

	sound(other, CHAN_AUTO, "misc/fanfare.wav", 1, ATTN_NORM);
	centerprint_team(other.vteam, "Your team captured the enemy flag!");
	centerprint_team(other.follow_item.vteam, "Your flag was captured!");

	award_frags(other.vteam);

	h = other.netname;
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " of the ");
	h = NameForTeam(other.vteam);
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " team has captured the ");
	h = NameForTeam(other.follow_item.vteam);
	bprint(PRINT_HIGH, h);
	bprint(PRINT_HIGH, " flag!\n");

	self.count = self.count + 1;
	other.follow_item.think = flaghome;
	other.follow_item.nextthink = (time + 0.1);
	other.follow_item.solid = SOLID_NOT;
	other.follow_item.mdl = other.follow_item.model;
	other.follow_item.model = string_null;
	other.follow_item.touch = SUB_Null;
	other.follow_item.movetype = MOVETYPE_TOSS;
	other.follow_item = world;
};

void() ShowScores =
{
	local entity t;
	local string hold;

	bprint(PRINT_HIGH, "-----------\nScores:\n");
	self.refresh_cent = time + (4 * 60);

	t = find(world, classname, "tr34ghm2");
	while (t != world)
	{
		hold = NameForTeam(t.vteam);
		bprint(PRINT_HIGH, hold);
		bprint(PRINT_HIGH, " Team:");
		hold = ftos(t.count);
		bprint(PRINT_HIGH, hold);
		bprint(PRINT_HIGH, "\n");
		t = find(t, classname, "tr34ghm2");
	}
	bprint(PRINT_HIGH, "-----------\n");
};

void() FreeFlag =
{
	local entity oself;

	oself = self;
	self = self.owner;
	self.mdl = self.model;
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	if ((self.state == STATE_CARRIED))
	{
		self.enemy.follow_item = world;
		self.enemy = world;
	}
	self.movetype = MOVETYPE_TOSS;
	setorigin(self, self.dest);
	self.state = STATE_HOME;
	self = oself;
};

void() field_think =
{
	local float y;
	local entity oself;

	if ((self.vteam == 1) && (self.refresh_cent < time))
		ShowScores();

	y = CountMembers(self.vteam);
	if (y != 0)
		y = 1;

	if ((y == 0) && (self.poison == 1))
	{
		SUB_UseTargets();
		self.poison = 1;
		FreeFlag();
		self.count = STATE_HOME;
	}
	if ((y == 1) && (self.poison == 1))
	{
		SUB_UseTargets();
		oself = self;
		self = self.owner;
		flaghome();
		self = oself;
		self.poison = STATE_HOME;
	}
	self.nextthink = time + 1;
};

entity(vector fmins, vector fmaxs) spawn_flag_field =
{
	local entity trigger;
	local vector t1;
	local vector t2;

	trigger = spawn();
	trigger.classname = "tr34ghm2";
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.flags = FL_ITEM;
	trigger.touch = flag_trigger_touch;
	trigger.vteam = self.vteam;
	trigger.target = self.target;
	trigger.think = field_think;
	trigger.nextthink = (time + 20);
	setorigin(trigger, self.origin);
	t1 = fmins;
	t2 = fmaxs;
	setsize(trigger, (t1 - '8 8 60'), (t2 + '8 8 60'));
	return (trigger);
};

void(float jj) flag_start =
{
	self.touch = flag_touch;
	precache_model("progs/flag.mdl");
	precache_sound("misc/fanfare.wav");
	precache_sound("shambler/ssight.wav");
	setmodel(self, "progs/flag.mdl");
	self.mdl = self.model;
	self.classname = "flag";
	self.skin = jj;
	self.vteam = jj;
	if (self.vteam > MAX_TEAMS)
		MAX_TEAMS = self.vteam;

	setsize(self, '-16 -16 0', '16 16 56');
	StartItem();
	self.dest = self.origin;
	self.state = STATE_HOME;
	MAPTYPE = MAP_STC;
	if (self.spawnflags & 1)
		return;

	MAPTYPE = MAP_CTF;
	self.r_owner = spawn_flag_field(self.maxs, self.mins);
};

void() item_flag_team1 =
{
	self.classname = "item_flag_team1";
	self.effects = (EF_FLAG1 | EF_RED);
	self.netname = "Red Flag";
	flag_start(2);
};

void() item_flag_team2 =
{
	self.classname = "item_flag_team2";
	self.effects = (EF_FLAG2 | EF_BLUE);
	self.netname = "Blue Flag";
	flag_start(1);
};

void() item_flag_team3 =
{
	self.classname = "item_flag_team3";
	self.effects = EF_YELLOW;
	self.netname = "Yellow Flag";
	flag_start(3);
};

void() item_flag_team4 =
{
	self.classname = "item_flag_team4";
	self.effects = EF_GREEN;
	self.netname = "Green Flag";
	flag_start(4);
};

void() info_player_team1 =
{
};

void() info_player_team2 =
{
};

void() info_player_team3 =
{
};

void() info_player_team4 =
{
};
