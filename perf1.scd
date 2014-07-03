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
