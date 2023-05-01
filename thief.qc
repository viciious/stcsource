//Decompiled code. Please respect the original copyright.

void() ThiefPrecache =
{
	precache_model("progs/hook.mdl");
	precache_model("progs/bit.mdl");
	precache_model("progs/v_hook.mdl");
	precache_sound("shambler/smack.wav");
	precache_sound("blob/land1.wav");
	precache_model("progs/v_knife.mdl");
	precache_model("progs/v_clept.mdl");
	precache_model("progs/stash.mdl");
};

void() Thief_SetSpawn =
{
	self.max_shells = 800;
	self.max_nails = 800;
	self.max_rockets = 800;
	self.max_cells = 800;
	self.items = (((IT_AXE | IT_SHOTGUN) | IT_SUPER_SHOTGUN) | IT_ARMOR1);
	self.armorvalue = 50;
	self.armortype = 0.3;
	self.max_type = 0.3;
	self.max_value = 50;
	self.max_bit = IT_ARMOR1;
	self.max_strafe = 430;
	self.max_speed = 430;
	stuffcmd(self, "exec cfg/thief.cfg\n");
	self.pl_skin = "stc_thif";
	stuffcmd(self, "alias +hook \"impulse 198\"\n");
	stuffcmd(self, "alias -hook \"impulse 199\"\n");
};

void(entity who) GiveAmmo =
{
	local float h;
	local float flag;
	local entity oself;
	local string strin;

	if ((who.ammo_shells < who.max_shells))
	{
		h = (who.max_shells - who.ammo_shells);
		if ((h > self.ammo_shells))
		{
			h = self.ammo_shells;
		}
		who.ammo_shells = (who.ammo_shells + h);
		self.ammo_shells = (self.ammo_shells - h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if ((who.ammo_nails < who.max_nails))
	{
		h = (who.max_nails - who.ammo_nails);
		if ((h > self.ammo_nails))
		{
			h = self.ammo_nails;
		}
		who.ammo_nails = (who.ammo_nails + h);
		self.ammo_nails = (self.ammo_nails - h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if ((who.ammo_rockets < who.max_rockets))
	{
		h = (who.max_shells - who.ammo_rockets);
		if ((h > self.ammo_rockets))
		{
			h = self.ammo_rockets;
		}
		who.ammo_rockets = (who.ammo_rockets + h);
		self.ammo_rockets = (self.ammo_rockets - h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if ((who.ammo_cells < who.max_cells))
	{
		h = (who.max_cells - who.ammo_cells);
		if ((h > self.ammo_cells))
		{
			h = self.ammo_cells;
		}
		who.ammo_cells = (who.ammo_cells + h);
		self.ammo_cells = (self.ammo_cells - h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if ((flag == WEAPON_SHOTGUN))
	{
		sound(self, CHAN_AUTO, "weapons/lock4.wav", WEAPON_SHOTGUN, ATTN_NORM);
		stuffcmd(self, "bf\n");
		if ((who.classname == "player"))
		{
			centerprint3(who, "You recieved ammo from\n", self.netname, ".");
			centerprint3(self, "You gave\n", who.netname, "\n some ammo");
			stuffcmd(who, "bf\n");
			oself = self;
			self = who;
			W_SetCurrentAmmo();
			self = oself;
		}
		else
		{
			if ((who.classname == "ballista"))
			{
				oself = who.r_owner;
				strin = ftos(who.ammo_shells);
				centerprint3(self, oself.netname, "'s ballista\nAmmo:", strin);
			}
		}
	}
};

void() Thief_FireKnife =
{
	local vector source;
	local vector org;
	local float damg;
	local entity oself;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * FL_DIALOG)), FALSE, self);
	if ((trace_fraction == WEAPON_SHOTGUN))
	{
		return;
	}
	org = (trace_endpos - (v_forward * WEAPON_SPIKES));
	oself = self;
	self = trace_ent;
	if (!infront(oself))
	{
		damg = 80;
	}
	else
	{
		damg = SVC_INTERMISSION;
	}
	self = oself;
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = WEAPON_SHOTGUN;
		SpawnBlood(org, 20);
		T_Damage(trace_ent, self, self, damg, STATE_HOME);
	}
	else
	{
		sound(self, CHAN_WEAPON, "player/axhit2.wav", WEAPON_SHOTGUN, ATTN_NORM);
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, MAP_TF);
		WriteCoord(MSG_MULTICAST, org_x);
		WriteCoord(MSG_MULTICAST, org_y);
		WriteCoord(MSG_MULTICAST, org_z);
		multicast(org, MULTICAST_PVS);
	}
};
void() player_steal1;

void() StealAmmo =
{
	local vector source;
	local vector org;
	local entity who;
	local float h;
	local float flag;
	local entity oself;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * FL_DIALOG)), FALSE, self);
	if ((trace_fraction == WEAPON_SHOTGUN))
	{
		return;
	}
	who = trace_ent;
	if ((self.class == CLASS_BSMITH))
	{
		if ((trace_ent.classname == "ballista"))
		{
			GiveAmmo(trace_ent);
		}
		return;
	}
	if (((trace_ent.classname == "barrel") && ((who.vteam != self.vteam) && MAX_TEAMS)))
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, SVC_INTERMISSION);
		WriteCoord(MSG_MULTICAST, who.origin_x);
		WriteCoord(MSG_MULTICAST, who.origin_y);
		WriteCoord(MSG_MULTICAST, who.origin_z);
		multicast(self.origin, MULTICAST_PVS);
		oself = who.r_owner;
		centerprint3(self, "You disarmed\n", oself.netname, "'s barrel");
		centerprint3(oself, "Your barrel was dissarmed\nby ", who.netname, ".");
		remove(who);
	}
	if (((trace_ent.classname == "ballista") && ((who.vteam != self.vteam) && MAX_TEAMS)))
	{
		WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte(MSG_MULTICAST, TE_GUNSHOT);
		WriteByte(MSG_MULTICAST, SVC_INTERMISSION);
		WriteCoord(MSG_MULTICAST, who.origin_x);
		WriteCoord(MSG_MULTICAST, who.origin_y);
		WriteCoord(MSG_MULTICAST, who.origin_z);
		multicast(self.origin, MULTICAST_PVS);
		oself = who.r_owner;
		self.ammo_shells = trace_ent.ammo_shells;
		trace_ent.ammo_shells = STATE_HOME;
		centerprint3(self, "You stole the ammo from\n", oself.netname, "'s Ballista");
		centerprint3(oself, "Your Ballista's ammo was stolen\nby ", who.netname, "");
		if ((trace_ent.ammo_shells < STATE_HOME))
		{
			trace_ent.ammo_shells = STATE_HOME;
		}
		if ((self.ammo_shells > self.max_shells))
		{
			self.ammo_shells = self.max_shells;
		}
	}
	if (((trace_ent.classname == "ballista") && (((who.vteam == self.vteam) && MAX_TEAMS) || (trace_ent.r_owner == self))))
	{
		GiveAmmo(trace_ent);
		return;
	}
	if (((trace_ent.classname == "door") && trace_ent.team))
	{
		activator = self;
		other = self;
		oself = self;
		self = who;
		self.use();
		self = oself;
	}
	if ((trace_ent.classname != "player"))
	{
		return;
	}
	if (((self.vteam == who.vteam) && MAX_TEAMS))
	{
		GiveAmmo(who);
		return;
	}
	if (((who.ammo_shells > STATE_HOME) && (who.items & IT_SHELLS)))
	{
		h = (self.max_shells - self.ammo_shells);
		if ((h > who.ammo_shells))
		{
			h = who.ammo_shells;
		}
		who.ammo_shells = (who.ammo_shells - h);
		self.ammo_shells = (self.ammo_shells + h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if (((who.ammo_nails > STATE_HOME) && (who.items & IT_NAILS)))
	{
		h = (self.max_nails - self.ammo_nails);
		if ((h > who.ammo_nails))
		{
			h = who.ammo_nails;
		}
		who.ammo_nails = (who.ammo_nails - h);
		self.ammo_nails = (self.ammo_nails + h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if (((who.ammo_rockets > STATE_HOME) && (who.items & IT_ROCKETS)))
	{
		h = (self.max_rockets - self.ammo_rockets);
		if ((h > who.ammo_rockets))
		{
			h = who.ammo_rockets;
		}
		who.ammo_rockets = (who.ammo_rockets - h);
		self.ammo_rockets = (self.ammo_rockets + h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if (((who.ammo_cells > STATE_HOME) && (who.items & IT_CELLS)))
	{
		h = (self.max_cells - self.ammo_cells);
		if ((h > who.ammo_cells))
		{
			h = who.ammo_cells;
		}
		who.ammo_cells = (who.ammo_cells - h);
		self.ammo_cells = (self.ammo_cells + h);
		if ((h > STATE_HOME))
		{
			flag = WEAPON_SHOTGUN;
		}
	}
	if ((flag == WEAPON_SHOTGUN))
	{
		centerprint3(who, "Your ammo was stolen by\n", self.netname, "!!!");
		sound(self, CHAN_AUTO, "weapons/lock4.wav", WEAPON_SHOTGUN, ATTN_NORM);
		centerprint3(self, "You stole\n", who.netname, "'s\nammo");
		stuffcmd(who, "bf\n");
		stuffcmd(self, "bf\n");
		oself = self;
		self = who;
		W_SetCurrentAmmo();
		self = oself;
	}
};
.float hook;
float HOOK_OUT    = 1;
float HOOK_ON    = 2;
float ACTIVATE_HOOK    = 198;
float TERMINATE_HOOK    = 199;

void(entity Head) DisolveChain =
{
	local entity link;

	link = Head.goalentity;
	while ((link != world))
	{
		Head = link.goalentity;
		remove(link);
		link = Head;
	}
};

void() LinkPos =
{
	setorigin(self, (self.owner.origin + (((self.enemy.origin + '0 0 16') - self.owner.origin) * self.weapon)));
	self.nextthink = (time + 0.01);
};

entity(entity head, entity tail, float num) CreateChain =
{
	local entity link;
	local entity prevlink;
	local float linknum;

	linknum = num;
	num = (num + HOOK_OUT);
	prevlink = world;
	while ((linknum > STATE_HOME))
	{
		link = spawn();
		link.goalentity = prevlink;
		prevlink = link;
		link.owner = head;
		link.enemy = tail;
		link.weapon = (linknum / num);
		link.movetype = MOVETYPE_NOCLIP;
		link.solid = SOLID_NOT;
		link.angles_z = (51 * linknum);
		link.angles_y = (41 * linknum);
		link.angles_x = (SVC_FINALE * linknum);
		link.avelocity = '310 410 510';
		setmodel(link, "progs/bit.mdl");
		setsize(link, VEC_ORIGIN, VEC_ORIGIN);
		setorigin(link, (head.origin + (((tail.origin + '0 0 16') - head.origin) * link.weapon)));
		link.nextthink = (time + 0.01);
		link.think = LinkPos;
		linknum = (linknum - HOOK_OUT);
	}
	return (link);
};

void() HookVanish =
{
	local entity oself;

	oself = self;
	self = self.owner;
	if ((((self.weaponframe != STATE_HOME) && (self.weapon == IT_SHOTGUN)) && !self.deadflag))
	{
		player_run();
	}
	self = oself;
	self.owner.hook = (self.owner.hook - (self.owner.hook & HOOK_OUT));
	DisolveChain(self);
	remove(self);
};

void() HookPull =
{
	local vector vel;
	local vector spray;
	local float v;

	if ((((((self.owner.hook & HOOK_ON) != HOOK_ON) || (self.owner.teleport_time > time)) || self.owner.deadflag) || (self.enemy.solid == SOLID_NOT)))
	{
		HookVanish();
		return;
	}
	setorigin(self, (self.enemy.origin + self.dest1));
	vel = (self.origin - (self.owner.origin + '0 0 16'));
	v = vlen(vel);
	if ((v <= 100))
	{
		vel = ((normalize(vel) * v) * CLASS_BSMITH);
	}
	if ((v > 100))
	{
		vel = (normalize(vel) * 700);
	}
	self.owner.velocity = vel;
	self.nextthink = (time + 0.1);
};

void() touch_nohook =
{
	if ((other.classname == "hookstar"))
	{
		other.cheating = TRUE;
	}
};

void() trigger_nohook =
{
	InitTrigger();
	self.touch = touch_nohook;
};

void() T_ChainTouch =
{
	if (((self.owner.hook & HOOK_ON) != HOOK_ON))
	{
		HookVanish();
		return;
	}
	if ((self.cheating == TRUE))
	{
		HookVanish();
		return;
	}
	if ((other.solid == SOLID_SLIDEBOX))
	{
		setorigin(self, ((other.origin + other.mins) + (other.size * 0.5)));
	}
	else
	{
		sound(self, CHAN_WEAPON, "player/axhit2.wav", HOOK_OUT, ATTN_NORM);
		self.avelocity = VEC_ORIGIN;
	}
	self.solid = SOLID_NOT;
	self.dest1 = (self.origin - other.origin);
	self.movetype = MOVETYPE_NONE;
	self.enemy = other;
	self.nextthink = (time + 0.1);
	self.think = HookPull;
	self.touch = SUB_Null;
};

void(entity myself) Thief_FireChain =
{
	local entity star;

	star = spawn();
	star.owner = self;
	star.movetype = MOVETYPE_FLY;
	star.solid = SOLID_BBOX;
	setmodel(star, "progs/hook.mdl");
	setsize(star, VEC_ORIGIN, VEC_ORIGIN);
	makevectors(myself.v_angle);
	setorigin(star, ((myself.origin + (v_forward * FL_VOTED)) + '0 0 16'));
	star.velocity = (v_forward * 1000);
	star.angles = vectoangles(self.velocity);
	sound(myself, CHAN_WEAPON, "weapons/ax1.wav", HOOK_OUT, ATTN_NORM);
	star.classname = "hookstar";
	star.cheating = FALSE;
	star.touch = T_ChainTouch;
	star.nextthink = (time + 1.3);
	star.think = HookVanish;
	star.goalentity = CreateChain(star, myself, WEAPON_BIG);
};

void() Thief_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_knife.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = STATE_HOME;
			self.weaponmodel = "progs/v_hook.mdl";
			self.weaponframe = STATE_HOME;
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = STATE_HOME;
				self.weaponmodel = "progs/v_clept.mdl";
				self.weaponframe = STATE_HOME;
			}
			else
			{
				self.currentammo = STATE_HOME;
				self.weaponmodel = "";
				self.weaponframe = STATE_HOME;
			}
		}
	}
};

float() Thief_BestWeapon =
{
	return (IT_AXE);
};

float() Thief_CheckNoAmmo =
{
	return (TRUE);
};

void() Thief_Attack =
{
	local float r;

	if (!Thief_CheckNoAmmo())
	{
		return;
	}
	if (((self.weaponframe != STATE_HOME) && (self.weapon == IT_SHOTGUN)))
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + HOOK_OUT);
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + 0.5);
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", HOOK_OUT, ATTN_NORM);
		r = random();
		if ((r < 0.25))
		{
			player_axe1();
		}
		else
		{
			if ((r < 0.5))
			{
				player_axeb1();
			}
			else
			{
				if ((r < 0.75))
				{
					player_axec1();
				}
				else
				{
					player_axed1();
				}
			}
		}
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			player_hook1();
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.attack_finished = (time + 0.5);
				player_steal1();
			}
		}
	}
};

void() Thief_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = STATE_HOME;
	if ((self.impulse == HOOK_OUT))
	{
		fl = IT_AXE;
	}
	else
	{
		if ((self.impulse == HOOK_ON))
		{
			fl = IT_SHOTGUN;
		}
		else
		{
			if ((self.impulse == MAP_TF))
			{
				fl = IT_SUPER_SHOTGUN;
			}
		}
	}
	self.impulse = STATE_HOME;
	if (!(self.items & fl))
	{
		sprint(self, PRINT_HIGH, "no weapon.\n");
		return;
	}
	if (am)
	{
		sprint(self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}
	self.weapon = fl;
	W_SetCurrentAmmo();
};

void() ThiefCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_AXE))
		{
			self.weapon = IT_SHOTGUN;
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_SUPER_SHOTGUN;
			}
			else
			{
				if ((self.weapon == IT_SUPER_SHOTGUN))
				{
					self.weapon = IT_AXE;
				}
			}
		}
		if (((self.items & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ThiefCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (HOOK_OUT)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_SHOTGUN))
		{
			self.weapon = IT_SHOTGUN;
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_AXE;
			}
			else
			{
				if ((self.weapon == IT_AXE))
				{
					self.weapon = IT_SUPER_SHOTGUN;
				}
			}
		}
		if (((it & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ThiefImpulse =
{
	if (((self.impulse >= HOOK_OUT) && (self.impulse <= WEAPON_BIG)))
	{
		Thief_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		ThiefCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		ThiefCycleWeaponReverseCommand();
	}
	if ((((self.weapon != IT_SHOTGUN) && (self.impulse == ACTIVATE_HOOK)) && !(self.hook & HOOK_OUT)))
	{
		self.hook = (HOOK_OUT | HOOK_ON);
		Thief_FireChain(self);
	}
	if ((((self.weapon != IT_SHOTGUN) && (self.impulse == TERMINATE_HOOK)) && (self.hook & HOOK_OUT)))
	{
		self.hook = (self.hook - (self.hook & HOOK_ON));
	}
	self.impulse = STATE_HOME;
};
