import hxd.Res in Res;
import Const;

enum JardinierState {
	Stand;
	Attack;
}

class Jardinier extends Entity
{
	public var state:JardinierState;

	public function new()
	{
		super(Hero, Const.W / 4 * 3, Const.H / 5 * 3 , [h2d.Tile.fromColor(0xFF0000, 16, 16)]);

		state = Stand;
	}

	public function attaque() {
		battle.ennemy.hurt(10);

		if (state != Stand) return;
		state = Attack;
		y = y - 8;
		game.event.wait(0.2, function () {
			y = y + 8;
			state = Stand;
		});
	}
}