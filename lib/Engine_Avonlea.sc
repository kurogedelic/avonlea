// Engine_Avonlea.sc
Engine_Avonlea : CroneEngine {

  var synth;

  *new { ^super.new }

  // pamameter
  classvar <>controlNames = [
    \depthMorph,  // fog
    \glintMorph,  // shining
    \weightMorph, // weight
    \gain         // master gain
  ];

  controlNames { ^controlNames }

  start {
    // SynthDef is define
    SynthDef(\avonlea, {
      |depthMorph = 0.4, glintMorph = 0.3, weightMorph = 0.4, gain = 1.0|
      var base, shimmer, drone, env;
      var lfoDepth, lfoGlint, lfoWeight;
      var depth, glint, weight;
      var delayL, delayR, delayTimeL, delayTimeR;
      var blend;

      lfoDepth  = SinOsc.kr(0.003).range(-1, 1);
      lfoGlint  = LFNoise1.kr(0.2).range(-1, 1);
      lfoWeight = SinOsc.kr(0.01).range(-1, 1);

      depth  = 3000 + (lfoDepth  * depthMorph * 2500);
      glint  = 1.5   + (lfoGlint * glintMorph * 1.4);
      weight = 0.3   + (lfoWeight * weightMorph * 0.2);

      delayTimeL = SinOsc.kr(0.07).range(0.03, 0.08);
      delayTimeR = SinOsc.kr(0.09).range(0.04, 0.09);

      base = SinOsc.ar(100, 0, 0.3);

      shimmer = SinOsc.ar(
        5000 + LFNoise1.kr(0.1).range(-1000, 1000),
        0,
        EnvGen.kr(Env.perc(0.1, 1), Dust.kr(glint), 0.08)
      );

      blend = SinOsc.kr(0.003).range(0.3, 0.7);

      drone = XFade2.ar(
        LPF.ar(base + shimmer, depth),
        HPF.ar(base + shimmer, 4000),
        blend * 2 - 1
      );

      drone = CombL.ar(drone, 0.3, weight, 3) + drone;

      delayL = DelayL.ar(drone, 0.1, delayTimeL);
      delayR = DelayL.ar(drone, 0.1, delayTimeR);

      Out.ar(0, [delayL, delayR] * gain);
    }).add;
  }

  // pamrameter live
  set(n, x) {
    synth.set(n, x);
  }

  // play
  ready {
    synth = Synth.new(\avonlea, target: s);
  }

  // stop
  stop {
    synth.free;
  }
}
