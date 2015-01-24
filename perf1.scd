// (
// // Basis of good improv session
// Synth(\ctrBuzz, args:[
// 	\hardMix, 0.8,
// 	//	\impDur, 72,
// 	//	\impDur, 82.5,
// 	\impDur, 50,
// 	\dur, 40,
// 	\microDur, 1.1,
// 	\freqA, 49.9 ,
// 	\freqB, 50 - 0.6,
// 	\durN, 0.5,
// 	\octLow: -10,
// 	\octHigh: -8,
// 	\octSpeed: 0.6,
// 	\octChaos: 2,
// 	\klankDecay, 50,
// 	\combOct: 3.1,
// 	\envFix: 0
// ], target:r, addAction:'addBefore')
// )

State(\spce).push();
State(\spce).clear();
State(\spce).initActions.add({
	Require("spce");

	~lc.notNil.if({ ~lc.free });
	~qn.notNil.if({ ~qn.free });

	~resources.addAll([
		~lc = LCDevice(),
		~qn = QuNeo(),
		~bfBus = Bus.audio(s, 4),
		~synthGroup = Group(~reverb, \addBefore),
	]);

	~lc.knobs.do(_.ringStyle_(\fill));
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
		~durNMod =			CV(ControlSpec(-0.5, 0.5, 	default:0)),
		~microDurMod = 		CV(ControlSpec(-3, 3, 		default:0)),
		~hardMixMod = 		CV(ControlSpec(-0.5, 0.5,	default:0)),
		~octSpeedMod = 		CV(ControlSpec(-3, 3, 		default:0)),
		~klankDecayMod =	CV(ControlSpec(-100, 100, 	default:0)),
		~lowpassMod = 		CV(ControlSpec(-380, 1000, 	default:0)),
	];

	~globalBus = ~global.collectAs({
		|cv|
		var name, bus = Bus.control(s, 1);
		name = currentEnvironment.findKeyForValue(cv);
		[cv].connectToBus(s, bus.index);
		~resources.add(bus);
		name -> bus;
	}, Event);

	// Polled when creating / setting the Pdef - static for synth lifetime
	~instance = [
		~impDur = 	 		CV(ControlSpec(1/20, 200, 'exp', 	default:0)),
		~durN = 			CV(ControlSpec(0, 1, 				default:0.5)),
		~microDur =  		CV(ControlSpec(1/20, 20, 'exp', 	default:10)),
		~hardMix = 			CV(ControlSpec(0.0, 1.0, 			default:0.0)),
		~octSpeed = 		CV(ControlSpec(0.1, 10, 'exp', 		default:1)),
		~octChaos = 		CV(ControlSpec(0.1, 10, 'exp', 		default:1)),
		// ~impulseDur =	CV(ArrayedSpec([
		// 	ControlSpec(1/20, 20, 'exp'),
		// 	ControlSpec(20, 300, 'lin', step:10)
		// ], default:0)),
		//  ~dur = 			CV(ControlSpec(4, 32, 'exp', 		default:8)),
		// ~freqA =	 		CV(ControlSpec(-12, 12), default:-4),
		// ~freqB = 		CV(ControlSpec(-12, 12), default:-3),
		~octLow = 			CV(ControlSpec(-12, 12, step:1,		default:-4)),
		~octHigh = 			CV(ControlSpec(-12, 12, step:1,		default:-3)),
		~combOct =	 		CV(ControlSpec(-8, 8, step:1, 		default:-4)),
		~klankDecay = 		CV(ControlSpec(1, 400, 'exp', 		default:4)),
	];

	// Connect to Livid
	if (LCDevice.initialized) {
		~global.do({
			|cv, i|
			var knob, name = currentEnvironment.findKeyForValue(cv).asSymbol;
			knob = ~lc.knobRows.flatten[i];
			knob.cv_(cv);
			knob.button.default().buttonOnActions.add({
				~synthGroup.set(name, knob.cv.value);
			});
		});
		~instance[0..5].do({
			|cv, i|
			var knob, name = currentEnvironment.findKeyForValue(cv);
			knob = ~lc.knobRows.flatten[16 + i];
			knob.cv_(cv);
			knob.button.default().buttonOnActions.add({
				~synthGroup.set(name, knob.cv.value);
			});
		});
		~instance[6..].do({
			|cv, i|
			var knob, name = currentEnvironment.findKeyForValue(cv);
			knob = ~lc.knobRows.flatten[24 + i];
			knob.cv_(cv);
			knob.button.default().buttonOnActions.add({
				~synthGroup.set(name, knob.cv.value);
			});
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
			\instrument, 	\ctrBuzz,
			\group,			~synthGroup,
			\hardMix, 		~hardMix,
			\hardMixMod, 	~globalBus[\hardMixMod].asMap,
			\impDur, 		~impDur,
			\impDurMod, 	~globalBus[\impulseDurMod].asMap,
			\dur, 			4,
			\legato, 		8,
			\microDur, 		~microDur,
			\microDurMod, 	~globalBus[\microDurMod].asMap,
			\freqA, 		67.midicps,
			\freqB, 		65.midicps,
			\durN, 			~durN,
			\durNMod,		~globalBus[\durNMod].asMap,
			\octLow, 		~octLow,
			\octHigh, 		~octHigh,
			\octSpeed, 		~octSpeed,
			\octSpeedMod, 	~globalBus[\octSpeedMod].asMap,
			\octChaos, 		~octChaos,
			\klankDecay, 	~klankDecay,
			\combOct, 		~combOct,
			\envFix, 		1,
			\lowpassMod, 	~globalBus[\lowpassMod].asMap,
		)
	);

	Pdef(\cbPat1, Pbind(
		\impDur, Prand([2, 2, 2, 2, 2, 2, 6, 12], inf) * Pkey(\impDur),
		\microDur, Pseq([4, 4, 1.5, 0.5], inf) * Pkey(\microDur),
		\durN, Pseq([0.05, 0.9, 0.05], inf) + Pkey(\durN),
	));

	Pdef(\cbNotesDrop1, Pbind(
		\freqA, Scale.major.degreeToFreq(1, 98, 2).postln,
		\freqB, Scale.major.degreeToFreq(-3, 98, 2).postln,
	));

	Pdef(\cbNotesDrop1, Pbind(
		\freqA, Pseq([67, 74].midicps, inf),
		\freqB, Pseq([64, 60].midicps, inf),
	));


	~grid.front;
	// ServerView(s).front;
	// FullscreenPanel(\main).place(ServerView(s).view, 3, 0, 2, 1);
	// FullscreenPanel(\main).place(~grid.view, 0, 2, 2, 2);
	// FullscreenPanel(\main).front;
});

State(\spce).startActions.add({
	~lc.connect();
	~qn.connect();
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

	Pdef(\ctrBuzz,
		 Pdef(\cbNotesDrop1) <> Pdef(\ctrBuzzBase)
	).play;

	~panner = { B2UHJ.ar(*InFeedback.ar(5, 3)) }.play;
});

ServerView(s).front;



/*

State(\spce).doInit();
State(\spce).doStart();

(
	\instrument:	 \ctrBuzz,
	\hardMix: 		~hardMix,
	\hardMixMod: 	~globalBus[\hardMixMod].asMap,
	\impDur: 		~impulseDur,
	\impDurMod: 	~globalBus[\impulseDurMod].asMap,
	\dur:			8,
	\legato: 		8,
	\microDur: 		~microDur,
	\microDurMod: 	~globalBus[\microDurMod].asMap,
	\freqA: 		67.midicps,
	\freqB: 		63.midicps,
	\durN: 			~durN,
	\octLow: 		~octLow,
	\octHigh: 		~octHigh,
	\octSpeed: 		~octSpeed,
	\octSpeedMod: 	~globalBus[\octSpeedMod].asMap,
	\octChaos: 		~octChaos,
	\klankDecay: 	~klankDecay,
	\combOct: 		~combOct,
	\envFix: 		1,
	\lowpassMod:	~globalBus[\lowpassMod].asMap,
);


*/