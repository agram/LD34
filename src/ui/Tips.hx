package ui;

import hxd.Res in Res;
import Const;

class Tips extends h2d.ScaleGrid
{
	var game:Game;
	var e:Entity;

	var texte:h2d.Text;

	var filtre:Entity;

	public function new(e:Entity)
	{
		game = Game.inst;
		super(Res.dialogRound.toTile(), 4, 4);
		this.e = e;

		filtre = new Entity(ENull, Const.W / 2, Const.H / 2, [h2d.Tile.fromColor(0x808080, Const.W, Const.H, 0.5)]);
		filtre.initInteractive();
		var canBeClosed = false;
		filtre.interactive.onPush = function (e) { if(canBeClosed) myremove(); };
		filtre.interactive.onRelease = function (e) { canBeClosed = true; };

		width = 400;
		height = 100;
		x = e.x;
		y = e.y;
		game.s2d.add(this, Const.LAYER_UI + 3);

		var font = Res.font._8bit.toFont();

		var s = 0.3;
		texte = new h2d.Text(font);
		texte.text = "Description du tips";
		texte.x = 10;
		texte.y = 10;
		texte.scale(s);
		texte.textColor = 0x000000;
		this.addChild(texte);
	}

	public function myremove() {
		filtre.remove();
		texte.remove();
		remove();
	}
}