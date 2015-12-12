package ui;
import hxd.Res in Res;
import Const;

enum TypeJauge {
	LIFE;
	TIMER;
}

class Jauge extends Entity
{
	var type:TypeJauge;
	var e:Entity;
	public var max:Float;
	var jauge:Entity;
	var textValue:h2d.Text;

	var scal:Float;

	public function new(type: ui.Jauge.TypeJauge, x:Float, y:Float, w:Float, h:Float, ?e:Entity)
	{
		scal = 0.5;
		super(Jauge, x, y, [h2d.Tile.fromColor(0x505050, Std.int(w), Std.int(h))]);
		this.type = type;
		game.s2d.add(anim, Const.LAYER_UI + 1);
		this.e = e;
		jauge = new Entity(Jauge, x, y, [h2d.Tile.fromColor(switch(type) {case TIMER: 0xFF0000; case LIFE: 0x80BB20; }, Std.int(w), Std.int(h))]);
		game.s2d.add(jauge.anim, Const.LAYER_UI + 1);
		jauge.setDx(0);
		jauge.x -= w / 2;
		this.max = 10;

		switch(type) {
			case LIFE : this.max = e.lifeMax;
			case TIMER : this.max = 30;
		}

		textValue = new h2d.Text(font);
		textValue.textColor = 0x000000;
		textValue.scale(scal);
		game.s2d.add(textValue, Const.LAYER_UI + 1);

	}

	override public function update(dt:Float)
	{
		super.update(dt);
		var value = 0.;
		switch(type) {
			case LIFE: value = e.life;
			case TIMER: value = max - (haxe.Timer.stamp() - e.beginTimer);
			default:
		};
		if (value < 0) value = 0;
		else if (value > max) value = max;

		jauge.anim.scaleX = value / max;
		textValue.text = Math.floor(value) + '/' + max;
		textValue.x = x - textValue.textWidth / 2 * scal;
		textValue.y = y - textValue.textHeight / 2 * scal;
	}

	override public function remove()
	{
		super.remove();
		textValue.remove();
		jauge.remove();
	}

	public function setVisible(b:Bool) {
		anim.visible = b;
		jauge.anim.visible = b;
		textValue.visible = b;
	}
}