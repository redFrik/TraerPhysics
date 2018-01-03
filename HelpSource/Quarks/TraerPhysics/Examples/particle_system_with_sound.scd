//example particle system with sound

(
s.latency= nil;
s.waitForBoot{

	var width= 640, height= 360, maxAge= 150;
	var win= Window("ps", Rect(100, 100, width, height), false, false);
	var usr= UserView(win, Rect(0, 0, width, height));
	var mouse, objects= List.new;

	SynthDef(\main, {|in= 0, out= 0|
		var src= In.ar(in, 2);
		src= src.tanh;
		src= FreeVerb2.ar(src[0], src[1], 0.2, 1);
		Out.ar(out, src);
	}).add;
	SynthDef(\part, {|out= 0, x= 0, y= 0, a= 1, d= 0|
		var freq= y.linexp(0, height, 2000, 50);
		var amp= a.linlin(0, maxAge, 0.1, 0).lagud(0, 0.1);
		var pan= x.linlin(0, width, -1, 1);
		var src= SinOscFB.ar(freq+d, (d*0.01).clip(0, 1), amp);
		DetectSilence.ar(src, doneAction:2);
		OffsetOut.ar(out, Pan2.ar(src, pan));
	}).add;
	s.sync;
	Synth(\main, [\in, 40, \out, 0]);

	~ps= TraerParticleSystem(0, 0, 0, 0.1);
	mouse= TraerParticle(1);
	mouse.position= TraerVector3D(width/2, height/2, 0);	//start in the middle
	usr.mouseDownAction= {|v, x, y|
		var newMousePos= TraerVector3D(x, y, 0);
		var delta= newMousePos.distanceTo(mouse.position);
		var diff= newMousePos.subtract(mouse.position);
		var p, s;
		p= ~ps.makeParticle(1, x, y, 0);	//create a particle at mouse location
		s= ~ps.makeSpring(p, mouse, diff.x*0.01, diff.y*0.01, delta);
		if(objects.size<500, {
			objects.add((
				particle: p,
				spring: s,
				synth: Synth(\part, [\out, 40, \x, x, \y, y]),
				delta: delta
			));
		});
		mouse.position.set(x, y, 0);  //update mouse position
	};
	usr.mouseMoveAction= usr.mouseDownAction;
	usr.drawFunc= {
		var dead= List.new;
		objects.do{|obj|
			if(obj.particle.age>maxAge, {
				obj.particle.dead= true;
				dead.add(obj);
			});
		};
		dead.do{|obj|
			~ps.removeSpring(obj[\spring]);
			~ps.removeParticle(obj[\particle]);
			obj[\synth].set(\gate, 0);
			objects.remove(obj);
		};
		~ps.tick;
		Pen.fillColor= Color.black;
		objects.do{|obj|
			var age= obj[\particle].age;
			var delta= obj[\delta];
			var size= age.linlin(0, maxAge, 100, 0)*obj[\particle].mass;
			var pos= obj[\particle].position;
			Pen.addOval(Rect.aboutPoint(Point(pos.x, pos.y), size, size));
			obj[\synth].set(\x, pos.x, \y, pos.y, \a, age, \d, delta);
		};
		Pen.stroke;
	};
	usr.animate= true;
	win.front;
	CmdPeriod.doOnce({win.close});
};
)

//click and drag
//press cmd+period to stop


//change the physics while running
~ps.setGravity(0, 1, 0);
~ps.setGravity(0, -3, 0);
~ps.setDrag(0.001)
~ps.setGravity(0.1, 0, 0);
