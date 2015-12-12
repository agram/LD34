import hxd.Key in K;
import Data;

class Game extends hxd.App {

	public static var inst : Game;
	public var event : hxd.WaitEvent;

	public var battle:Battle;

	public var entities:Array<Entity>;
	public var twins:Array<Twin>;

	public var pause:Bool = false;
	public var finish:Bool = false;

	override function init() {
		event = new hxd.WaitEvent();
		s2d.setFixedSize(Const.W, Const.H);

		entities = [];
		twins = [];

		battle = new Battle();
		battle.newGame();
	}

	var slow = false;
	var rapide = false;
	override function update(dt:Float) {
		if ( K.isPressed("N".code) ) { finish = false; battle.newGame();}
		if ( K.isPressed("R".code) ) { slow = !slow; rapide = false; }
		if ( K.isPressed("T".code) ) { rapide = !rapide; slow = false; }
		if ( K.isPressed("P".code) ) { pause = !pause; }

		if (finish || pause) return;

		if (slow) dt /= 10;
		if (rapide) dt *= 4;

		super.update(dt);

		battle.update(dt);
		event.update(dt);
		for (e in entities.copy() ) e.update(dt);
		for (t in twins.copy() ) t.update(dt);

	}

	public function setPause() {
		pause = true;
		var oldE = entities;
		var oldT = twins;
		var speeds = [];

		for ( e in entities ) {
			var old = e.anim.speed;
			e.anim.speed = 0;
			speeds.push( { e:e, oldSpeed:old } );
		}

		var oldEvents = event;
		entities = [];
		twins = [];
		event = new hxd.WaitEvent();

		return function() {
			entities = oldE;
			twins = oldT;
			event = oldEvents;
			for (s in speeds) s.e.anim.speed = s.oldSpeed;
			pause = false;
		};
	}

	public function dispose() {
		s2d.dispose();
		entities = null;
		s2d = null;
		event = null;
	}

	static function main() {
		#if mobile
		hxd.Res.initPak();
		#else
		hxd.Res.initLocal();
		#end
		Data.load(hxd.Res.data.entry.getBytes().toString());
		inst = new Game();
	}
}