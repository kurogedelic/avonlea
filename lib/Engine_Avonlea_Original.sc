// Engine_Avonlea.sc - Simplified version for testing
Engine_Avonlea : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // Simpler SynthDef definition
    SynthDef(\avonlea, {
      |moonPhase = 0.5, moonAltitude = 30, windSpeed = 0.5, gain = 1.0|
      var sig = SinOsc.ar(440) * 0.1 * gain;
      Out.ar(0, [sig, sig]);
    }).add;

    // パラメータ制御コマンドを追加
    this.addCommand("set", "sf", { |msg|
      var key = msg[1].asSymbol;
      var value = msg[2].asFloat;
      synth.set(key, value);
    });
    
    // 月のパラメータを設定するコマンドを追加
    this.addCommand("moon", "ff", { |msg|
      var phase = msg[1].asFloat;
      var altitude = msg[2].asFloat;
      synth.set(\moonPhase, phase);
      synth.set(\moonAltitude, altitude);
    });
    
    // 風の速度を設定するコマンドを追加
    this.addCommand("wind", "f", { |msg|
      var speed = msg[1].asFloat;
      synth.set(\windSpeed, speed);
    });

    // Synthを生成
    context.server.sync;
    synth = Synth.new(\avonlea, target: context.server);
  }

  free {
    synth.free;
  }
}