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
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Define the synth
    SynthDef(\avonlea, {
      |out=0, depth=0.5, glint=0.4, wind=0.3, gain=0.9, atmosphere=1.0|
      
      // Determine other parameters from Norns main parameters
      var depthMorph, glintMorph, weightMorph, moonPhase, moonAltitude, windSpeed, lullaby;
      var base, shimmer, drone, melody;
      var lfoDepth, lfoGlint, lfoWeight;
      var actualDepth, actualGlint, weight;
      var delayL, delayR, delayTimeL, delayTimeR;
      var blend;
      var shimmerBrightness, shimmerFreq, shimmerHigh, shimmerLow;
      var windNoise, windFiltered, windModulation;
      var pulseRate, melodyTone;
      
      // Generate all parameters from Norns' three knobs
      // depth parameter (0.0~1.0) - Sound warmth and depth
      depthMorph = depth.linlin(0, 1, 0.2, 0.8); // Filter depth
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
      
      // Modulation oscillators made more gentle and organic
      lfoDepth  = SinOsc.kr(0.0023).range(-1, 1);
      lfoGlint  = LFNoise2.kr(0.12).range(-1, 1); // Smoother modulation
      lfoWeight = SinOsc.kr(0.007).range(-1, 1);
      
      actualDepth  = 2000 + (lfoDepth * depthMorph * 2000); // More low frequencies
      weight = 0.4 + (lfoWeight * weightMorph * 0.15); // Delay balance adjustment
      
      // More organic delay times
      delayTimeL = SinOsc.kr(0.033).range(0.05, 0.085);
      delayTimeR = SinOsc.kr(0.021).range(0.08, 0.13); // Golden ratio relationship
      
      // Soft fundamental sound with multiple harmonics
      base = 
        SinOsc.ar(100, 0, 0.2) +          // Fundamental
        SinOsc.ar(150, 0, 0.1) +           // 3/2 relationship (perfect 5th)
        SinOsc.ar(200, 0, 0.08) +          // 2/1 relationship (octave)
        SinOsc.ar(300, 0, 0.04);           // 3/1 relationship (octave + 5th)
      
      // Sound design based on moon phases
      shimmerBrightness = moonPhase.linlin(0, 1, 0.3, 0.9); // Keep some brightness even at new moon
      shimmerFreq = moonPhase.linlin(0, 1, 300, 900);       // Lower frequency range
      
      // Timbre changes based on moon altitude
      shimmerHigh = moonAltitude.linlin(0, 90, 0.3, 0.7);  // Higher moon = more highs
      shimmerLow = moonAltitude.linlin(0, 90, 0.7, 0.4);   // Lower moon = more lows
      
      // Combination of glintMorph and moon phase
      actualGlint = 0.7 + (shimmerBrightness * 1.2) + (lfoGlint * glintMorph * 0.5);
      
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
      
      // Generate gentle lullaby-like melody
      pulseRate = 0.85; // Stable tempo like a heartbeat
      melodyTone = lullaby * 0.25; // Lullaby volume adjustment
      
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
    
      // Sound blending
      blend = SinOsc.kr(0.0025).range(0.3, 0.6); // More gentle changes
      
      // Crossfader adjustment (more toward low frequencies)
      drone = XFade2.ar(
        LPF.ar(base + shimmer, actualDepth),
        HPF.ar(base + shimmer, 4000) * 0.7, // Slightly reduce highs
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
      
      // Final EQ to increase softness
      drone = 
        // Low-mid frequency boost
        LPF.ar(drone, 600) * 1.2 +
        // Slight mid frequency reduction (reduce aggressiveness)
        BPF.ar(drone, 1200, 1) * 0.8 +
        // High frequency transparency (preserve wind texture)
        HPF.ar(drone, 3000) * 0.8;
      
      // Final delay and panning
      delayL = DelayL.ar(drone, 0.15, delayTimeL);
      delayR = DelayL.ar(drone, 0.15, delayTimeR);
      
      // Apply atmosphere (weather) filtering
      delayL = LPF.ar(delayL, 8000 * atmosphere); // High frequency rolloff in bad weather
      delayR = LPF.ar(delayR, 8000 * atmosphere);
      
      Out.ar(out, [delayL, delayR] * gain * atmosphere);
    }).add;

    // Initial synth
    context.server.sync;
    synth = Synth.new(\avonlea, [
      \depth, defaultDepth,
      \glint, defaultGlint,
      \wind, defaultWind,
      \gain, defaultGain,
      \atmosphere, defaultAtmosphere
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
