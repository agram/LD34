import hxd.Res in Res;
import Const;

class Piece extends Entity
{
	var timer:Float;
	var value:Float;

	public function new(x, y, value)
	{
		super(Piece, x, y, [h2d.Tile.fromColor(0xFFFF00, 8, 8)]);

		this.value = value;

		if (Std.random(3) == 0) Res.sound.piece.play(false, 0.2);

		game.s2d.add(anim, Const.LAYER_GAME + 2);
		var a = new Twin(this, TIME, 30);
		a.setDest(x + Std.random(128) - 64, y + Std.random(32) + 32);
		a.sethJump(Std.random(16) + 16);
		a.onFinish(function() { interactive.visible = true; });
		initInteractive();
		interactive.scale(4);
		interactive.x -= getWidth();
		interactive.y -= getHeight();
		interactive.propagateEvents = true;
		//piece.interactive.backgroundColor = 0x80808080;
		interactive.onOver = function (e) { ramasse(); };
		interactive.onOut = function (e) { ramasse(); };
		interactive.onMove = function (e) { ramasse(); };
		interactive.visible = false;

		timer = haxe.Timer.stamp();
	}

	override public function update(dt:Float)
	{
		super.update(dt);

		if (haxe.Timer.stamp() - timer > 5) ramasse();

	}

	var isOk = false;

	function ramasse() {
		if (isOk) return;
		isOk = true;
		if(Std.random(3) == 0) Res.sound.piece.play(false, 0.2);
		var b = new Twin(this, TIME, 15);
		b.setDest(x, y - 16);
		var b = new Twin(this, ALPHA, 15);
		b.setDest(0);
		b.onFinish(function () { remove(); } );

		battle.player.addMoney(value);

		var e = new Entity(ENull, x, y, [h2d.Tile.fromColor(0xFFFFFF, 1, 1, 0)]);
		var t = new h2d.Text(font, this.anim);
		anim.addChild(t);
		t.text = value + '';
		t.x -= (t.textWidth + 8);
		t.y -= t.textHeight / 2;
		var a = new Twin(e, TIME, 15);
		a.setDest(e.x, e.y - 32);
		a.onFinish(function () {
			t.remove();
			e.remove();
		});
	}

}