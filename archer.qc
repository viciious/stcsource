//Decompiled code. Please respect the original copyright.

void() ArcherPrecache =
{
	precache_model("progs/v_bow.mdl");
	precache_sound("archer/draw.wav");
	precache_model("progs/v_bow2.mdl");
	precache_sound("archer/fire1.wav");
	precache_sound("archer/fire2.wav");
	precache_sound("archer/drop.wav");
	precache_sound("archer/hit1.wav");
	precache_sound("archer/hit2.wav");
	precache_model("progs/arrow.mdl");
};

void() Archer_SetSpawn =
{
	self.max_shells = 400;
	self.max_nails = STATE_HOME;
	self.max_rockets = STATE_HOME;
	self.max_cells = STATE_HOME;
	self.items = ((IT_AXE | IT_SHOTGUN) | IT_ARMOR1);
	self.armorvalue = 50;
	self.armortype = 0.3;
	self.max_type = 0.6;
	self.max_value = 100;
	self.max_bit = IT_ARMOR2;
	self.max_strafe = 280;
	self.max_speed = 300;
	stuffcmd(self, "exec cfg/archer.cfg\n");
	self.pl_skin = "stc_arch";
	self.ammo_shells = 25;
	stuffcmd(self, "alias azoom_in \"fov 90; wait; fov 70; wait; fov 50; wait; fov 30; wait; fov 10; wait; fov 5\"\n");
	stuffcmd(self, "alias azoom_out \"fov 10; wait; fov 30; wait; fov 50; wait; fov 70; wait; fov 90\"\n");
	stuffcmd(self, "alias a_on \"setinfo autozoom 1; alias autozoom a_off; echo Auto Zoom on;\"\n");
	stuffcmd(self, "alias a_off \"setinfo autozoom 0; alias autozoom a_on; echo Auto Zoom off;\"\n");
	stuffcmd(self, "alias autozoom \"a_on\"\n");
};

void() Archer_FireAxe =
{
	local vector source;
	local vector org;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * FL_DIALOG)), FALSE, self);
	if ((trace_fraction == WEAPON_SHOTGUN))
	{
		return;
	}
	org = (trace_endpos - (v_forward * WEAPON_SPIKES));
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = WEAPON_SHOTGUN;
		SpawnBlood(org, 20);
		if ((deathmatch > MAP_TF))
		{
			T_Damage(trace_ent, self, self, 75, STATE_HOME);
		}
		else
		{
			T_Damage(trace_ent, self, self, 20, STATE_HOME);
		}
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
void() Arrow_Touch;

void() FixArrow =
{
	self.movetype = MOVETYPE_FLYMISSILE;
	self.touch = Arrow_Touch;
	self.velocity = (normalize(self.velocity) * 2000);
	self.angles = vectoangles(self.velocity);
	sound(self, CHAN_AUTO, "knight/bounce.wav", WEAPON_SHOTGUN, ATTN_NORM);
	other = world;
};

void() Arrow_Touch =
{
	local vector y;
	local entity temp;

	if ((other == world))
	{
		if ((random() < 0.6))
		{
			sound(self, CHAN_AUTO, "archer/hit1.wav", WEAPON_SHOTGUN, ATTN_NORM);
		}
		else
		{
			sound(self, CHAN_AUTO, "archer/hit2.wav", WEAPON_SHOTGUN, ATTN_NORM);
		}
		self.velocity = VEC_ORIGIN;
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = (time + MAP_TF);
		return;
	}
	temp = self;
	self = other;
	if (((other.aflag & FL_SHEILD) && infront(temp)))
	{
		temp.movetype = MOVETYPE_BOUNCE;
		temp.think = FixArrow;
		temp.nextthink = (time + 0.01);
		temp.touch = SUB_Null;
		makevectors(other.v_angle);
		other.velocity = (other.velocity - (v_forward * 60));
		other.armorvalue = (other.armorvalue - MAP_TF);
		if ((other.armorvalue < STATE_HOME))
		{
			other.armorvalue = STATE_HOME;
		}
		return;
	}
	self = temp;
	if ((other.takedamage != DAMAGE_AIM))
	{
		sound(self, CHAN_AUTO, "archer/drop.wav", WEAPON_SHOTGUN, ATTN_NORM);
		y = self.angles;
		T_Damage(other, self, self.owner, self.rad_time, STATE_HOME);
		y_y = anglemod((y_y + 180));
		makevectors(y);
		self.velocity = (v_forward * 100);
		self.avelocity = '500 500 500';
		self.movetype = MOVETYPE_BOUNCE;
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = (time + MAP_TF);
	}
	else
	{
		if ((random() < 0.6))
		{
			sound(self, CHAN_AUTO, "archer/hit1.wav", WEAPON_SHOTGUN, ATTN_NORM);
		}
		else
		{
			sound(self, CHAN_AUTO, "archer/hit2.wav", WEAPON_SHOTGUN, ATTN_NORM);
		}
		other.deathtype = "arrow";
		T_Damage(other, self, self.owner, self.rad_time, STATE_HOME);
		remove(self);
	}
};

void() Archer_ArrowFire =
{
	if ((self.ammo_shells < WEAPON_SHOTGUN))
	{
		return;
	}
	if ((deathmatch != WEAPON_SPIKES))
	{
		self.ammo_shells = (self.ammo_shells - WEAPON_SHOTGUN);
		self.currentammo = (self.ammo_shells - WEAPON_SHOTGUN);
	}
	if ((random() < 0.6))
	{
		sound(self, CHAN_WEAPON, "archer/fire1.wav", 0.6, ATTN_NORM);
	}
	else
	{
		sound(self, CHAN_WEAPON, "archer/fire2.wav", 0.6, ATTN_NORM);
	}
	newmis = spawn();
	newmis.skin = self.vteam;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.rad_time = self.regen_time;
	newmis.velocity = aim(self, 2000);
	newmis.velocity = (newmis.velocity * 2000);
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = Arrow_Touch;
	newmis.voided = STATE_HOME;
	newmis.nextthink = (time + CLASS_THIEF);
	newmis.think = SUB_Remove;
	newmis.classname = "rocket";
	setmodel(newmis, "progs/arrow.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, ((self.origin + (v_forward * WEAPON_BIG)) + '0 0 16'));
	if ((self.weapon == IT_SHOTGUN))
	{
		self.attack_finished = (time + 0.5);
		self.weaponframe = CLASS_BSMITH;
		self.max_strafe = 280;
		self.max_speed = 300;
		SetSpeed();
		player_run();
		if ((infokey(self, "autozoom") == "1"))
		{
			stuffcmd(self, "azoom_out\n");
		}
	}
};

void() Archer_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_shells;
			self.weaponmodel = "progs/v_bow.mdl";
			self.weaponframe = STATE_HOME;
			self.items = (self.items | IT_SHELLS);
		}
		else
		{
			self.currentammo = STATE_HOME;
			self.weaponmodel = "";
			self.weaponframe = STATE_HOME;
		}
	}
};

float() Archer_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_shells >= WEAPON_SHOTGUN) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() Archer_CheckNoAmmo =
{
	if ((self.currentammo > STATE_HOME))
	{
		return (TRUE);
	}
	if ((self.weapon == IT_AXE))
	{
		return (TRUE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;

void() Archer_Attack =
{
	local float r;

	if (!Archer_CheckNoAmmo())
	{
		return;
	}
	if (((self.weaponframe != STATE_HOME) && (self.weapon == IT_SHOTGUN)))
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + WEAPON_SHOTGUN);
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + 0.5);
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", WEAPON_SHOTGUN, ATTN_NORM);
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
			player_arrow1();
			self.attack_finished = (time + 0.5);
		}
	}
};

void() Archer_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = STATE_HOME;
	if ((self.impulse == WEAPON_SHOTGUN))
	{
		fl = IT_AXE;
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			fl = IT_SHOTGUN;
			if ((self.ammo_shells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
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

void() ArcherCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_AXE))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_shells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
			}
		}
		else
		{
			if ((self.weapon == IT_SHOTGUN))
			{
				self.weapon = IT_AXE;
			}
		}
		if (((self.items & self.weapon) && (am == STATE_HOME)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ArcherCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SHOTGUN))
		{
			self.weapon = IT_AXE;
		}
		else
		{
			if ((self.weapon == IT_AXE))
			{
				self.weapon = IT_SHOTGUN;
				if ((self.ammo_shells < WEAPON_SHOTGUN))
				{
					am = WEAPON_SHOTGUN;
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

void() ArcherImpulse =
{
	if (((self.impulse >= WEAPON_SHOTGUN) && (self.impulse <= WEAPON_BIG)))
	{
		Archer_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		ArcherCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		ArcherCycleWeaponReverseCommand();
	}
	self.impulse = STATE_HOME;
};
