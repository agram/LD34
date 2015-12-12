import hxd.Res in Res;
import Const;

enum EntityKind {
	ENull;
	Button;
	Ui;
	Jauge;

	Hero;
	Parcelle;
	Ennemy;

	Fx;
	Piece;
}

class Entity {
	var game : Game;
	var battle :Battle;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var kind : EntityKind;
	public var anim : h2d.Anim;
	public var tiles : Array<h2d.Tile>;
	public var event : hxd.WaitEvent;

	public var dx:Float;
	public var dy:Float;

	public var vx:Float;
	public var vy:Float;
	var vz:Float;
	var z:Float;

	public var font:h2d.Font;

	public var speed: Float = 2.;

	public var startDx:Int = 0;
	public var startDy:Int = 0;

	var vDx:Float = 0.;
	var vDy:Float = 0.;
	var DDX:Float = 0.;
	var DDY:Float = 0.;
	var isMoving:Bool = false;
	var maxDx:Float;
	var maxDy:Float;
	var startX:Float;
	var startY:Float;

	public var life:Float;
	public var lifeMax:Float;
	public var dead:Bool = false;
	public var isRemoved:Bool = false;

	public var interactive:h2d.Interactive;

	public var beginTimer:Float;

	public function new( kind, x, y, ?tiles:Array<h2d.Tile> = null) {
		game = Game.inst;
		battle = game.battle;
		this.kind = kind;

		if(tiles == null) this.tiles = [];
		else this.tiles = tiles;

		anim = new h2d.Anim(tiles, 15);
		anim.filter = true;
		game.s2d.add(anim, Const.LAYER_GAME);

		this.x = x;
		this.y = y;

		for (t in anim.frames) {
			t.dx = -Std.int(t.width / 2);
			t.dy = -Std.int(t.height / 2);
		}

		if(anim.frames.length > 0){
			dx = -Std.int(anim.frames[0].width / 2);
			dy = -Std.int(anim.frames[0].height / 2);

			startDx = anim.frames[0].dx;
			startDy = anim.frames[0].dy;
		}

		event = new hxd.WaitEvent();

		game.entities.push(this);

		vx = 0;
		vy = 0;
		vz = 0;
		z = 0;
		frict = 1;

		font = Res.font._8bit.toFont();

		startX = this.x;
		startY = this.y;

		beginTimer = haxe.Timer.stamp();
	}

	public function getWidth() { return anim.frames[0].width; }
	public function getHeight() { return anim.frames[0].height; }

	public function setDx(v:Float, ?updateStart = false ) { for (f in anim.frames) f.dx = Std.int(v); if(updateStart) startDx = Std.int(v); }
	public function setDy(v:Float, ?updateStart = false) { for (f in anim.frames) f.dy = Std.int(v); if(updateStart) startDy = Std.int(v); }
	public function getDx() { return anim.frames[0].dx; }
	public function getDy() { return anim.frames[0].dy; }

	function init() { };

	var timerHold:Float;
	public function initInteractive(withTips:Bool = false) {
		if(tiles.length > 0) {
			interactive = new h2d.Interactive(getWidth(), getHeight(), anim);
			interactive.x -= getWidth() / 2;
			interactive.y -= getHeight() / 2;
			interactive.propagateEvents = false;

			if(withTips) {
				interactive.onPush = function (e) {
					timerHold = haxe.Timer.stamp();
				}
			}
			//interactive.backgroundColor = 0x80800080;
		}
	}

	inline function get_x() return anim.x;
	inline function get_y() return anim.y;
	inline function set_x(v) return anim.x = v;
	inline function set_y(v) return anim.y = v;

	var frict:Float;

	var texte:h2d.Text;

	var tips:h2d.ScaleGrid;
	public function update(dt:Float) {
		if(event != null) event.update(dt);

		if (timerHold > 0 && haxe.Timer.stamp() - timerHold > 1) {
			if(tips == null) tips = new ui.Tips(this);
		}
		else if (tips != null) {
			tips.remove();
			tips = null;
		}

		if (shaking > 0) {
			var p = Std.int(Math.sqrt(powShaking));
			for (f in anim.frames) {
				f.dx = startDx + (Std.random(3*p) - p);
				f.dy = startDy + (Std.random(3*p) - p);
			}
		}

		var tf = Math.pow(frict, dt);
		vx *= tf;
		vy *= tf;
		vz *= tf;
		x += vx * dt;
		y += vy * dt;
		z += vz * dt;

		if (isMoving && shaking <= 0) {
			DDX += vDx * dt;
			DDY += vDy * dt;
			setDx(startDx + DDX);
			setDy(startDy + DDY);
			if (DDX < -maxDx || DDX > maxDx) {
				DDX = DDX < -maxDx ? -maxDx : maxDx;
				vDx = (Math.random() / 2 + 0.10) * (vDx > 0 ? -1 : 1);
			}
			if (DDY < -maxDy || DDY > maxDy) {
				DDY = DDY < -maxDy ? -maxDy : maxDy;
				vDy = (Math.random() / 2 + 0.10) * (vDy > 0 ? -1 : 1);
			}
		}

	}

	public function remove() {
		if(texte != null) texte.remove();
		anim.remove();
		event = null;
		game.entities.remove(this);
		isRemoved = true;
		if (tips != null) tips.remove();
	}

	public function dispose() {
		event = null;
	}

	public var shaking:Int = 0;
	public var powShaking:Int = 0;

	public function shake(time, ?pow = 1., ?f:Void -> Void) {
		if (startDx == 0) startDx = getDx();
		if (startDy == 0) startDy = getDy();
		shaking++;
		powShaking += Std.int(pow);
		game.event.wait(time, function () {
			shaking--;
			powShaking -= Std.int(pow);
			setDx(startDx);
			setDy(startDy);
			if(f != null) f();
		});
	}

	static public function loadFX( name : String ) {
		 var res = [for (r in Res.load(name) ) r];
		 res.sort(function(r1, r2) return Reflect.compare(r1.name, r2.name));
		 return [for ( r in res ) r.toTile()];
	}

	public function affTexte(t:String, color:Int, textScale:Float = 1., yy:Float = null, asc = true ) {
		texte = new h2d.Text(font);
		texte.filters = [new h2d.filter.Glow(0x000000)];
		texte.filter = true;

		texte.text = t;
		texte.x = x - texte.textWidth * textScale / 2;
		yy = yy != null ? yy : y - 100;
		texte.y = yy;
		texte.scale(textScale);
		texte.textColor = color;
		game.s2d.add(texte, Const.LAYER_UI);

		game.event.waitUntil(function (dt) {
			if (asc) {
				texte.y -= dt * 4;
				texte.alpha -= dt / 60;
				if (yy - texte.y > 200) {
					texte.remove();
					return true;
				}
				return false;
			}
			else {
				texte.y += dt * 4;
				if (texte.y - yy > 200) {
					texte.remove();
					return true;
				}
				return false;
			}
		});
	}

	function changeAnim(tiles:Array<h2d.Tile>) {
		if(tiles == null) this.tiles = [];
		else this.tiles = tiles;

		for (t in tiles) {
			t.dx = -Std.int(t.width / 2);
			t.dy = -Std.int(t.height / 2);
		}
		startDx = tiles[0].dx;
		startDy = tiles[0].dy;
		anim.frames = tiles;
	}

	public function explode(?parts = 10) {
		var s = parts;
		for(i in 0...Std.int(getWidth()/s)+1) for(j in 0...Std.int(getHeight()/s)+1) {
			var e = new Entity(ENull, x + (getDx() + i * s) * anim.scaleX, y + (getDy() + j * s)*anim.scaleY, [anim.frames[0].sub(i * s, j * s, s, s)]);
			e.anim.scaleX = anim.scaleX;
			e.anim.scaleY = anim.scaleY;

			var a = new Twin(e, ALPHA, 30);
			a.setDest(0);
			a.onFinish(function () { e.remove(); } );
			var a = new Twin(e, TIME, Std.random(10) +10);
			a.setDest(e.x + Std.random(32) - 16, e.y + Std.random(32) - 16);
			a.onFinish(function () { e.remove(); } );
		}
	}

	public function moveSlowly(?amplitude = 1) {
		maxDx = 10. * amplitude;
		maxDy = 10. * amplitude;
		isMoving = true;
		vDx = Math.random() / 2 + 0.10;
		vDy = Math.random() / 2 + 0.10;
	}

	public function stopMoving() {
		isMoving = false;
		x = startX;
		y = startY;
		setDx(startDx);
		setDy(startDy);
	}

	public function fadeOut(?time:Float = 60, ?onEnd:Void -> Void) {
		game.event.waitUntil(function (dt) {
			if (anim.alpha <= 0) {
				if (onEnd != null) onEnd();
				remove();
				return true;
			}
			anim.alpha -= dt / time;
			return false;
		});
	}

	public function blink(nb, speed, ?onEnd:Void -> Void) {
		var c = 0.;
		var i = 1;
		game.event.waitUntil(function (dt) {
			c += dt * speed / 100 * i;
			anim.colorAdd = new h3d.Vector(c, c, c);
			if (c < 0) {
				nb--;
				i = 1;
				if (nb == 0) {
					anim.colorAdd = new h3d.Vector(0, 0, 0);
					if (onEnd != null) onEnd();
					return true;
				}
			}
			else if (c > 0.5) i = -1;
			return false;
		});
	}

	public function heal(val) {
		life += val;
		if (life <= 0) {
			life = 0;
			dead = true;
		}
		else if ( life > lifeMax) {
			life = lifeMax;
		}
		var e = new Entity(ENull, x, y, [h2d.Tile.fromColor(0xFFFFFF, 1, 1, 0)]);
		var t = new h2d.Text(font, this.anim);
		e.anim.addChild(t);
		t.text = val + '';
		t.textColor = 0x80BB20;
		t.scale(0.5);
		var a = new Twin(e, TIME, 60);
		a.setDest(e.x, e.y - 16);
		a.setFunction(function (b) { return Math.pow(b, 3); } );
		a.onFinish(function () {
			t.remove();
			e.remove();
		});
	}

	public function hurt(dmg:Float) {
		if (dead) return;

		shake(0.5, 10);
		life -= dmg;
		if (life <= 0) {
			life = 0;
			dead = true;
		}
		else if ( life > lifeMax) {
			life = lifeMax;
		}
		var e = new Entity(ENull, x, y - getWidth() / 4, [h2d.Tile.fromColor(0xFFFFFF, 1, 1, 0)]);
		game.s2d.add(e.anim, Const.LAYER_UI - 1);
		var t = new h2d.Text(font, this.anim);
		e.anim.addChild(t);
		t.text = dmg + '';
		t.x -= t.textWidth / 2 * 0.5;
		t.scale(0.5);
		var a = new Twin(e, TIME, 30);
		a.setDest(e.x, e.y - 32);
		a.onFinish(function () {
			t.remove();
			e.remove();
		});
	}

	public function vanish(?speed:Float = 1., ?onEnd:Void -> Void) {
		if (onEnd == null) onEnd = function () { };
		var c = 0.;
		game.event.waitUntil(function (dt) {
			c += dt * speed / 100;
			anim.colorAdd = new h3d.Vector( -c, -c, -c, 1 - c);
			if (c < 1) return false;
			onEnd();
			return true;
		});
	}
}