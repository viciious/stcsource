//Decompiled code. Please respect the original copyright.
void() player_run;
void() player_arrow1;
void() player_ssword1;
void() player_torch1;
void() player_bomb1;
void() player_hook1;
void() Wizard_Teleporter;
void() SetSpeed;
void(float add) SetOnFire;
void() FireThink;
void (entity client, string s, ...) centerprint3 = #73; 
void (entity client, string s, ...) centerprint5 = #73; 
.float average;
.float cheating;
.float next_check;
.float team_no;
vector obj_org;
vector obj_mins;
vector obj_maxs;

string extra;
float vt_votes;
string votemap;

void(string gibname, float dm) ThrowGib;
void(vector org, entity death_owner) spawn_tdeath;
void(vector org) spawn_tfog;
void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;
void(vector org, vector dir) launch_spike;

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

float() crandom;

vector(float dm) VelocityForDamage;

string(float t) NameForTeam =
{
	if ((t == WEAPON_SHOTGUN))
	{
		return ("blue");
	}
	if ((t == WEAPON_ROCKET))
	{
		return ("red");
	}
	if ((t == MAP_TF))
	{
		return ("yellow");
	}
	if ((t == WEAPON_SPIKES))
	{
		return ("green");
	}
};

void() CheckCheat =
{
	local string h;
	local float ork;
	local float l;

	if ((infokey(world, "cheat") == "1"))
	{
		return;
	}
	if ((self.class == CLASS_OBSERVER))
	{
		return;
	}
	if ((time < self.next_check))
	{
		return;
	}
	if (MAX_TEAMS)
	{
		ork = STATE_HOME;
		if ((self.vteam == WEAPON_SHOTGUN))
		{
			ork = TE_LIGHTNINGBLOOD;
		}
		else
		{
			if ((self.vteam == WEAPON_ROCKET))
			{
				ork = WEAPON_SPIKES;
			}
			else
			{
				if ((self.vteam == MAP_TF))
				{
					ork = TE_BLOOD;
				}
				else
				{
					if ((self.vteam == WEAPON_SPIKES))
					{
						ork = MAP_TF;
					}
				}
			}
		}
		l = stof(infokey(self, "bottomcolor"));
		if (((l != ork) && (ork != STATE_HOME)))
		{
			self.cheating = (self.cheating + 100);
			stuffcmd(self, "color ");
			h = ftos(ork);
			stuffcmd(self, h);
			stuffcmd(self, "\n");
			stuffcmd(self, "team ");
			h = NameForTeam(self.vteam);
			stuffcmd(self, h);
			stuffcmd(self, "\n");
		}
	}
	if ((infokey(self, "skin") != self.pl_skin))
	{
		stuffcmd(self, "skin ");
		stuffcmd(self, self.pl_skin);
		stuffcmd(self, "\n");
		self.cheating = (self.cheating + 100);
	}
	if ((self.cheating > 200))
	{
		bprint(PRINT_HIGH, self.netname);
		bprint(PRINT_HIGH, " was kicked for cheating.\n");
		stuffcmd(self, "echo \"You were kicked for cheating\"\ndisconnect\n");
	}
	self.next_check = (time + WEAPON_SHOTGUN);
};

void() Observer_SetSpawn =
{
	self.max_shells = STATE_HOME;
	self.max_nails = STATE_HOME;
	self.max_rockets = STATE_HOME;
	self.max_cells = STATE_HOME;
	self.items = STATE_HOME;
	self.armorvalue = STATE_HOME;
	self.armortype = STATE_HOME;
	self.max_type = STATE_HOME;
	self.max_value = STATE_HOME;
	self.max_bit = STATE_HOME;
	self.max_strafe = STATE_HOME;
	self.max_speed = STATE_HOME;
	self.pl_skin = "base";
};

void() SetSpeed =
{
	local string h;

	self.maxspeed = self.max_speed;
	h = ftos(self.maxspeed);
	stuffcmd(self, "cl_forwardspeed ");
	stuffcmd(self, h);
	stuffcmd(self, "\n");
	stuffcmd(self, "cl_backspeed ");
	stuffcmd(self, h);
	stuffcmd(self, "\n");
};

void() StopSpeed =
{
	self.maxspeed = STATE_HOME;
};

void() StuffAliases =
{
	stuffcmd(self, "alias archer \"impulse 90\"\n");
	stuffcmd(self, "alias knight \"impulse 91\"\n");
	stuffcmd(self, "alias barrel \"impulse 92\"\n");
	stuffcmd(self, "alias alch \"impulse 93\"\n");
	stuffcmd(self, "alias alchemist \"impulse 93\"\n");
	stuffcmd(self, "alias thief \"impulse 94\"\n");
	stuffcmd(self, "alias wizard \"impulse 96\"\n");
	stuffcmd(self, "alias blacksmith \"impulse 95\"\n");
	stuffcmd(self, "alias bsmith \"impulse 95\"\n");
	stuffcmd(self, "alias random \"impulse 97\"\n");
	stuffcmd(self, "alias yes \"impulse 29\"\n");
	stuffcmd(self, "alias vote \"impulse 28\"\n");
	stuffcmd(self, "alias id \"impulse 254\"\n");
	stuffcmd(self, "alias saveme \"impulse 253\"\n");
	stuffcmd(self, "alias destroy \"impulse 13\"\n");
};

void() CheckPoison =
{
	local float damage;

	if ((self.class == CLASS_ALCH))
	{
		return;
	}
	if ((self.poison_time > time))
	{
		return;
	}
	damage = (self.poison * 0.14);
	if (!(self.velocity_x || self.velocity_y))
	{
		self.poison = (self.poison - WEAPON_ROCKET);
	}
	self.deathtype = "poison2";
	T_Damage(self, self.enemy, self.enemy, damage, DAMAGE_IGNOREARMOR);
	SpawnBlood(self.origin, damage);
	self.poison = (self.poison - WEAPON_SHOTGUN);
	self.poison_time = (time + WEAPON_SHOTGUN);
};

float(entity builder) CheckArea =
{
	local vector src;
	local vector end;
	local float pos;

	if (!(builder.flags & FL_ONGROUND))
	{
		return (FALSE);
	}
	pos = pointcontents(obj_org);
	if (((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)))
	{
		return (FALSE);
	}
	src_x = ((obj_org_x + obj_maxs_x) + FL_VOTED);
	src_y = ((obj_org_y + obj_maxs_y) + FL_VOTED);
	src_z = ((obj_org_z + obj_maxs_z) + FL_VOTED);
	pos = pointcontents(src);
	if (((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)))
	{
		return (FALSE);
	}
	end_x = ((obj_org_x + obj_mins_x) - FL_VOTED);
	end_y = ((obj_org_y + obj_mins_y) - FL_VOTED);
	end_z = ((obj_org_z + obj_mins_z) - FL_VOTED);
	traceline(src, end, TRUE, builder);
	if ((trace_fraction != WEAPON_SHOTGUN))
	{
		return (FALSE);
	}
	pos = pointcontents(end);
	if (((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)))
	{
		return (FALSE);
	}
	src_x = ((obj_org_x + obj_mins_x) - FL_VOTED);
	src_y = ((obj_org_y + obj_maxs_y) + FL_VOTED);
	src_z = ((obj_org_z + obj_maxs_z) + FL_VOTED);
	pos = pointcontents(src);
	if (((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)))
	{
		return (FALSE);
	}
	end_x = ((obj_org_x + obj_maxs_x) + FL_VOTED);
	end_y = ((obj_org_y + obj_mins_y) - FL_VOTED);
	end_z = ((obj_org_z + obj_mins_z) - FL_VOTED);
	traceline(src, end, TRUE, builder);
	if ((trace_fraction != WEAPON_SHOTGUN))
	{
		return (FALSE);
	}
	pos = pointcontents(end);
	if (((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)))
	{
		return (FALSE);
	}
	traceline(builder.origin, obj_org, TRUE, builder);
	if ((trace_fraction != WEAPON_SHOTGUN))
	{
		return (FALSE);
	}
	return (TRUE);
};

float(entity targ) infront =
{
	local vector vec;
	local float dot;

	makevectors(self.angles);
	vec = normalize((targ.origin - self.origin));
	dot = (vec * v_forward);
	if ((dot > 0.3))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(string type) CountDaughters =
{
	local float y;
	local entity t;

	y = STATE_HOME;
	t = find(world, item_class, "daughter");
	while ((t != world))
	{
		if ((t.r_owner == self))
		{
			if ((type != string_null))
			{
				if ((t.classname == type))
				{
					y = (y + WEAPON_SHOTGUN);
				}
			}
			else
			{
				y = (y + WEAPON_SHOTGUN);
			}
		}
		t = find(t, item_class, "daughter");
	}
	return (y);
};

float() team_touch =
{
	if ((teamplay == STATE_HOME))
	{
		return (FALSE);
	}
	if (((self.team > STATE_HOME) && (self.team != other.vteam)))
	{
		return (TRUE);
	}
	if (((self.team < STATE_HOME) && ((STATE_HOME - self.team) == other.vteam)))
	{
		return (TRUE);
	}
	if (((self.team_no != STATE_HOME) && (self.team_no != other.vteam)))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity ent, float add) T_Armor =
{
	local float r;
	local float max;

	if ((ent.items & IT_ARMOR1))
	{
		if ((ent.class == CLASS_KNIGHT))
		{
			max = 150;
		}
		else
		{
			max = 100;
		}
	}
	if ((ent.items & IT_ARMOR2))
	{
		if ((ent.class == CLASS_KNIGHT))
		{
			max = 250;
		}
		else
		{
			max = 150;
		}
	}
	if ((ent.items & IT_ARMOR3))
	{
		if ((ent.class == CLASS_KNIGHT))
		{
			max = 400;
		}
		else
		{
			max = 200;
		}
	}
	if ((max > ent.max_value))
	{
		max = ent.max_value;
	}
	r = (max - ent.armorvalue);
	if ((r < STATE_HOME))
	{
		r = STATE_HOME;
	}
	if ((add > r))
	{
		add = r;
	}
	ent.armorvalue = (ent.armorvalue + add);
	return (add);
};

void() FizzleOut =
{
	sound(self, CHAN_AUTO, "barrel/out.wav", WEAPON_SHOTGUN, ATTN_NORM);
	self.enemy.heat = STATE_HOME;
	self.enemy.aflag = (self.enemy.aflag - (self.enemy.aflag & FL_ONFIRE));
	remove(self);
};

void() FireThink =
{
	local entity t;
	local entity oself;
	local entity otemp;

	if ((self.enemy.heat < WEAPON_SHOTGUN))
	{
		FizzleOut();
	}
	if ((pointcontents(self.origin) != CONTENT_EMPTY))
	{
		FizzleOut();
	}
	setorigin(self, self.enemy.origin);
	self.velocity = self.enemy.velocity;
	self.enemy.heat = (self.enemy.heat - WEAPON_SHOTGUN);
	self.enemy.deathtype = "hellfire";
	if (self.enemy.takedamage)
	{
		T_Damage(self.enemy, self, self.owner, (self.enemy.heat * 0.25), STATE_HOME);
	}
	t = findradius(self.origin, 50);
	while ((t != world))
	{
		if (((t != self.enemy) && (t.classname == "player")))
		{
			oself = self;
			otemp = other;
			self = self.owner;
			other = t;
			SetOnFire((oself.enemy.heat * 0.5));
			self = oself;
			other = otemp;
		}
		t = t.chain;
	}
	self.nextthink = (time + 0.7);
};

void(float add) SetOnFire =
{
	local entity up;

	if ((other.class == CLASS_KNIGHT))
	{
		add = (add * 0.5);
	}
	if (((other.class == CLASS_BARREL) && (other.weapon == IT_AXE)))
	{
		add = (add * 0.2);
	}
	if ((other.heat > STATE_HOME))
	{
		other.heat = (other.heat + add);
		return;
	}
	sound(other, CHAN_AUTO, "barrel/catch.wav", WEAPON_SHOTGUN, ATTN_NORM);
	other.aflag = (other.aflag | FL_ONFIRE);
	up = spawn();
	setmodel(up, "progs/fire.mdl");
	setorigin(up, other.origin);
	up.enemy = other;
	up.owner = self;
	up.movetype = MOVETYPE_NOCLIP;
	up.solid = SOLID_NOT;
	setsize(up, VEC_ORIGIN, VEC_ORIGIN);
	up.think = FireThink;
	up.nextthink = (time + 0.7);
	up.classname = "fire";
	up.effects = EF_DIMLIGHT;
	other.heat = (other.heat + add);
};

float() Num_Players =
{
	local entity t;
	local float h;

	h = STATE_HOME;
	t = find(world, classname, "player");
	while ((t != world))
	{
		if (!t.deadflag)
		{
			h = (h + WEAPON_SHOTGUN);
		}
		t = find(t, classname, "player");
	}
	return (h);
};

void() Destroy_Daughters =
{
	local entity y;
	local entity oself;

	y = find(world, item_class, "daughter");
	while ((y != world))
	{
		if ((y.r_owner == self))
		{
			oself = self;
			self = y;
			self.th_die();
			self = oself;
		}
		y = find(y, item_class, "daughter");
	}
};

void() Climb =
{
	local vector source;
	local vector org;

	if (((self.class == CLASS_OBSERVER) || (self.health < WEAPON_SHOTGUN)))
	{
		return;
	}
	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * 54)), FALSE, self);
	if ((trace_fraction == WEAPON_SHOTGUN))
	{
		return;
	}
	org = (trace_endpos - (v_forward * WEAPON_SPIKES));
	if (((trace_ent.solid == SOLID_BSP) && (self.class == CLASS_THIEF)))
	{
		self.velocity_z = 160;
		self.velocity_z = 160;
	}
	if ((trace_ent.classname == "tree"))
	{
		self.velocity_z = 160;
		self.velocity_z = 160;
	}
};
