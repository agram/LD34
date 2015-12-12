package ui;

import hxd.Res in Res;
import Const;

enum UiState {
	NEW;
	PLAYING;
	MENU;
}

class Ui
{
	var game:Game;
	var battle:Battle;

	public var state:UiState;

	public var plants:Array<Button> = [];
	public var money:h2d.Text;
	public var rank:h2d.Text;

	public var minimap:Minimap;

	public function new()
	{
		game = Game.inst;
		battle = game.battle;

		state = NEW;

		var font = Res.font._8bit.toFont();
		money = new h2d.Text(font);
		game.s2d.add(money, Const.LAYER_UI);
		money.x = 10;
		money.y = 10;

		rank = new h2d.Text(font);
		game.s2d.add(rank, Const.LAYER_UI);
		rank.x = Const.W / 5 * 3;
		rank.y = 10;

		minimap = new Minimap();
	}

	var cross:Entity;
	public function init() {
		remove();
		//var b = new Entity(Ui, Const.W / 2, Const.H / 2, [h2d.Tile.fromColor(0x000000, 10, Const.H)]);

		for (i in 0...battle.plants.length) {
			var p = game.battle.plants[i];
			var b = new Button(0, Const.H / 10 * 9, [h2d.Tile.fromColor(0x0000FF, 16, 16)]);
			b.x = b.getWidth() * 1.5 * i + 8;
			b.setTitle(p.name, 0.7);
			plants.push(b);
		}

		state = PLAYING;
	}

	function getSelectedPlant() {
		for (p in plants) if (p.selected) return p;
		return null;
	}

	public function update(dt:Float) {
		money.text = battle.player.money + ' thunes';
		rank.text = 'Rank ' + battle.player.rank;
		rank.x = Const.W / 5 * 3 - rank.textWidth / 2;
	}

	public function remove() {
	}

}

class Minimap extends Entity {

	var monstres:Array<Entity> = [];

	public function new() {
		super(Ui, 0 , 16, [h2d.Tile.fromColor(0xB04000, 128, 16)]);
		x = Const.W - getWidth() / 2 - 16;

		for (i in 0...5) {
			var t = i == 4 ? h2d.Tile.fromColor(0x0000FF, 16, 16) : h2d.Tile.fromColor(0x0000FF, 8, 8);
			var m = new Entity(ENull, getWidth() / 6 * (i + 1) - getWidth()/2 + (i==4?0:-8), 0, [t]);
			anim.addChild(m.anim);
			monstres.push(m);
		}
	}

	var cross:Array<Entity> = [];

	override function update(dt) {
		if (battle.player.nbMonstre == 0) for (m in monstres) m.anim.visible = true;

		for (i in 0...battle.player.nbMonstre) {
			if (monstres[i].anim.visible) {
				var e = new Entity(Fx, x + monstres[i].x, y + monstres[i].y, monstres[i].anim.frames);
				e.explode(2);
				e.remove();
				monstres[i].anim.visible = false;
			}
		}
	}

}