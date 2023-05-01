//Decompiled code. Please respect the original copyright.

void() AlchPrecache =
{
	precache_model("progs/v_orb.mdl");
	precache_model("progs/v_cod.mdl");
	precache_model("progs/potion.mdl");
	precache_model("progs/v_potion.mdl");
	precache_model("progs/w_spike.mdl");
	precache_sound("alch/sceptar.wav");
	precache_sound("wizard/hit.wav");
	precache_model("progs/s_psn.spr");
	precache_sound("alch/shatter.wav");
	precache_sound("items/r_item1.wav");
	precache_model("progs/cauldron.mdl");
	precache_sound("items/health1.wav");
	precache_model("progs/shrap1.mdl");
	precache_model("progs/shrap2.mdl");
	precache_model("progs/shrap3.mdl");
	precache_sound("alch/clang.wav");
	precache_sound("alch/cgib.wav");
	precache_sound("alch/churn.wav");
};

void() Alch_SetSpawn =
{
	self.max_shells = STATE_HOME;
	self.max_nails = 60;
	self.max_rockets = STATE_HOME;
	self.max_cells = 100;
	self.items = ((IT_AXE | IT_SHOTGUN) | IT_SUPER_SHOTGUN);
	self.armorvalue = STATE_HOME;
	self.armortype = STATE_HOME;
	self.max_type = 0.3;
	self.max_value = 100;
	self.max_bit = IT_ARMOR1;
	self.ammo_cells = 100;
	self.max_strafe = 230;
	self.max_speed = 250;
	stuffcmd(self, "exec cfg/alch.cfg\n");
	self.pl_skin = "stc_alch";
};
void() CauldronGib;

void() Cauldron_Touch =
{
	local string h;

	if (((other.vteam != self.vteam) && MAX_TEAMS))
	{
		return;
	}
	if ((other.health <= STATE_HOME))
	{
		return;
	}
	if ((other.classname != "player"))
	{
		return;
	}
	h = self.r_owner.netname;
	if (((other.class == CLASS_ALCH) && (self.regen_time != 50)))
	{
		centerprint(other, "You have re-filled the cauldron.\n");
		self.regen_time = 50;
		return;
	}
	if ((self.regen_time == STATE_HOME))
	{
		centerprint(other, "The cauldron is empty.\n");
		CauldronGib();
		return;
	}
	if ((self.regen_time == CLASS_THIEF))
	{
		centerprint(self.r_owner, "Your cauldron is getting empty.\n");
	}
	if ((other.health < (other.max_health + 100)))
	{
		other.health = (other.max_health + 100);
		sound(self, CHAN_BODY, "items/health1.wav", WEAPON_SHOTGUN, ATTN_NORM);
		centerprint(other, "You have been healed by the cauldron.\n");
		self.regen_time = (self.regen_time - WEAPON_SHOTGUN);
		return;
	}
	if ((other.poison > STATE_HOME))
	{
		other.poison = STATE_HOME;
		centerprint(other, "Cauldron has cleansed\nthe poison from your\nwounds.\n");
		sound(self, CHAN_BODY, "misc/talk.wav", WEAPON_SHOTGUN, ATTN_NORM);
		self.regen_time = (self.regen_time - WEAPON_SHOTGUN);
		if ((other != self.r_owner))
		{
			self.r_owner.frags = (self.r_owner.frags + WEAPON_SHOTGUN);
		}
		return;
	}
	if ((other.heat > STATE_HOME))
	{
		other.heat = STATE_HOME;
		centerprint(other, "Cauldron has extinguised\nthe flames.\n");
		sound(self, CHAN_BODY, "misc/talk.wav", WEAPON_SHOTGUN, ATTN_NORM);
		self.regen_time = (self.regen_time - WEAPON_SHOTGUN);
		if ((other != self.r_owner))
		{
			self.r_owner.frags = (self.r_owner.frags + WEAPON_SHOTGUN);
		}
	}
};

void() CauldronGib =
{
	local entity own;
	local string j;

	own = self.r_owner;
	if ((own.build_item == self))
	{
		own.build_finished = time;
		own.saved_time = STATE_HOME;
		own.build_item = world;
		own.th_build = SUB_Null;
		ThrowGib("progs/shrap1.mdl", (self.health * WEAPON_ROCKET));
		ThrowGib("progs/shrap2.mdl", (self.health * WEAPON_ROCKET));
		ThrowGib("progs/shrap3.mdl", (self.health * WEAPON_ROCKET));
		sound(self, CHAN_BODY, "alch/cgib.wav", WEAPON_SHOTGUN, ATTN_NORM);
		remove(self);
		return;
	}
	j = self.enemy.netname;
	if ((j != ""))
	{
		centerprint3(own, "", j, " has destroyed\n your cauldron!\n");
	}
	else
	{
		centerprint(own, "Your cauldron has been destroyed.\n");
	}
	ThrowGib("progs/shrap1.mdl", (self.health * WEAPON_ROCKET));
	ThrowGib("progs/shrap2.mdl", (self.health * WEAPON_ROCKET));
	ThrowGib("progs/shrap3.mdl", (self.health * WEAPON_ROCKET));
	sound(self, CHAN_BODY, "alch/cgib.wav", WEAPON_SHOTGUN, ATTN_NORM);
	remove(self);
};

void(entity attacker, float take) CauldronPain =
{
	sound(self, CHAN_BODY, "alch/clang.wav", 0.5, ATTN_NORM);
};

void() Build_Cauldron =
{
	local entity y;

	y = self.build_item;
	y.vteam = self.vteam;
	y.touch = Cauldron_Touch;
	y.regen_time = 50;
	self.build_item = world;
};

void() Alch_Cauldron =
{
	local float temp;

	if ((CountDaughters("cauldron") > WEAPON_SHOTGUN))
	{
		sprint(self, PRINT_HIGH, "You can have only two cauldrons at a time.\n");
		return;
	}
	makevectors(self.v_angle);
	v_forward_z = STATE_HOME;
	v_forward = (normalize(v_forward) * FL_DIALOG);
	obj_org = (self.origin + v_forward);
	obj_mins = '-16 -16 -16';
	obj_maxs = '16 16 16';
	temp = CheckArea(self);
	if ((temp == FALSE))
	{
		sprint(self, PRINT_HIGH, "You cannot build there.\n");
		return;
	}
	newmis = spawn();
	self.build_finished = (time + 15);
	self.saved_time = (time + WEAPON_SHOTGUN);
	self.ammo_nails = (self.ammo_nails - SVC_INTERMISSION);
	self.currentammo = (self.ammo_nails - SVC_INTERMISSION);
	self.th_build = Build_Cauldron;
	self.oldorigin = self.origin;
	self.build_item = newmis;
	setorigin(newmis, obj_org);
	newmis.r_owner = self;
	newmis.item_class = "daughter";
	setmodel(newmis, "progs/cauldron.mdl");
	newmis.solid = SOLID_BBOX;
	newmis.takedamage = DAMAGE_YES;
	newmis.th_pain = CauldronPain;
	newmis.health = 300;
	newmis.max_health = 300;
	newmis.ammo_nails = SVC_INTERMISSION;
	newmis.movetype = MOVETYPE_TOSS;
	setsize(newmis, obj_mins, obj_maxs);
	newmis.touch = SUB_Null;
	newmis.classname = "building_cauldron";
	newmis.netname = "cauldron";
	newmis.th_die = CauldronGib;
};

void() fire_poison_sceptar =
{
	local vector vec;
	local vector org;

	makevectors(self.v_angle);
	org = ((self.origin + '0 0 16') + (v_forward * 20));
	if ((deathmatch != WEAPON_SPIKES))
	{
		self.ammo_cells = (self.ammo_cells - WEAPON_SHOTGUN);
		self.currentammo = (self.ammo_cells - WEAPON_SHOTGUN);
	}
	vec = normalize(v_forward);
	sound(self, CHAN_WEAPON, "alch/sceptar.wav", WEAPON_SHOTGUN, ATTN_NORM);
	launch_spike(org, vec);
	newmis.velocity = (vec * 600);
	newmis.owner = self;
	newmis.classname = "wizspike";
	setmodel(newmis, "progs/w_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.attack_finished = (time + 0.5);
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_BIGKICK);
};

void() s_psn1 = [ 0, s_psn2 ]
{
};

void() s_psn2 = [ 1, s_psn3 ]
{
};

void() s_psn3 = [ 2, s_psn4 ]
{
};

void() s_psn4 = [ 3, s_psn5 ]
{
};

void() s_psn5 = [ 4, SUB_Remove ]
{
};

void() PotionShatter =
{
	local float h;

	if (self.voided)
	{
		return;
	}
	self.voided = WEAPON_SHOTGUN;
	if ((other.takedamage == DAMAGE_AIM))
	{
		if (((other.vteam == self.owner.vteam) && MAX_TEAMS))
		{
			h = other.health;
			T_Heal(other, TE_LAVASPLASH, TRUE);
			if ((h != other.health))
			{
				sound(self, CHAN_WEAPON, "items/r_item1.wav", WEAPON_SHOTGUN, ATTN_NORM);
			}
			remove(self);
			other.heat = STATE_HOME;
			other.poison = STATE_HOME;
			return;
		}
		other.poison = (other.poison + 45);
		other.enemy = self.owner;
	}
	else
	{
		if (other.takedamage)
		{
			T_Damage(other, self, self.owner, CLASS_THIEF, STATE_HOME);
		}
	}
	sound(self, CHAN_VOICE, "alch/shatter.wav", WEAPON_SHOTGUN, ATTN_NORM);
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_GUNSHOT);
	WriteByte(MSG_MULTICAST, SVC_INTERMISSION);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast(self.origin, MULTICAST_PVS);
	self.movetype = MOVETYPE_NONE;
	self.velocity = VEC_ORIGIN;
	self.touch = SUB_Null;
	setmodel(self, "progs/s_psn.spr");
	self.solid = SOLID_NOT;
	T_RadiusDamage(self, self.owner, TE_LAVASPLASH, self, "poison2", DAMAGE_IGNOREARMOR);
	s_psn1();
};

void() Alch_FirePotion =
{
	newmis = spawn();
	newmis.voided = STATE_HOME;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "potion";
	makevectors(self.v_angle);
	if (self.v_angle_x)
	{
		newmis.velocity = ((((v_forward * 500) + (v_up * 200)) + ((crandom() * v_right) * TE_LAVASPLASH)) + ((crandom() * v_up) * TE_LAVASPLASH));
	}
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = (newmis.velocity * 500);
		newmis.velocity_z = 50;
	}
	newmis.avelocity = '600 600 600';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = PotionShatter;
	setmodel(newmis, "progs/potion.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, self.origin);
};

void() Alch_SetCurrentAmmo =
{
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
	if ((self.weapon == IT_AXE))
	{
		self.currentammo = STATE_HOME;
		self.weaponmodel = "progs/v_potion.mdl";
		self.weaponframe = STATE_HOME;
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			self.currentammo = self.ammo_cells;
			self.weaponmodel = "progs/v_orb.mdl";
			self.weaponframe = STATE_HOME;
			self.items = (self.items | IT_CELLS);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.currentammo = self.ammo_nails;
				self.weaponmodel = "progs/v_cod.mdl";
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

float() Alch_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_cells >= WEAPON_SHOTGUN) && (it & IT_SHOTGUN)))
	{
		return (IT_SHOTGUN);
	}
	return (IT_AXE);
};

float() Alch_CheckNoAmmo =
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

void() Alch_Attack =
{
	local float r;

	if (!Alch_CheckNoAmmo())
	{
		return;
	}
	makevectors(self.v_angle);
	self.show_hostile = (time + WEAPON_SHOTGUN);
	if ((self.weapon == IT_AXE))
	{
		self.attack_finished = (time + 0.5);
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", WEAPON_SHOTGUN, ATTN_NORM);
		player_axe1();
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			player_shot1();
			self.attack_finished = (time + 0.5);
			fire_poison_sceptar();
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				self.attack_finished = (time + 0.7);
				Alch_Cauldron();
			}
		}
	}
};

void() Alch_ChangeWeapon =
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
			if ((self.ammo_cells < WEAPON_SHOTGUN))
			{
				am = WEAPON_SHOTGUN;
			}
		}
		else
		{
			if ((self.impulse == MAP_TF))
			{
				fl = IT_SUPER_SHOTGUN;
				if ((self.ammo_nails < SVC_INTERMISSION))
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

void() AlchCycleWeaponCommand =
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
				if ((self.ammo_cells < WEAPON_SHOTGUN))
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

void() AlchCycleWeaponReverseCommand =
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
			if ((self.ammo_cells < WEAPON_SHOTGUN))
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

void() AlchImpulse =
{
	local string h;

	if (((self.impulse >= WEAPON_SHOTGUN) && (self.impulse <= WEAPON_BIG)))
	{
		Alch_ChangeWeapon();
	}
	if ((self.impulse == TE_LAVASPLASH))
	{
		AlchCycleWeaponCommand();
	}
	if ((self.impulse == TE_BLOOD))
	{
		AlchCycleWeaponReverseCommand();
	}
	if ((self.impulse == 44))
	{
		return;
	}
	self.impulse = STATE_HOME;
};
