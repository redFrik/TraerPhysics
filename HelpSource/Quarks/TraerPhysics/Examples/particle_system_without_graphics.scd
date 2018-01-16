(
var spring, num;
s.waitForBoot{
	SynthDef(\part, {|out= 40, x= 0, y= 0, z= 0|
		var pan= x;
		var freq= y.linexp(-1, 1, 50, 2000);
		var amp= z*0.3;
		var src= SinOscFB.ar(freq, z.abs.lag(1), amp);
		Out.ar(out, Pan2.ar(src, pan));
	}, #[\ir, 0.001, 0.001, 0.001]).add;
	SynthDef(\main, {|in= 40, out= 0|
		var src= In.ar(in, 2);
		Out.ar(out, src.tanh);
	}).add;
	s.sync;
	Synth(\main);

	num= 5;	//number of particles
	~ps= TraerParticleSystem(0, 0, 0.01, 0.005);	//system with gravity and drag
	spring= ~ps.makeParticle(1, 0, 0, 0);	//spring that will be moved around with pbind
	spring.makeFixed;

	~springs= List.new;
	~particles= {|i|
		var p= ~ps.makeParticle(1, 0, 0, 0);
		~springs.add(~ps.makeSpring(p, spring, 0.1, 0.1, 0.01));	//connect the particle to the spring
		p;
	}.dup(num);
	~synths= ~particles.collect{|p|
		Synth(\part, [\x, p.position.x, \y, p.position.y, \z, p.position.z]);
	};
	s.sync;
	Routine.run({
		inf.do{
			~ps.tick;
			~particles.do{|p, i|
				~synths[i].set(\x, p.position.x, \y, p.position.y, \z, p.position.z);
			};
			0.001.wait;	//fast update rate (1000fps)
		};
	});
	Event.addEventType(\spring, {
		spring.position.x= ~x;
		spring.position.y= ~y;
		spring.position.z= ~z;
	});
	Pdef(\mel, Pbind(	//this moves the spring around
		\type, \spring,
		\dur, 1,
		\x, Pseq([0, -1, 1], inf),
		\y, Pseq([0.5, -0.5], inf),
		\z, Pseq([0], inf)
	)).play;
};
)

//change all particles
~particles.do{|p| p.mass= 2};  //change all particles' mass
~particles.do{|p| p.mass= 0.2};  //change all particles' mass
~particles.do{|p| p.mass= 1};  //change all particles' mass

~springs.do{|s| s.damping= 0.01};
~springs.do{|s| s.damping= 0.05};
~springs.do{|s| s.restLength= 0.2};
~springs.do{|s| s.restLength= 0.02};

//change the movement of the spring
(
Pdef(\mel, Pbind(
	\type, \spring,
	\dur, 0.5,
	\x, Pseq([0, -1, 1, 0.5, 0, 0.5, 0], inf),
	\y, Pseq([0.5, 0.4, 0.3, 0.2, 0.1, -1], inf),
	\z, Pseq([0.25, -0.25], inf)
)).play;
)

(
Pdef(\mel, Pbind(
	\type, \spring,
	\dur, 0.25,
	\x, Pseg([-1, 1], 11, 'lin', inf),
	\y, Pseg([-1, 1], 9, 'lin', inf),
	\z, Pseg([-1, 1], 5, 'lin', inf)
)).play;
)

(
Pdef(\mel, Pbind(
	\type, \spring,
	\dur, 0.25,
	\x, Pseq([-0.1, 0.1], inf),
	\y, Pseq([60, 65, 63, 56, 80], inf).midicps.explin(50, 2000, -1, 1),
	\z, Pseq([Pn(0.25, 5), Pn(0, 3)], inf)
)).play;
)

(
Pdef(\mel, Pbind(
	\type, \spring,
	\dur, 0.5,
	\x, Pseq([0, -1, 1, 0.5, 0, 0.5, 0], inf),
	\y, Pseq([0.5, 0.4, 0.3, 0.2, 0.1, -1], inf),
	\z, Pseq([0.25, -0.25], inf)
)).play;
)

//change the physics while running
~ps.setGravity(0, -0.1, 0.1);
~ps.setGravity(0, 0.5, 0.1);
~ps.setGravity(0.1, 0.01, 0.1);
~ps.setDrag(0.1)
~ps.setDrag(0.01)

//etc
