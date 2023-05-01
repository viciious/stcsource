//Decompiled code. Please respect the original copyright.

void() BarrelPrecache =
{
	precache_model("progs/v_flame.mdl");
	precache_model("progs/fire.mdl");
	precache_model("progs/v_bomb.mdl");
	precache_model("progs/v_barrel.mdl");
	precache_sound("barrel/bounce.wav");
	precache_sound("barrel/catch.wav");
	precache_sound("barrel/out.wav");
	precache_sound("barrel/barrel.wav");
	precache_model("progs/bomb.mdl");
	precache_model("progs/barrel.mdl");
};

void() Barrel_SetSpawn =
{
	self.max_shells = STATE_HOME;
	self.max_nails = 60;
	self.max_rockets = 200;
	self.max_cells = STATE_HOME;
	self.items = ((IT_AXE | IT_SHOTGUN) | IT_SUPER_SHOTGUN);
	self.ammo_rockets = SVC_INTERMISSION;
	self.armorvalue = STATE_HOME;
	self.armortype = STATE_HOME;
	self.max_type = 0.6;
	self.max_value = 150;
	self.max_bit = IT_ARMOR2;
	self.max_strafe = 150;
	self.max_speed = 175;
	stuffcmd(self, "exec cfg/barrel.cfg\n");
	self.pl_skin = "base";
};

void() GrenadeExplode =
{
	if (self.voided)
	{
		return;
	}
	self.voided = WEAPON_SHOTGUN;
	T_RadiusDamage(self, self.owner, 150, world, "grenade", STATE_HOME);
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast(self.origin, MULTICAST_PHS);
	remove(self);
};

void() GrenadeTouch =
{
	if ((other == self.owner))
	{
		return;
	}
	if (((other.takedamage == DAMAGE_AIM) && !(other.aflag & FL_SHEILD)))
	{
		GrenadeExplode();
		return;
	}
	sound(self, CHAN_WEAPON, "barrel/bounce.wav", WEAPON_SHOTGUN, ATTN_NORM);
	if ((self.velocity == VEC_ORIGIN))
	{
		self.avelocity = VEC_ORIGIN;
	}
};

void() Barrel_FireBomb =
{
	if ((deathmatch != WEAPON_SPIKES))
	{
		self.ammo_rockets = (self.ammo_rockets - WEAPON_SHOTGUN);
		self.currentammo = (self.ammo_rockets - WEAPON_SHOTGUN);
	}
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_SMALLKICK);
	newmis = spawn();
	newmis.voided = STATE_HOME;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "grenade";
	makevectors(self.v_angle);
	if (self.v_angle_x)
	{
		newmis.velocity = ((((v_forward * 700) + (v_up * 200)) + ((crandom() * v_right) * TE_LAVASPLASH)) + ((crandom() * v_up) * TE_LAVASPLASH));
	}
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = (newmis.velocity * 700);
		newmis.velocity_z = 200;
	}
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = GrenadeTouch;
	if ((deathmatch == WEAPON_SPIKES))
	{
		newmis.nextthink = (time + 2.5);
		self.attack_finished = (time + 1.1);
		T_Damage(self, self, self.owner, TE_LAVASPLASH, STATE_HOME);
	}
	else
	{
		newmis.nextthink = (time + 2.5);
	}
	newmis.think = GrenadeExplode;
	setmodel(newmis, "progs/bomb.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, self.origin);
};

void() Barrel_FireTorch =
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
	other = trace_ent;
	if ((other.takedamage == DAMAGE_AIM))
	{
		SetOnFire(80);
	}
	else
	{
		if (other.takedamage)
		{
			trace_ent.axhitme = WEAPON_SHOTGUN;
			if ((deathmatch > MAP_TF))
			{
				T_Damage(trace_ent, self, self, 75, STATE_HOME);
			}
			else
			{
				T_Damage(trace_ent, self, self, 20, STATE_HOME);
			}
		}
	}
};

entity() FindBarrel =
{
	local entity t;

	t = find(world, classname, "barrel");
	while ((t != world))
	{
		if ((t.r_owner == self))
		{
			return (t);
		}
		t = find(t, classname, "barrel");
	}
	return (t);
};

void(entity attacker, float take) BarrelPain =
{
};

void() Explode_Barrel =
{
	if ((self.r_owner.build_item == self))
	{
		self.r_owner.build_finished = time;
		self.r_owner.saved_time = STATE_HOME;
		self.r_owner.build_item = world;
		self.r_owner.th_build = SUB_Null;
		ThrowGib("progs/shrap1.mdl", (self.health * WEAPON_ROCKET));
		ThrowGib("progs/shrap2.mdl", (self.health * WEAPON_ROCKET));
		ThrowGib("progs/shrap3.mdl", (self.health * WEAPON_ROCKET));
		sound(self, CHAN_BODY, "bsmith/die.wav", WEAPON_SHOTGUN, ATTN_NORM);
		remove(self);
		return;
	}
	if (self.voided)
	{
		return;
	}
	self.voided = WEAPON_SHOTGUN;
	T_RadiusDamage(self, self.r_owner, 500, world, "barrel", STATE_HOME);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	multicast(self.origin, MULTICAST_PHS);
	sound(self, CHAN_AUTO, "barrel/barrel.wav", WEAPON_SHOTGUN, ATTN_NORM);
	remove(self);
};

void() Build_Barrel =
{
	local entity y;

	y = self.build_item;
	y.vteam = self.vteam;
	self.build_item = world;
};

void() FireBarrel =
{
	local float temp;
	local entity film;

	if ((CountDaughters("barrel") > STATE_HOME))
	{
		film = self;
		self = FindBarrel();
		self.th_die();
		self = film;
		W_SetCurrentAmmo();
		return;
	}
	if ((self.ammo_nails < SVC_INTERMISSION))
	{
		return;
	}
	makevectors(self.v_angle);
	v_forward_z = STATE_HOME;
	v_forward = (normalize(v_forward) * FL_DIALOG);
	obj_org = (self.origin + v_forward);
	obj_mins = '-16 -16 -16';
	obj_maxs = '16 16 20';
	temp = CheckArea(self);
	if ((temp == FALSE))
	{
		sprint(self, PRINT_HIGH, "You cannot build there.\n");
		return;
	}
	newmis = spawn();
	self.build_finished = (time + WEAPON_SPIKES);
	self.saved_time = (time + WEAPON_SHOTGUN);
	self.ammo_nails = (self.ammo_nails - SVC_INTERMISSION);
	self.currentammo = (self.ammo_nails - SVC_INTERMISSION);
	self.th_build = Build_Barrel;
	self.oldorigin = self.origin;
	self.build_item = newmis;
	setorigin(newmis, obj_org);
	newmis.r_owner = self;
	newmis.ammo_nails = SVC_INTERMISSION;
	newmis.item_class = "daughter";
	setmodel(newmis, "progs/barrel.mdl");
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_YES;
	newmis.th_pain = BarrelPain;
	newmis.health = 75;
	newmis.max_health = 75;
	newmis.movetype = MOVETYPE_TOSS;
	setsize(newmis, obj_mins, obj_maxs);
	newmis.touch = SUB_Null;
	newmis.classname = "building_barrel";
	newmis.netname = "barrel";
	newmis.th_die = Explode_Barrel;
};

void() Barrel_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_flame.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_rockets;
			self.weaponmodel = "progs/v_bomb.mdl";
			self.weaponframe = STATE_HOME;
			self.items = (self.items | IT_ROCKETS);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = self.ammo_nails;
				if ((CountDaughters("barrel") > STATE_HOME))
				{
					self.weaponmodel = "";
				}
				else
				{
					self.weaponmodel = "progs/v_barrel.mdl";
				}
				self.weaponframe = STATE_HOME;
				self.items = (self.items | IT_NAILS);
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

float() Barrel_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_rockets >= WEAPON_SHOTGUN) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() Barrel_CheckNoAmmo =
{
	if ((self.currentammo > STATE_HOME))
	{
		return (TRUE);
	}
	if (((self.weapon == IT_SUPER_SHOTGUN) && (CountDaughters("barrel") != STATE_HOME)))
	{
		return (TRUE);
	}
	if (((self.weapon == IT_SUPER_SHOTGUN) && (self.ammo_nails < SVC_INTERMISSION)))
	{
		return (FALSE);
	}
	if ((self.weapon == IT_AXE))
	{
		return (TRUE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};

void() Barrel_Attack =
{
	local float r;

	if (!Barrel_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + WEAPON_SHOTGUN);
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + WEAPON_SHOTGUN);
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", WEAPON_SHOTGUN, ATTN_NORM);
		player_torch1();
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			player_bomb1();
			self.attack_finished = (time + 0.5);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				FireBarrel();
				self.attack_finished = (time + WEAPON_SHOTGUN);
			}
		}
	}
};

void() Barrel_ChangeWeapon =
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
			if ((self.ammo_rockets < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
			}
		}
		else
		{
			if ((self.impulse == MAP_TF))
			{
				fl = IT_SUPER_SHOTGUN;
				if (((self.ammo_nails < SVC_INTERMISSION) && (CountDaughters("barrel") == STATE_HOME)))
				{
					am = WEAPON_SHOTGUN;
				}
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

void() BarrelCycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_SHOTGUN))
		{
			self.weapon = IT_AXE;
		}
		else
		{
			if ((self.weapon == IT_AXE))
			{
				self.weapon = IT_SHOTGUN;
				if ((self.ammo_rockets < WEAPON_SHOTGUN))
				{
					am = WEAPON_SHOTGUN;
				}
			}
			else
			{
				if ((self.weapon == IT_SHOTGUN))
				{
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_nails < SVC_INTERMISSION))
					{
						am = WEAPON_SHOTGUN;
					}
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

void() BarrelCycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = STATE_HOME;
	while (WEAPON_SHOTGUN)
	{
		am = STATE_HOME;
		if ((self.weapon == IT_SUPER_SHOTGUN))
		{
			self.weapon = IT_SHOTGUN;
			if ((self.ammo_rockets < WEAPON_SHOTGUN))
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
			else
			{
				if ((self.weapon == IT_AXE))
				{
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_nails < SVC_INTERMISSION))
					{
						am = WEAPON_SHOTGUN;
					}
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

void() BarrelImpulse =
{
	if (((self.impulse >= WEAPON_SHOTGUN) && (self.impulse <= WEAPON_BIG)))
	{
		Barrel_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		BarrelCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		BarrelCycleWeaponReverseCommand();
	}
	self.impulse = STATE_HOME;
};

void() Barrel_WeaponFrame =
{
};
