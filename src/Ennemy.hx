import hxd.Res in Res;
import Const;

class Ennemy extends Entity
{
	var money:Float;

	var jauge:ui.Jauge;
	var jaugeTimer:ui.Jauge;

	public var isBigBoss:Bool = false;

	public function new()
	{
		super(Ennemy, Const.W / 4 * 3, Const.H / 7 * 2, [h2d.Tile.fromColor(0xFF0000, 32, 32)]);

		isBigBoss = battle.isBigBoss();

		lifeMax = life = (10 + 10 * battle.player.rank) * (isBigBoss ? 10 : 1);

		money = 10 + 1 * battle.player.rank;

		jauge = new ui.Jauge(LIFE, x, y - getHeight() / 2 - 8, 48, 8, this);

		anim.scale(0.5);
		var a = new Twin(this, SCALE, 20);
		a.setDest(1);
		anim.alpha = 0.5;
		var b = new Twin(this, ALPHA, 20);
		b.setDest(1);

		if (isBigBoss) {
			jaugeTimer = new ui.Jauge(TIMER, x, y - getHeight() / 2 - 24, 48, 8, this);
		}
	}

	override public function update(dt:Float)
	{
		super.update(dt);
		//if(haxe.Timer.stamp() - e.beginTimer > 30)
	}

	override public function hurt(dmg:Float)
	{
		if (dead) return;
		super.hurt(dmg);

		if (dead) {
			battle.player.addRank();
			jauge.remove();
			explode();
			remove();
			game.event.wait(0.5, function () {
				battle.ennemy = new Ennemy();
			});

			var nb = battle.isBigBoss() ? Std.random(10) + 10 : Std.random(3) + 3;
			var miniMoney = Math.ceil(money / nb);
			for (i in 0...nb) {
				game.event.wait(0.05 * i, function () { new Piece(x, y, miniMoney); });
			}
		}
	}

	override public function remove()
	{
		super.remove();
		jauge.remove();
		if(jaugeTimer != null) jaugeTimer.remove();
	}

}