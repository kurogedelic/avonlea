# Avonlea - Project Information

## Overview
Avonlea is a tranquil ambient sketch for norns (sound computer/music platform). It's inspired by the Lake of Shining Waters from Anne of Green Gables.

## Technical Details
- **Platform**: norns (monome)
- **Language**: Lua
- **Engine**: Avonlea (SuperCollider engine)
- **Version**: v1.1.0

## Project Structure
```
avonlea/
├── avonlea.lua          # Main script file
├── cover.png            # UI cover image
├── README.md            # User documentation
└── lib/
    ├── Engine_Avonlea.sc   # SuperCollider engine
    ├── avonlea_engine.lua  # Sound engine wrapper
    ├── avonlea_visual.lua  # Visual/UI components
    ├── constants.lua       # Configuration constants
    ├── moon_calculator.lua # Moon phase calculations
    ├── moon_drawing.lua    # Moon visualization
    ├── shooting_star.lua   # Shooting star effects
    └── weather.lua         # Weather system

```

## Key Features
- **Ambient soundscape** influenced by real-time moon phase and weather effects
- **Visual elements** include moon, stars, reeds, and weather effects  
- **Three-knob simplicity** with immediate encoder access to core parameters
- **Extended sound design** via 14 additional parameters in norns menu system
- **Weather integration** with real location data (Prince Edward Island)
- **Comprehensive presets** demonstrating the expanded sonic range
- **Backward compatibility** - all original behavior preserved

## Controls

### Hardware Controls
- **E1**: Wind control (0.0-1.0)
- **E2**: Depth control (0.0-1.0)
- **E3**: Glint control (0.0-1.0) 
- **K2**: Cycle through weather states
- **K3**: Toggle moon info display (time and moon phase %)

### Extended Parameters (via norns menu)

#### Core Controls
- **Depth**: Sound warmth and depth (0.0-1.0)
- **Glint**: Sparkle and spatial feel (0.0-1.0)
- **Wind**: Wind sound and movement (0.0-1.0)
- **Master Gain**: Overall volume (0.0-1.0)

#### Harmonic & Tuning
- **Detune**: Subtle pitch detuning (-2.0 to 2.0)
- **Harmonics**: Harmonic content amount (0.0-2.0)

#### Temporal Controls
- **Lullaby Tempo**: Melody tempo multiplier (0.1-3.0x)
- **LFO Rate**: Modulation speed (0.1-3.0x)
- **LFO Depth**: Modulation intensity (0.0-2.0)
- **Shimmer Rate**: Sparkle frequency (0.0-3.0x)

#### Spatial & Effects
- **Stereo Width**: Stereo field width (0.0-1.0)
- **Reverb**: Reverb amount (0.0-1.0)
- **Chorus**: Chorus effect depth (0.0-0.8)
- **Saturation**: Soft distortion (0.0-1.0)

#### EQ & Filtering
- **Low Cut**: High-pass filter amount (0.0-1.0)
- **High Cut**: Low-pass filter amount (0.1-1.0)

#### Mood & Character
- **Mood Shift**: Overall emotional character (0.0-1.0)

#### Advanced
- **Delay Feedback**: Echo feedback amount (0.0-0.9)
- **Delay Mix**: Echo wet/dry balance (0.0-1.0)

### Presets
- **Calm Waters**: Peaceful lake setting
- **Starry Night**: Clear evening with enhanced shimmer  
- **Breezy Evening**: Windy atmospheric setting
- **Dream Lullaby**: Gentle, sleep-inducing mode
- **Ethereal Mist**: Mysterious, detuned atmosphere
- **Approaching Storm**: Dark, intense weather
- **Golden Hour**: Warm, nostalgic evening

## Implementation Details

### Sound Processing Extensions
- **Harmonic control**: Detune and harmonic content manipulation
- **Temporal modulation**: Controllable LFO rates and depths
- **Spatial processing**: Stereo width, reverb, and chorus effects
- **Dynamic filtering**: Low/high cut controls for timbral shaping
- **Character controls**: Mood shifts and saturation for emotional range

### Architecture
- **SuperCollider engine**: Extended with 14 new safe parameters
- **Lua wrapper**: Organized parameter categories with clear descriptions
- **Preset system**: 7 presets showcasing different sonic characters
- **Weather integration**: Original weather modulation system intact
- **Visual feedback**: Parameter changes reflected in UI

### Safety & Compatibility
- All new parameters have sensible defaults
- Original three-knob behavior completely preserved
- SuperCollider engine changes are additive, not destructive
- Error protection for engine communication
- Backward compatible with existing .pset files

## Development Notes
- Uses Open-Meteo for weather data
- Moon calculations based on actual lunar phases
- Sound engine responds dynamically to weather and moon states
- Visual feedback system shows parameter changes
- Extended parameters accessible via norns parameter system
- All controls organized in logical categories for easy navigation

## Testing
- Test original encoder behavior (E1=Wind, E2=Depth, E3=Glint) remains unchanged
- Verify all new parameters respond correctly via norns menu
- Test preset loading and parameter interactions
- Confirm weather modulation still functions with extended parameters
- Test on norns hardware or development environment

## Installation
Install via maiden: `;install https://github.com/kurogedelic/avonlea`