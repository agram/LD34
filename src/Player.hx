import hxd.Key in K;
import Data;

class Player
{
	public var money:Float;
	public var rank:Int;
	public var monster:Int;
	public var nbHarvest:Int;
	public var nbMonstre:Int;

	public var jardin:Array<Parcelle>;

	public var pieces:Array<Entity>;

	public function new()
	{
		restart();
	}

	public function restart() {
		money = 0;
		rank = 0;
		nbHarvest = 0;
		nbMonstre = 0;
	}

	public function addMoney(m) {
		money += m;
	}

	public function addRank() {
		nbMonstre++;
		if (nbMonstre > 4) {
			Game.inst.event.wait(0.5, function () {
				rank++;
				nbMonstre = 0;
			});
		}
	}

}

class Parcelle extends Entity {

	public function new () {
		super(Parcelle, 0, 0, [h2d.Tile.fromColor(0x803000, 100, 100)]);
	}

}