// Engine_Avonlea.sc - Ultra-minimal version
Engine_Avonlea : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Minimal synth
    SynthDef(\avonlea, {
      arg out=0, amp=0.5, hz=440, moonPhase=0.5, moonAltitude=30, windSpeed=0.5;
      var sig = SinOsc.ar(hz) * amp;
      Out.ar(out, [sig, sig]);
    }).add;

    context.server.sync;
    synth = Synth.new(\avonlea, [\out, context.out_b], context.xg);
    
    // Most basic command format
    this.addCommand("amp", "f", { |msg|
      synth.set(\amp, msg[1]);
    });
    
    this.addCommand("hz", "f", { |msg|
      synth.set(\hz, msg[1]);
    });
    
    // Now add the moon command - same format as other working commands
    this.addCommand("moon", "ff", { |msg|
      synth.set(\moonPhase, msg[1]);
      synth.set(\moonAltitude, msg[2]);
    });
    
    // Now add the wind command - same format as other working commands
    this.addCommand("wind", "f", { |msg|
      synth.set(\windSpeed, msg[1]);
    });
  }

  free {
    synth.free;
  }
}