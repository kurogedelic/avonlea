// Avonlea_Mac_Test.scd
// SuperCollider test file for Avonlea engine development
// 
// このファイルではNorns上のエンジンをMacで開発・テストするためのコードを含みます
// 実際にNorns上では動作しませんが、音響デザインとパラメータの実験に使用します
// Green Grablesの柔らかく安心感のある質感を目指した改良版 - Norns用に最適化

// Run this first to clean up
(
s.freeAll;
s.quit;
)

// Run this to start server
(
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 48000;
s.boot;
)

// Define synthdefs (that will go into Engine_Avonlea.sc)
(
SynthDef(\avonlea, {
  |out=0, depth=0.5, glint=0.4, wind=0.3, gain=0.9|
  
  // Norns向けの主要パラメーターから他のパラメーターを決定
  var depthMorph, glintMorph, weightMorph, moonPhase, moonAltitude, windSpeed, lullaby;
  var base, shimmer, drone, melody;
  var lfoDepth, lfoGlint, lfoWeight;
  var actualDepth, actualGlint, weight;
  var delayL, delayR, delayTimeL, delayTimeR;
  var blend;
  var shimmerBrightness, shimmerFreq, shimmerHigh, shimmerLow;
  var windNoise, windFiltered, windModulation;
  var pulseRate, melodyTone;
  
  // Nornsの3つのノブから全パラメータを生成
  // depthパラメータ (0.0~1.0) - 音色の暖かみと深さ
  depthMorph = depth.linlin(0, 1, 0.2, 0.8); // フィルターの深さ
  moonPhase = depth.linlin(0, 1, 0.3, 0.8);   // 月相
  lullaby = depth.linlin(0, 1, 0.3, 0.7);     // 子守唄要素
  
  // glintパラメータ (0.0~1.0) - きらめきと空間感
  glintMorph = glint.linlin(0, 1, 0.1, 0.6);     // きらめきの量
  weightMorph = glint.linlin(0, 1, 0.3, 0.7);     // 空間感
  moonAltitude = glint.linlin(0, 1, 20, 70);      // 月の高度
  
  // windパラメータ (0.0~1.0) - 風の音軸と動き
  windSpeed = wind.linlin(0, 1, 0.05, 0.8);       // 風速
  // 風が強いほど子守唄を抑える
  lullaby = lullaby * (1 - (wind * 0.5));
  
  // 変調オシレーターをより緩やかで有機的に
  lfoDepth  = SinOsc.kr(0.0023).range(-1, 1);
  lfoGlint  = LFNoise2.kr(0.12).range(-1, 1); // より滑らかな変調
  lfoWeight = SinOsc.kr(0.007).range(-1, 1);
  
  actualDepth  = 2000 + (lfoDepth * depthMorph * 2000); // 低域をより多く
  weight = 0.4 + (lfoWeight * weightMorph * 0.15); // ディレイバランス調整
  
  // より有機的なディレイタイム
  delayTimeL = SinOsc.kr(0.033).range(0.05, 0.085);
  delayTimeR = SinOsc.kr(0.021).range(0.08, 0.13); // 黄金比に近い関係
  
  // 複数の倍音を持つ柔らかい基本音
  base = 
    SinOsc.ar(100, 0, 0.2) +          // 基音
    SinOsc.ar(150, 0, 0.1) +           // 3/2の関係（完全5度）
    SinOsc.ar(200, 0, 0.08) +          // 2/1の関係（オクターブ）
    SinOsc.ar(300, 0, 0.04);           // 3/1の関係（オクターブ+5度）
  
  // 月の満ち欠けに基づく音色設計
  shimmerBrightness = moonPhase.linlin(0, 1, 0.3, 0.9); // 新月でも少し明るさを残す
  shimmerFreq = moonPhase.linlin(0, 1, 300, 900);       // より低い周波数帯
  
  // 月の高度による音色の変化
  shimmerHigh = moonAltitude.linlin(0, 90, 0.3, 0.7);  // 月が高いほど高音が増える
  shimmerLow = moonAltitude.linlin(0, 90, 0.7, 0.4);   // 月が低いほど低音が増える
  
  // glintMorphと月相の組み合わせ
  actualGlint = 0.7 + (shimmerBrightness * 1.2) + (lfoGlint * glintMorph * 0.5);
  
  // 複数の周波数層を持つシンマーで豊かな質感
  shimmer = 
    // 低域のシンマー
    SinOsc.ar(
      shimmerFreq * (1 + LFNoise1.kr(0.05).range(-0.01, 0.01)),
      0,
      EnvGen.kr(Env.perc(0.3, 1.5), Dust.kr(actualGlint * shimmerBrightness * 0.5), 0.1 * shimmerBrightness * shimmerLow)
    ) +
    // 中域のシンマー
    SinOsc.ar(
      shimmerFreq * 1.5 * (1 + LFNoise1.kr(0.06).range(-0.01, 0.01)),
      0,
      EnvGen.kr(Env.perc(0.2, 1.2), Dust.kr(actualGlint * shimmerBrightness * 0.4), 0.07 * shimmerBrightness)
    ) +
    // 高域のシンマー（より繊細に）
    SinOsc.ar(
      shimmerFreq * 2 * (1 + LFNoise1.kr(0.08).range(-0.01, 0.01)),
      0,
      EnvGen.kr(Env.perc(0.1, 0.8), Dust.kr(actualGlint * shimmerBrightness * 0.3), 0.04 * shimmerBrightness * shimmerHigh)
    );
  
  // 風の要素をより有機的に
  windModulation = LFNoise2.kr(0.08 + (windSpeed * 0.1)); // より滑らかな変調
  windNoise = PinkNoise.ar(windSpeed * 0.3);
  
  // 複数の帯域で風の音を作る
  windFiltered = 
    // 低域 - 暖かみのある存在感
    LPF.ar(windNoise, 200 + (windSpeed * 100)) * 0.6 +
    // 中域 - 風のささやき
    BPF.ar(
      windNoise, 
      SinOsc.kr(0.03 + (windSpeed * 0.05)).range(400, 800),
      0.4
    ) * 0.3 +
    // 高域 - 繊細な空気感
    HPF.ar(
      windNoise, 
      2000 + (windSpeed * 1000),
      0.1
    ) * windSpeed * 0.2;
  
  // 子守唄的な穏やかな旋律の生成
  pulseRate = 0.85; // 心拍のような安定したテンポ
  melodyTone = lullaby * 0.25; // 子守唄の音量調整
  
  melody = [
    // 子守唄的な穏やかな3音のメロディー
    SinOsc.ar(300, 0, 
      EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25), melodyTone)
    ),
    SinOsc.ar(400, 0, 
      EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25, 0.33), melodyTone * 0.8)
    ),
    SinOsc.ar(350, 0, 
      EnvGen.kr(Env.perc(0.2, 1.5), Impulse.kr(pulseRate * 0.25, 0.67), melodyTone * 0.9)
    ),
    // 低域のハミング音 - 安定感を与える
    SinOsc.ar(150, 0, 
      LFTri.kr(pulseRate * 0.125).range(0, 0.1) * lullaby
    ),
    // 非常に静かな安定した低音のうねり
    SinOsc.ar(75, 0, 
      LFTri.kr(pulseRate * 0.0625).range(0.05, 0.12) * lullaby
    )
  ].sum;
  
  // 安定したアンビエント要素の追加 - 揺らぎの少ない安心感のある成分
  melody = melody + (
    LPF.ar(
      SinOsc.ar([250, 300, 350], 0, 0.04 * lullaby).sum * 
      LFTri.kr(0.1).range(0.6, 1.0),
      400
    )
  );

  // 音色の混合
  blend = SinOsc.kr(0.0025).range(0.3, 0.6); // より穏やかな変化
  
  // クロスフェーダーの調整（より低域よりに）
  drone = XFade2.ar(
    LPF.ar(base + shimmer, actualDepth),
    HPF.ar(base + shimmer, 4000) * 0.7, // 高域を少し抑える
    blend * 1.6 - 0.8
  );
  
  // メイン音と風の音と子守唄をバランス良くミックス
  drone = drone + (windFiltered * windSpeed * 0.6) + melody;
  
  // 複数のフィードバックパスで複雑な空間感
  drone = 
    // メインのディレイ（少し緩める）
    (CombL.ar(drone, 0.5, weight, 4) * 0.6) +
    // 短いエコー（立体感）
    (CombL.ar(drone, 0.2, weight * 0.5, 1.5) * 0.3) +
    // 元の信号
    (drone * 0.8);
  
  // 柔らかさを増すための最終的なEQ
  drone = 
    // 低中域の増強
    LPF.ar(drone, 600) * 1.2 +
    // 中域のわずかな抑制（攻撃性を下げる）
    BPF.ar(drone, 1200, 1) * 0.8 +
    // 高域の透明感（量を抑える）
    HPF.ar(drone, 5000) * 0.5;
  
  // 最終的なディレイとパンニング
  delayL = DelayL.ar(drone, 0.15, delayTimeL);
  delayR = DelayL.ar(drone, 0.15, delayTimeR);
  
  Out.ar(out, [delayL, delayR] * gain);
}).add;
)

// Play the synth to test - Norns用に最適化したGreen Grables版
(
x = Synth(\avonlea, [
\gain, 0.8,     // 音量
\depth, 0.5,    // 音色の暖かみ・深さ (0.0~1.0)
\glint, 0.4,    // きらめきと空間感 (0.0~1.0)
\wind, 0.3      // 風の音軸と動き (0.0~1.0)
]);
)
)

// Test changes in parameters
(
// より暖かみと安心感のある設定
x.set(\depth, 0.7, \wind, 0.2);
)

(
// よりきらめきと空間感が強い設定
x.set(\glint, 0.8, \wind, 0.3);
)

(
// 風の要素を強めた設定
x.set(\wind, 0.7, \depth, 0.4);
)

(
// 静かな設定 - 風が弱く、暖かみと空間感のバランス
x.set(\wind, 0.1, \depth, 0.6, \glint, 0.5);
)

(
// 深く暖かい音色
x.set(\depth, 0.9, \wind, 0.2, \glint, 0.3);
)

(
// 轻く明るい音色
x.set(\depth, 0.3, \wind, 0.2, \glint, 0.6);
)

// Norns向けのコントロール例
/*
// Nornsではこのように使用します

engine.name = 'Avonlea'

function init()
  -- パラメーターの初期化
  params:add_control("depth", "Depth", controlspec.new(0, 1, 'lin', 0, 0.5, ""))
  params:set_action("depth", function(x) engine.depth(x) end)
  
  params:add_control("glint", "Glint", controlspec.new(0, 1, 'lin', 0, 0.4, ""))
  params:set_action("glint", function(x) engine.glint(x) end)
  
  params:add_control("wind", "Wind", controlspec.new(0, 1, 'lin', 0, 0.3, ""))
  params:set_action("wind", function(x) engine.wind(x) end)
  
  params:add_control("gain", "Gain", controlspec.new(0, 1, 'lin', 0, 0.8, ""))
  params:set_action("gain", function(x) engine.gain(x) end)
end
*/

// Stop synth when done
x.free;

// Stop synth when done
x.free;
