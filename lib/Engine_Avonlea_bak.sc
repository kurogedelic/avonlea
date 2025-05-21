// Engine_Avonlea.sc
Engine_Avonlea : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // SynthDef定義
    SynthDef(\avonlea, {
      |depthMorph = 0.4, glintMorph = 0.3, weightMorph = 0.4, gain = 1.0, moonPhase = 0.5, moonAltitude = 30, windSpeed = 0.5|
      var base, shimmer, drone, env;
      var lfoDepth, lfoGlint, lfoWeight;
      var depth, glint, weight;
      var delayL, delayR, delayTimeL, delayTimeR;
      var blend;
      var shimmerBrightness, shimmerFreq;
      var windNoise, windFiltered, windModulation;

      lfoDepth  = SinOsc.kr(0.003).range(-1, 1);
      lfoGlint  = LFNoise1.kr(0.2).range(-1, 1);
      lfoWeight = SinOsc.kr(0.01).range(-1, 1);

      depth  = 3000 + (lfoDepth  * depthMorph * 2500);
      // glintとweightの計算は後で月相と組み合わせて行う
      weight = 0.3   + (lfoWeight * weightMorph * 0.2);

      delayTimeL = SinOsc.kr(0.07).range(0.03, 0.08);
      delayTimeR = SinOsc.kr(0.09).range(0.04, 0.09);

      base = SinOsc.ar(100, 0, 0.3);

      // 月の満ち欠けに基づくシンマーの明るさと周波数の計算
      // 月相に影響されるshimmerBrightness
      shimmerBrightness = moonPhase.linlin(0, 1, 0.2, 1.0); // 新月で最小、満月で最大
      shimmerFreq = moonPhase.linlin(0, 1, 3500, 7000);     // 周波数も変化（新月で低く、満月で高く）
      
      // glintMorphを月相と組み合わせる - 月相がベースとなり、glintMorphは調整値に
      glint = 1.0 + (shimmerBrightness * 1.5) + (lfoGlint * glintMorph * 0.7);
      
      // 風の要素の作成
      windModulation = LFNoise1.kr(0.1 + (windSpeed * 0.2)); // 風速に伴い変調が速くなる
      windNoise = PinkNoise.ar(windSpeed * 0.4); // 風速に比例したノイズ量
      // 共鳴フィルターで風の音を作る
      windFiltered = RLPF.ar(
        windNoise, 
        SinOsc.kr(0.05 + (windSpeed * 0.1)).range(300, 1200) * (windSpeed + 0.5), // 風速でフィルターが変動
        0.7 - (windSpeed * 0.3) // 風が強いほど共鳴度が上がる
      );
      
      shimmer = SinOsc.ar(
        shimmerFreq + LFNoise1.kr(0.1).range(-1000 * shimmerBrightness, 1000 * shimmerBrightness),
        0,
        EnvGen.kr(Env.perc(0.1, 1), Dust.kr(glint * shimmerBrightness), 0.08 * shimmerBrightness)
      );

      blend = SinOsc.kr(0.003).range(0.3, 0.7);

      drone = XFade2.ar(
        LPF.ar(base + shimmer, depth),
        HPF.ar(base + shimmer, 4000),
        blend * 2 - 1
      );

      // メイン音と風の音をミックス
      drone = drone + (windFiltered * windSpeed * 0.8);
      
      drone = CombL.ar(drone, 0.3, weight, 3) + drone;

      delayL = DelayL.ar(drone, 0.1, delayTimeL);
      delayR = DelayL.ar(drone, 0.1, delayTimeR);

      Out.ar(0, [delayL, delayR] * gain);
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