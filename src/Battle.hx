import hxd.Key in K;
import hxd.Res in Res;

class Battle
{
	var game:Game;
	public var ui:ui.Ui;

	public var jardinier:Jardinier;
	public var ennemy:Ennemy;

	public var battleZone:h2d.Interactive;

	public var plants:Array<Data.Plants> = [];

	public var player:Player;

	public function new()
	{
		game = Game.inst;

		//var background = new h2d.Bitmap(h2d.Tile.fromColor(0xB6A06D, Const.W, Const.H));
		var background = new h2d.Bitmap(Res.gabarit_placeholder.toTile());
		game.s2d.add(background, Const.LAYER_BACKGROUND);

		battleZone = new h2d.Interactive(Const.W / 2, Const.H);
		battleZone.x = Const.W / 2;
		battleZone.enableRightButton = true;
		battleZone.propagateEvents = true;
		battleZone.onClick = function (e) { jardinier.attaque(); };
		game.s2d.add(battleZone, Const.LAYER_GAME +1);

		plants = [for (p in Data.plants.all) p];

		player = new Player();
	}

	public function update(dt) {
		if (ui.state != NEW) ui.update(dt);
	}

	public function newGame() {
		for (e in game.entities.copy()) e.remove();
		for (t in game.twins.copy()) t.remove();

		if(ui == null) ui = new ui.Ui();
		ui.init();

		jardinier = new Jardinier();
		ennemy = new Ennemy();

		player.restart();
	}

	public function remove() {
		battleZone.remove();
	}

	public function isBigBoss() {
		return player.nbMonstre == 4;
	}
}