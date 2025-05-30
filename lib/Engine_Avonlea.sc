// Engine_Avonlea.sc
// SuperCollider engine for the Avonlea script
// Ambient sound engine with moon phase, wind, and lullaby elements

Engine_Avonlea : CroneEngine {
  var <synth;
  
  // Default parameter values - centralized
  var defaultDepth = 0.5;
  var defaultGlint = 0.4;
  var defaultWind = 0.3;
  var defaultGain = 0.9;
  var defaultAtmosphere = 1.0;
  
  // Extended parameters with safe defaults
  var defaultDetune = 0.0;
  var defaultStereoWidth = 1.0;
  var defaultHarmonics = 0.5;
  var defaultTempoMult = 1.0;
  var defaultReverb = 0.3;
  var defaultChorus = 0.2;
  var defaultSaturation = 0.0;
  var defaultShimmerRate = 1.0;
  var defaultLowCut = 0.0;
  var defaultHighCut = 1.0;
  var defaultDelayFeedback = 0.4;
  var defaultDelayMix = 0.5;
  var defaultLfoDepth = 1.0;
  var defaultLfoRate = 1.0;
  var defaultMoodShift = 0.5;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Define the synth
    SynthDef(\avonlea, {
      |out=0, depth=0.5, glint=0.4, wind=0.3, gain=0.9, atmosphere=1.0,
       detune=0.0, stereoWidth=1.0, harmonics=0.5, tempoMult=1.0, 
       reverb=0.3, chorus=0.2, saturation=0.0, shimmerRate=1.0,
       lowCut=0.0, highCut=1.0, delayFeedback=0.4, delayMix=0.5,
       lfoDepth=1.0, lfoRate=1.0, moodShift=0.5|
      
      // Determine other parameters from Norns main parameters
      var depthMorph, glintMorph, weightMorph, moonPhase, moonAltitude, windSpeed, lullaby;
      var base, shimmer, drone, melody;
      var lfoDepthSig, lfoGlintSig, lfoWeightSig;
      var actualDepth, actualGlint, weight;
      var delayL, delayR, delayTimeL, delayTimeR;
      var blend;
      var shimmerBrightness, shimmerFreq, shimmerHigh, shimmerLow;
      var windNoise, windFiltered, windModulation;
      var pulseRate, melodyTone;
      var drySignal, wetSignal, mixedSignal;
      
      // Generate all parameters from Norns' three knobs
      // depth parameter (0.0~1.0) - Sound warmth and depth
      depthMorph = depth.linlin(0, 1, 0.1, 1.0); // Expanded filter depth range
      moonPhase = depth.linlin(0, 1, 0.3, 0.8);   // Moon phase
      lullaby = depth.linlin(0, 1, 0.3, 0.7);     // Lullaby element
      
      // glint parameter (0.0~1.0) - Sparkle and spatial feel
      glintMorph = glint.linlin(0, 1, 0.1, 0.6);     // Amount of sparkle
      weightMorph = glint.linlin(0, 1, 0.3, 0.7);     // Spatial feel
      moonAltitude = glint.linlin(0, 1, 20, 70);      // Moon altitude
      
      // wind parameter (0.0~1.0) - Wind sound axis and movement
      windSpeed = wind.linlin(0, 1, 0.05, 0.8);       // Wind speed
      // Suppress lullaby when wind is stronger
      lullaby = lullaby * (1 - (wind * 0.5));
      
      // Modulation oscillators made more gentle and organic - now controllable
      lfoDepthSig  = SinOsc.kr(0.0023 * lfoRate).range(-1, 1) * lfoDepth;
      lfoGlintSig  = LFNoise2.kr(0.12 * lfoRate).range(-1, 1) * lfoDepth; // Smoother modulation
      lfoWeightSig = SinOsc.kr(0.007 * lfoRate).range(-1, 1) * lfoDepth;
      
      actualDepth  = 200 + (depthMorph * 8000) + (lfoDepthSig * depthMorph * 2000); // Much wider frequency range: 200Hz to 8200Hz
      weight = 0.4 + (lfoWeightSig * weightMorph * 0.15); // Delay balance adjustment
      
      // More organic delay times
      delayTimeL = SinOsc.kr(0.033).range(0.05, 0.085);
      delayTimeR = SinOsc.kr(0.021).range(0.08, 0.13); // Golden ratio relationship
      
      // Soft fundamental sound with multiple harmonics - now with detune and harmonics control
      base = 
        SinOsc.ar(100 * (1 + (detune * 0.01)), 0, 0.2) +          // Fundamental with detune
        SinOsc.ar(150 * (1 + (detune * 0.015)), 0, 0.1 * harmonics) +           // 3/2 relationship (perfect 5th)
        SinOsc.ar(200 * (1 + (detune * 0.008)), 0, 0.08 * harmonics) +          // 2/1 relationship (octave)
        SinOsc.ar(300 * (1 + (detune * 0.005)), 0, 0.04 * harmonics);           // 3/1 relationship (octave + 5th)
      
      // Sound design based on moon phases
      shimmerBrightness = moonPhase.linlin(0, 1, 0.3, 0.9); // Keep some brightness even at new moon
      shimmerFreq = moonPhase.linlin(0, 1, 300, 900);       // Lower frequency range
      
      // Timbre changes based on moon altitude
      shimmerHigh = moonAltitude.linlin(0, 90, 0.3, 0.7);  // Higher moon = more highs
      shimmerLow = moonAltitude.linlin(0, 90, 0.7, 0.4);   // Lower moon = more lows
      
      // Combination of glintMorph and moon phase - now with shimmer rate control
      actualGlint = 0.7 + (shimmerBrightness * 1.2) + (lfoGlintSig * glintMorph * 0.5) * shimmerRate;
      
      // Rich texture shimmer with multiple frequency layers
      shimmer = 
        // Low frequency shimmer
        SinOsc.ar(
          shimmerFreq * (1 + LFNoise1.kr(0.05).range(-0.01, 0.01)),
          0,
          EnvGen.kr(Env.perc(0.3, 1.5), Dust.kr(actualGlint * shimmerBrightness * 0.5), 0.1 * shimmerBrightness * shimmerLow)
        ) +
        // Mid frequency shimmer
        SinOsc.ar(
          shimmerFreq * 1.5 * (1 + LFNoise1.kr(0.06).range(-0.01, 0.01)),
          0,
          EnvGen.kr(Env.perc(0.2, 1.2), Dust.kr(actualGlint * shimmerBrightness * 0.4), 0.07 * shimmerBrightness)
        ) +
        // High frequency shimmer (more delicate)
        SinOsc.ar(
          shimmerFreq * 2 * (1 + LFNoise1.kr(0.08).range(-0.01, 0.01)),
          0,
          EnvGen.kr(Env.perc(0.1, 0.8), Dust.kr(actualGlint * shimmerBrightness * 0.3), 0.04 * shimmerBrightness * shimmerHigh)
        );
      
      // Wind elements made more organic
      windModulation = LFNoise2.kr(0.08 + (windSpeed * 0.1)); // Smoother modulation
      windNoise = PinkNoise.ar(windSpeed * 1.5); // Much louder for testing
      
      // Create wind sound in multiple frequency bands
      windFiltered = 
        // Low frequencies - warm presence
        LPF.ar(windNoise, 200 + (windSpeed * 100)) * 1.0 +
        // Mid frequencies - wind whispers
        BPF.ar(
          windNoise, 
          SinOsc.kr(0.03 + (windSpeed * 0.05)).range(400, 800),
          0.4
        ) * 1.0 +
        // High frequencies - delicate air texture
        HPF.ar(
          windNoise, 
          2000 + (windSpeed * 1000),
          0.1
        ) * windSpeed * 1.0;
      
      // Generate gentle lullaby-like melody - now with tempo control and mood shift
      pulseRate = 0.85 * tempoMult; // Stable tempo like a heartbeat, now controllable
      melodyTone = lullaby * 0.25 * moodShift.linlin(0, 1, 0.5, 1.5); // Lullaby volume adjustment with mood
      
      melody = [
        // Gentle 3-note lullaby melody
        SinOsc.ar(300, 0, 
          EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25), melodyTone)
        ),
        SinOsc.ar(400, 0, 
          EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25, 0.33), melodyTone * 0.8)
        ),
        SinOsc.ar(350, 0, 
          EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25, 0.67), melodyTone * 0.9)
        ),
        // Low humming sound - provides stability
        SinOsc.ar(150, 0, 
          LFTri.kr(pulseRate * 0.125).range(0, 0.1) * lullaby
        ),
        // Very quiet stable low frequency waves
        SinOsc.ar(75, 0, 
          LFTri.kr(pulseRate * 0.0625).range(0.05, 0.12) * lullaby
        )
      ].sum;
      
      // Add stable ambient elements - reassuring components with minimal fluctuation
      melody = melody + (
        LPF.ar(
          SinOsc.ar([250, 300, 350], 0, 0.04 * lullaby).sum * 
          LFTri.kr(0.1).range(0.6, 1.0),
          400
        )
      );
    
      // Sound blending - now influenced by depth parameter
      blend = SinOsc.kr(0.0025).range(0.3, 0.6) + (depth * 0.3); // Depth affects blend position
      
      // Crossfader adjustment (more toward low frequencies)
      drone = XFade2.ar(
        LPF.ar(base + shimmer, actualDepth),
        HPF.ar(base + shimmer, 4000) * 0.7 * (1 - (depth * 0.5)), // Depth reduces highs more
        blend * 1.6 - 0.8
      );
      
      // Balanced mix of main sound, wind sound, and lullaby
      drone = drone + (windFiltered * 2.0) + melody;
      
      // Complex spatial feel with multiple feedback paths
      drone = 
        // Main delay (slightly relaxed)
        (CombL.ar(drone, 0.5, weight, 4) * 0.6) +
        // Short echo (dimensional effect)
        (CombL.ar(drone, 0.2, weight * 0.5, 1.5) * 0.3) +
        // Original signal
        (drone * 0.8);
      
      // Final EQ to increase softness - now more responsive to depth
      drone = 
        // Low-mid frequency boost - dramatically affected by depth
        LPF.ar(drone, 600) * (1.2 + (depth * 0.8)) +
        // Slight mid frequency reduction (reduce aggressiveness)
        BPF.ar(drone, 1200, 1) * (0.8 - (depth * 0.3)) +
        // High frequency transparency (preserve wind texture) - reduced with depth
        HPF.ar(drone, 3000) * (0.8 - (depth * 0.4));
      
      // Final delay and panning with feedback control
      delayL = DelayL.ar(drone + (LocalIn.ar(2)[0] * delayFeedback), 0.15, delayTimeL);
      delayR = DelayL.ar(drone + (LocalIn.ar(2)[1] * delayFeedback), 0.15, delayTimeR);
      
      // Send delay feedback
      LocalOut.ar([delayL, delayR]);
      
      // Apply atmosphere (weather) filtering
      delayL = LPF.ar(delayL, 8000 * atmosphere); // High frequency rolloff in bad weather
      delayR = LPF.ar(delayR, 8000 * atmosphere);
      
      // Add new processing effects
      // Chorus effect
      delayL = delayL + (DelayL.ar(delayL, 0.03, SinOsc.kr(0.5, 0).range(0.01, 0.02)) * chorus);
      delayR = delayR + (DelayL.ar(delayR, 0.03, SinOsc.kr(0.6, pi/2).range(0.01, 0.02)) * chorus);
      
      // Soft saturation
      delayL = (delayL * (1 + saturation)).tanh;
      delayR = (delayR * (1 + saturation)).tanh;
      
      // EQ controls
      delayL = HPF.ar(delayL, 20 + (lowCut * 200)); // Low cut
      delayR = HPF.ar(delayR, 20 + (lowCut * 200));
      delayL = LPF.ar(delayL, 20000 * highCut); // High cut  
      delayR = LPF.ar(delayR, 20000 * highCut);
      
      // Reverb
      delayL = delayL + (FreeVerb.ar(delayL, reverb, 0.8, 0.7) * 0.3);
      delayR = delayR + (FreeVerb.ar(delayR, reverb, 0.8, 0.7) * 0.3);
      
      // Stereo width control
      delayL = (delayL * stereoWidth) + (delayR * (1 - stereoWidth));
      delayR = (delayR * stereoWidth) + (delayL * (1 - stereoWidth));
      
      // Apply delay mix parameter
      drySignal = [drone, drone];
      wetSignal = [delayL, delayR];
      mixedSignal = (drySignal * (1 - delayMix)) + (wetSignal * delayMix);
      
      Out.ar(out, mixedSignal * gain * atmosphere);
    }).add;

    // Initial synth
    context.server.sync;
    synth = Synth.new(\avonlea, [
      \depth, defaultDepth,
      \glint, defaultGlint,
      \wind, defaultWind,
      \gain, defaultGain,
      \atmosphere, defaultAtmosphere,
      \detune, defaultDetune,
      \stereoWidth, defaultStereoWidth,
      \harmonics, defaultHarmonics,
      \tempoMult, defaultTempoMult,
      \reverb, defaultReverb,
      \chorus, defaultChorus,
      \saturation, defaultSaturation,
      \shimmerRate, defaultShimmerRate,
      \lowCut, defaultLowCut,
      \highCut, defaultHighCut,
      \delayFeedback, defaultDelayFeedback,
      \delayMix, defaultDelayMix,
      \lfoDepth, defaultLfoDepth,
      \lfoRate, defaultLfoRate,
      \moodShift, defaultMoodShift
    ], context.xg);
    
    // Define commands
    this.addCommand("depth", "f", { |msg|
      synth.set(\depth, msg[1]);
      ("Engine depth: " ++ msg[1]).postln;
    });
    
    this.addCommand("glint", "f", { |msg|
      synth.set(\glint, msg[1]);
      ("Engine glint: " ++ msg[1]).postln;
    });
    
    this.addCommand("wind", "f", { |msg|
      synth.set(\wind, msg[1]);
      ("Engine wind: " ++ msg[1]).postln;
    });
    
    this.addCommand("gain", "f", { |msg|
      synth.set(\gain, msg[1]);
    });
    
    this.addCommand("atmosphere", "f", { |msg|
      synth.set(\atmosphere, msg[1]);
    });
    
    // Extended parameter commands
    this.addCommand("detune", "f", { |msg|
      synth.set(\detune, msg[1]);
    });
    
    this.addCommand("stereoWidth", "f", { |msg|
      synth.set(\stereoWidth, msg[1]);
    });
    
    this.addCommand("harmonics", "f", { |msg|
      synth.set(\harmonics, msg[1]);
    });
    
    this.addCommand("tempoMult", "f", { |msg|
      synth.set(\tempoMult, msg[1]);
    });
    
    this.addCommand("reverb", "f", { |msg|
      synth.set(\reverb, msg[1]);
    });
    
    this.addCommand("chorus", "f", { |msg|
      synth.set(\chorus, msg[1]);
    });
    
    this.addCommand("saturation", "f", { |msg|
      synth.set(\saturation, msg[1]);
    });
    
    this.addCommand("shimmerRate", "f", { |msg|
      synth.set(\shimmerRate, msg[1]);
    });
    
    this.addCommand("lowCut", "f", { |msg|
      synth.set(\lowCut, msg[1]);
    });
    
    this.addCommand("highCut", "f", { |msg|
      synth.set(\highCut, msg[1]);
    });
    
    this.addCommand("delayFeedback", "f", { |msg|
      synth.set(\delayFeedback, msg[1]);
    });
    
    this.addCommand("delayMix", "f", { |msg|
      synth.set(\delayMix, msg[1]);
    });
    
    this.addCommand("lfoDepth", "f", { |msg|
      synth.set(\lfoDepth, msg[1]);
    });
    
    this.addCommand("lfoRate", "f", { |msg|
      synth.set(\lfoRate, msg[1]);
    });
    
    this.addCommand("moodShift", "f", { |msg|
      synth.set(\moodShift, msg[1]);
    });
    
    // Free synth on quit
    this.addCommand("free", "", { 
      synth.free;
    });
  }
  
  // Free resources when engine is unloaded
  free {
    if(synth.notNil, {
      synth.free;
    });
  }
}
