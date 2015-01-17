(

// Basis of good improv session
Synth(\ctrBuzz, args:[
	\hardMix, 0.8,
//	\impDur, 72,
//	\impDur, 82.5,
	\impDur, 50,
	\dur, 40,
	\microDur, 1.1,
	\freqA, 49.9 ,
	\freqB, 50 - 0.6,
	\durN, 0.5,
	\octLow: -10,
	\octHigh: -8,
	\octSpeed: 0.6,
	\octChaos: 2,
	\klankDecay, 50,
	\combOct: 3.1,
	\envFix: 0
], target:r, addAction:'addBefore')
)

MIDIClient.init

State(\spce).clear()
State(\spce).initActions.put({
	Require("spce");

	~lc.notNil.if({ ~lc.free });
	~qn.notNil.if({ ~qn.free });

	~resources.addAll([
		~lc = LCDevice(),
		~lc.knobs.do(_.ringStyle_(\fill));
		~bfBus = Bus.audio(s, 4);
		~qn = QuNeo(),
	]);

	~reverb = Synth(\BFormatReverb, args: [
		\in_bus, 10,
		\mix, 0.65,
		\predelay, 0.15,
		\cutoff, 100,
		\t60low, 15.5,
		\t60high, 2.5,
		//	\diffusion, 1.1,
		\diffusionLR, 1,
		\diffusionFB, 1,
		\out_bus, 5,
	]);
	~qn.pads[14].default().noteOnActions.clear.add({
		|pad, cv|
		~synthGroup.set(\t_impReset, 1);
	});
	~qn.pads[15].default().noteOnActions.clear.add({
		|pad, cv|
		~synthGroup.set(\otrig, cv.value);
	});
	~qn.pads[15].default().noteOffActions.clear.add({
		|pad, cv|
		~synthGroup.set(\otrig, 0);
	});

	// Global to all running synths.
	~global = [
		~impulseDurMod = 	CV(ControlSpec(-5, 4, 		default:0)),
		~microDurMod = 		CV(ControlSpec(-3, 3, 		default:0)),
		~hardMixMod = 		CV(ControlSpec(-0.5, 0.5,	default:0)),
		~octSpeedMod = 		CV(ControlSpec(-3, 3, 		default:0)),
		~lowpassMod = 		CV(ControlSpec(-380, 1000, 	default:0)),
		~klankDecayMod =	CV(ControlSpec(-100, 100, 	default:0))
	];

	~globalBus = ~global.collectAs({
		|cv|
		var name, bus = Bus.control(s, 1);
		name = currentEnvironment.findKeyForValue(cv);
		[cv].connectToBus(s, bus.index);
		name -> bus;
	}, Event);

	// Polled when creating / setting the Pdef - static for synth lifetime
	~instance = [
		~hardmix = 			CV(ControlSpec(0.0, 1.0, 			default:0.0)),
//		~impulseDur = 	 	CV(ControlSpec(1/20, 200, 'exp', 	default:0)),
		~impulseDur =		CV(ArrayedSpec([
			ControlSpec(1/20, 20, 'exp'),
			ControlSpec(20, 300, 'lin', step:10)
		], default:0)),
		~dur = 				CV(ControlSpec(4, 32, 'exp', 		default:8)),
		~microDur =  		CV(ControlSpec(1/20, 20, 'exp', 	default: 10)),
		//~freqA =	 		CV(ControlSpec(-12, 12), default:-4),
		//~freqB = 			CV(ControlSpec(-12, 12), default:-3),
		~durN = 			CV(ControlSpec(-0.5, 0.5, 			default:0.5)),
		~octLow = 			CV(ControlSpec(-12, 12, step:1,		default:-4)),
		~octHigh = 			CV(ControlSpec(-12, 12, step:1,		default:-3)),
		~octSpeed = 		CV(ControlSpec(0.1, 10, 'exp', 		default:1)),
		~octChaos = 		CV(ControlSpec(0.1, 10, 'exp', 		default:1)),
		~klankDecay = 		CV(ControlSpec(1, 400, 'exp', 		default:4)),
		~combOct =	 		CV(ControlSpec(-8, 8, step:1, 		default:-4)),
	];

	// Connect to Livid
	if (LCDevice.initialized) {
		~global.do({
			|cv, i|
			var name = currentEnvironment.findKeyForValue(cv);
			l.knobRows.flatten[i].cv_(cv).connect();
		});
		~instance[0..4].do({
			|cv, i|
			var name = currentEnvironment.findKeyForValue(cv);
			l.knobRows.flatten[16 + i].cv_(cv).connect();
		});
		~instance[5..].do({
			|cv, i|
			var name = currentEnvironment.findKeyForValue(cv);
			l.knobRows.flatten[24 + i].cv_(cv).connect();
		});
	};

	~grid = CVGrid(\ctrBuzz).rows_(8).fromEnvir(
		*[
			~global.copy.extend(8, nil),
			nil ! 8,
			~instance[0..4].extend(8, nil),
			~instance[5..].extend(8, nil)
		].flatten
	);

	Pdef(\ctrBuzzBase,
		Pbind(
			\instrument, \ctrBuzz,
			\hardMix, 		~hardMix,
			\hardMixMod, 	~globalBus[\hardMixMod].asMap,
			\impDur, 		~impulseDur,
			\impDurMod, 	~globalBus[\impulseDurMod].asMap,
			\dur, 8,
			\legato, 4,
			\microDur, 		~microDur,
			\microDurMod, 	~globalBus[\microDurMod].asMap,
			\freqA, 67.midicps,
			\freqB, 63.midicps,
			\durN, 			~durN,
			\octLow, 		~octLow,
			\octHigh, 		~octHigh,
			\octSpeed, 		~octSpeed,
			\octSpeedMod, 	~globalBus[\octSpeedMod].asMap,
			\octChaos, 		~octChaos,
			\klankDecay, 	~klankDecay,
			\combOct, 		~combOct,
			\envFix, 1,
			\lowpassMod, 	~globalBus[\lowpassMod].asMap,
	));

	Pdef(\cbPat1, Pbind(
		\impDur, Prand([2, 2, 2, 2, 2, 2, 6, 12], inf) * Pkey(\impDur),
		\microDur, Pseq([4, 4, 1.5, 0.5], inf) * Pkey(\microDur),
		\durN, Pseq([0.05, 0.9, 0.05], inf) + Pkey(\durN),

	));

	Pdef(\cbNotesDrop1, Pbind(
		\freqA, Scale.minor.degreeToFreq(0, 98, 2).postln,
		\freqB, Scale.minor.degreeToFreq(-2, 98, 2).postln,
	));

	Pdef(\cbNotesDrop1, Pbind(
		\freqA, Scale.minor.degreeToFreq(0, 98, 2).postln,
		\freqB, Scale.minor.degreeToFreq(-4, 98, 2).postln,
	));


	~grid.front;
	ServerView(s).front;
	FullscreenPanel(\main).place(ServerView(s).view, 3, 0, 2, 1);
	FullscreenPanel(\main).place(~grid.view, 0, 2, 2, 2);
	FullscreenPanel(\main).front;
})

State(\spce).startActions.put({
	~panner = { B2UHJ.ar(*InFeedback.ar(5, 3)) }.play;
	~synthGroup = Group(~reverb, \addBefore);
});
~p = IdentityDictionary.newFrom(~pats);


CVGrid(\ctrBuzz,
	*(~mods ++ ~pats)
).front;

(
Pdef(\ctrBuzz,
	Pbind(
		\instrument, \ctrBuzz,
		\hardMix, ~p['hardmix'],
		\hardMixMod, ~modBus['hardmix +'].asMap,
		\impDur, Prand([2, 2, 2, 2, 2, 2, 6, 12], inf) * ~p['impulse dur *'], //*
		\impDurMod, ~modBus['impulse Dur +'].asMap,
		\dur, Prand([8] * 1, inf),
		\legato, Pseq([4], inf),
		\microDur, Pseq([4, 4, 1.5, 0.5], inf)  * ~p['micro dur *'],
		\microDurMod, ~modBus['microDur +'],
		\freqA, Scale.chromatic.degreeToFreq(0, 98, 2).postln,
		\freqB, Scale.chromatic.degreeToFreq(-2, 98, 2).postln,
		\durN, Pseq([0.05, 0.9, 0.05], inf) + ~p['durN +'], //*
		\durNMod, ~modBus['durN +'].asMap,
		\octLow, ~p['octLow'],
		\octHigh, ~p['octHigh'], //*
		\octSpeed, ~p['octSpeed'],
		\octSpeedMod, ~modBus['octave speed +'].asMap,
		\octChaos, ~p['octChaos'],
		\klankDecay, ~p['klank decay'], // *
		\combOct, ~p['compOct'],
		\envFix, 1,
		\lowpassMod, ~modBus['lowpass +'].asMap,

));
)

Pdef(\ctrBuzz).play

Pdef(\ctrBuzz,
	Pbind(
		\instrument, \ctrBuzz,
));

Pdef(\ctrBuzz).play;

)
Bus(\control, 100, 5).debugScope;



// nice
(
Synth(\ctrBuzz, args:[
	\hardMix, 0.1,
	\impDur, 0.5,
//	\impDur, 62.5,
//	\impDur, 50,
	\dur, 40,
	\microDur, 1.1,
	\freqA, 49.9 * 4/3,
	\freqB, 150 - 0.6 * 2/3,
	\durN, 0.5,
	\octLow: 2,
	\octHigh: 3,
	\octSpeed: 0.6,
	\klankDecay, 50,
	\combOct: -6,
	\envFix: 0
], target:r, addAction:'addBefore')
)

n = s.record("/Users/fsc/Desktop/SC_CLEAN/SPCE/2.wav");
s.stopRecording()
