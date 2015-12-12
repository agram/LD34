enum ModeTwin {
	TIME;
	SPEED;
	SCALE;
	ALPHA;
}

class Twin
{
	var game:Game;
	public var e:Entity;
	var x:Float;
	var y:Float;
	var startScale:Float;
	var startAlpha:Float;
	var destX:Float;
	var destY:Float;
	var time:Int;
	var speed:Float;
	var scaleDest:Float;
	var alphaDest:Float;
	var compteur:Float;
	var f:Float -> Float;
	var fEachFrame:Void -> Void;
	var fFinish:Void -> Void;
	var mode:ModeTwin;
	var vx:Float;
	var vy:Float;
	var frict:Float;

	var hJump:Float;

	var diffX: Bool;
	var diffY: Bool;
	var diffScale: Bool;
	var diffAlpha: Bool;

	var beginScale:Float = 0;
	var endScale:Float = 0;
	var willScale = false;
	var facteurXScale:Float = 1;
	var facteurYScale:Float = 1;

	public function new( e:Entity, mode:ModeTwin, value)
	{
		game = Game.inst;
		this.mode = mode;
		this.e = e;
		this.x = e.x;
		this.y = e.y;
		this.startScale = e.anim.scaleX;
		this.startAlpha = e.anim.alpha;
		time = 0;
		speed = 0;
		switch(mode) {
			case TIME :
				time = value;
				hJump = 0;
			case SPEED :
				speed = value;
				vx = this.destX - x;
				vy = this.destY - y ;
				var d = Math.sqrt(Math.pow(vx, 2) + Math.pow(vy, 2));
				var c = speed / d;
				vx *= c;
				vy *= c;
			case SCALE, ALPHA:
				time = value;
		}

		frict = 1;

		this.f = function(e) { return e; };

		fFinish = function() { };
		fEachFrame = function() { };

		compteur = 0;

		for ( t in game.twins ) if (t == this) { game.twins.remove(t); break; }


		game.twins.push(this);
	}

	var timeElapse = 0.;
	public function update(dt:Float) {
		switch (mode) {
		case TIME :
			var coef = f(compteur / time);

			e.x = x + (destX - x) * coef;
			e.y = y + (destY - y) * coef;
			e.y -= Math.sin(coef * Math.PI) * hJump;

			e.x += f(dt);
			e.y += f(dt);
			compteur += dt;
			if (compteur > time || testFin() ) {
				e.x = destX;
				e.y = destY;
				kill();
			}

			if (willScale) {
				e.anim.scaleX = facteurXScale * (beginScale + (endScale - beginScale) * coef);
				e.anim.scaleY = facteurYScale * (beginScale + (endScale - beginScale) * coef);
			}

		case SPEED :
			timeElapse -= dt;
			var tf = Math.pow(frict, dt);
			vx *= tf;
			e.x += f(vx * dt);
			vy *= tf;
			e.y += f(vy * dt);

			if (testFin()) {
				e.x = destX;
				e.y = destY;
				kill();
			}
		case SCALE :
			var coef = f(compteur / time);
			e.anim.scaleX = e.anim.scaleY = startScale + (scaleDest - startScale) * coef;
			compteur += dt;
			if (compteur > time || testFin() ) {
				e.anim.scaleX = scaleDest;
				e.anim.scaleY = scaleDest;
				kill();
			}

		case ALPHA :
			var coef = f(compteur / time);
			e.anim.alpha = startAlpha + (alphaDest - startAlpha) * coef;
			compteur += dt;
			if (compteur > time || testFin() ) {
				e.anim.alpha = alphaDest;
				kill();
			}

		}

		fEachFrame();
	}

	function testFin() {
		switch(mode) {
			case TIME:
				var tempdiffX = (e.x - destX) > 0;
				var tempdiffY = (e.y - destY) > 0;
				return diffX != tempdiffX && diffY != tempdiffY;
			case SPEED:
				return timeElapse <= 0;
			case SCALE:
				return (diffScale && e.anim.scaleX > scaleDest) || (!diffScale && e.anim.scaleX < scaleDest);
			case ALPHA:
				return (diffAlpha && e.anim.alpha > alphaDest) || (!diffAlpha && e.anim.alpha < alphaDest);
		}
	}

	public function setDest(?dest1:Float, ?dest2:Float) {
		switch(mode) {
			case TIME:
				destX = dest1;
				destY = dest2;
				diffX = (e.x - destX) > 0;
				diffY = (e.y - destY) > 0;
			case SPEED:
			case SCALE:
				scaleDest = dest1;
				diffScale = e.anim.scaleX < scaleDest;
			case ALPHA:
				alphaDest = dest1;
				diffAlpha = e.anim.alpha < alphaDest;
		}
	}

	public function sethJump(hJump:Float) {
		if (mode != TIME) return ;
		this.hJump = hJump;
	}

	public function setFunction(f:Float -> Float) { this.f = f; }

	public function onFinish (f:Void -> Void) { this.fFinish = f;  }
	public function onEachEtape (f:Void -> Void) { this.fEachFrame = f; }

	public function kill() {
		game.twins.remove(this);
		fFinish();
	}

	public function interrupt() {
		game.twins.remove(this);
	}

	public function setScale(beginScale:Float, endScale:Float, ?facteurX:Float = 1, ?facteurY:Float = 1 ) {
		this.beginScale = beginScale;
		this.endScale = endScale;
		willScale = true;
		this.facteurXScale = facteurX;
		this.facteurYScale = facteurY;
	}

	public function remove() {
		game.twins.remove(this);
	}
}