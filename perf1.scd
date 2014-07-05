(
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

(
l = LCDevice();

~mods = [
	'hardmix +': CV(ControlSpec(-0.5, 0.5, default:0)),
	'durN +': CV(ControlSpec(-0.5, 0.5, default:0)),
	'microDur +': CV(ControlSpec(-3, 3, default:0)),
	'impulse Dur +': CV(ControlSpec(-5, 3, default:0)),
	'octave speed +': CV(ControlSpec(-3, 3, default:0)),
	'lowpass +': CV(ControlSpec(-380, 1000, default:0)),
];
~modBus = ~mods.clump(2).collectAs({
	|item|
	var bus = Bus.control(s, 1);
	[item[1]].connectToBus(s, bus.index);

	item[0] -> bus;
}, Event);

~pats = [
	'hardmix': CV(ControlSpec(0, 1, default:0.0)),
	'impulse dur *': CV(ControlSpec(1/20, 200, 'exp')),
	'dur': CV(ControlSpec(4, 32, 'exp', default:8)),
	'micro dur *': CV(ControlSpec(1/10, 10, 'exp', default: 10)),
	// 'freqA': CV(ControlSpec(-12, 12), default:-4),
	// 'freqB': CV(ControlSpec(-12, 12), default:-3),
	'durN +': CV(ControlSpec(-0.5, 0.5, default:0.5)),
	'octLow': CV(ControlSpec(-12, 12, default:-4)),
	'octHigh': CV(ControlSpec(-12, 12, default:-3)),
	'octSpeed': CV(ControlSpec(0.1, 10, 'exp', default:1)),
	'octChaos': CV(ControlSpec(0.1, 10, 'exp', default:1)),
	'klank decay': CV(ControlSpec(1, 300, 'exp', default:4)),
	'comb oct': CV(ControlSpec(-8, 8, default:-4)),
];

~mods.pairsDo({
	|name, cv, i|
	l.knobRows.flatten[i / 2].cv_(cv).connect();
});
~pats.pairsDo({
	|name, cv, i|
	l.knobRows.flatten[16 + (i / 2)].cv_(cv).connect();
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
