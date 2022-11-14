class NilActor : Actor
{
	Default
	{
		+NOGRAVITY;
		+NOINTERACTION;
		+NODAMAGE;
		+INVULNERABLE;
		+NOSECTOR;

		// Wouldn't want explosives moving this.
		+DONTTHRUST;
	}
}