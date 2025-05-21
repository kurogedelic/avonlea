// Avonlea_Mac_Test_Fixed.scd
// SuperCollider test file for Avonlea engine development
// 
// このファイルではNorns上のエンジンをMacで開発・テストするためのコードを含みます
// 実際にNorns上では動作しませんが、音響デザインとパラメータの実験に使用します

// サーバーをクリーンアップして再起動
s.freeAll;
s.quit;

s.options.numOutputBusChannels = 2;
s.options.sampleRate = 48000;
s.boot;

// Define synthdefs (that will go into Engine_Avonlea.sc)
SynthDef(\avonlea, {
  |out=0, depthMorph=0.4, glintMorph=0.3, weightMorph=0.4, gain=1.0, moonPhase=0.5, moonAltitude=30, windSpeed=0.5|
  var base, shimmer, drone;
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
  weight = 0.3   + (lfoWeight * weightMorph * 0.2);

  delayTimeL = SinOsc.kr(0.07).range(0.03, 0.08);
  delayTimeR = SinOsc.kr(0.09).range(0.04, 0.09);

  base = SinOsc.ar(100, 0, 0.3);

  // 月の満ち欠けに基づくシンマーの明るさと周波数の計算
  shimmerBrightness = moonPhase.linlin(0, 1, 0.2, 1.0); // 新月で最小、満月で最大
  shimmerFreq = moonPhase.linlin(0, 1, 3500, 7000);     // 周波数も変化（新月で低く、満月で高く）
  
  // glintMorphを月相と組み合わせる
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

  Out.ar(out, [delayL, delayR] * gain);
}).add;

// テスト用シンセの作成と再生は下記のコードを実行してください
/*
x = Synth(\avonlea, [
  \gain, 0.8,         // 音量
  \depthMorph, 0.4,   // フィルターの深さ
  \glintMorph, 0.3,   // きらめきの量
  \weightMorph, 0.5,  // 空間感
  \moonPhase, 0.5,    // 月相（0=新月, 0.5=満月, 1=新月）
  \moonAltitude, 30,  // 月の高度（角度）
  \windSpeed, 0.5     // 風速
]);

// パラメータ変更テスト
// 満月（明るい輝き）
x.set(\moonPhase, 1.0);

// 新月（暗い輝き）
x.set(\moonPhase, 0.0);

// 風が強い
x.set(\windSpeed, 0.9);

// 風が弱い
x.set(\windSpeed, 0.1);

// フィルターの深さを変更
x.set(\depthMorph, 0.8);

// 空間感を変更
x.set(\weightMorph, 0.8);

// シンセを停止
x.free;
*/