class Button extends Entity
{

	var action:Void->Void;
	var title:h2d.Text;
	public var selected:Bool = false;

	public function new(x, y, t:Array<h2d.Tile>)
	{
		super(Button, x, y, t);
		action = function () { };
		initInteractive();
		interactive.onClick = function (e) { if (tips != null) return; select();  action(); };
	}

	override public function update(dt:Float)
	{
		super.update(dt);

		if (selected) {
			anim.colorAdd = new h3d.Vector(0.5, 0.5, 0.);
			anim.scaleX = anim.scaleY = 1.3;
		}
		else {
			anim.colorAdd = new h3d.Vector(0, 0, 0);
			anim.scaleX = anim.scaleY = 1.;
		}
	}

	public function setAction(f:Void -> Void) { action = f; }

	public function setTitle(texte:String, ?scale:Float = 1) {
		if (title == null) title = new h2d.Text(font, this.anim);
		title.text = texte;
		title.x = -title.textWidth / 4 * scale;
		title.y = -title.textHeight / 4 * scale;
		title.scaleX = title.scaleY = 0.5;
		title.scale(scale);
	}

	public function setColorText(c) {
		title.textColor = c;
	}

	public function select(?b:Bool) {
		if (selected) selected = false;
		else {

			for (b in battle.ui.plants) b.selected = false;
			selected = true;
		}
	}

	public function doAction() {
		action();
	}

	override public function remove()
	{
		super.remove();
		if (title != null) title.remove();
		interactive.remove();
	}

	public function setActive(b:Bool) {
		if (b) {
			interactive.visible = true;
			anim.colorAdd = new h3d.Vector(0, 0, 0, 1);
			if(title != null) title.colorAdd = new h3d.Vector(0, 0, 0, 0);
		}
		else {
			interactive.visible = false;
			anim.colorAdd = new h3d.Vector(0.5, 0.5, 0.5, 0.5);
			if(title != null) title.colorAdd = new h3d.Vector(0.5, 0.5, 0.5, 0.5);
		}
	}
}