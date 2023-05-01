//Decompiled code. Please respect the original copyright.

void() monster_army_think =
{
	droptofloor();
}

void() monster_army =
{
	self.mdl = "progs/tree2.mdl";
	self.model = "progs/tree2.mdl";
	precache_model("progs/tree2.mdl");
	setmodel(self, "progs/tree2.mdl");
	self.velocity = VEC_ORIGIN;
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.origin_z = self.origin_z + 6;
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.classname = "tree";
	self.think = monster_army_think;
	self.nextthink = time + 0.2;
};
