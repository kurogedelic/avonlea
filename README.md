# Avonlea

_A tranquil ambient sketch for norns._  
Inspired by the Lake of Shining Waters in **Anne of Green Gables**.

> "…as if the water were past all modes and tenses of emotion…"

---

## Concept

Avonlea is a quiet sandbox that portrays the night over a lake,  
as seen from Prince Edward Island. The sky and water respond  
to live weather and the moon's motion, crafting a soundscape that  
moves with the world.

---

## Features

### Real-time Integration
- **Moon tracking**: Phase and altitude automatically control sound depth and spatial parameters
- **Weather integration**: Live weather data from Open-Meteo API affects the soundscape
- **Time synchronization**: Reflects actual time and celestial positions

### Visual Elements
- **Dynamic sky**: Stars fade and appear based on weather conditions
- **Moon phases**: Accurate lunar phases with realistic positioning
- **Weather effects**: Rain and snow particles with wind interaction
- **Shooting stars**: Occasional meteors across clear skies
- **Lake reflections**: Moon reflections that respond to wind and weather

### Audio Engine
- **Three-parameter design**: Simple yet expressive control via Wind, Depth, and Glint
- **Weather-responsive sound**: Atmospheric filtering and modulation based on conditions
- **Lullaby elements**: Gentle melodic components that emerge in calm conditions
- **Spatial processing**: Multi-delay systems create sense of space and distance

---

## Controls

- **E1**: Wind intensity
- **E2**: "the depths of the lake"
- **E3**: Surface glint
- **K2**: Cycle weather mode (Auto / Clear / Cloudy / Rainy / Snowy)
- **K3**: Toggle time display (also refreshes time & weather)

> note: auto mode uses realtime weather data.  
> Location: 46.49300°N, 63.38729°W (Prince Edward Island)

---

## Atmosphere

- Moon phase and angle shape the shimmer and tone
- Open-Meteo provides real-world weather (daily update)
- Stars fade when clouds appear; glints dim with rain
- Wind bends reeds; snow softens the edges of sound

---

## Technical Details

### Requirements
- **norns** (any version)
- **Internet connection** for weather data (optional - works offline with manual weather control)

### Architecture
- **Lua frontend**: Main interface and visual rendering
- **SuperCollider engine**: Audio synthesis and processing
- **Modular design**: Clean separation of concerns with centralized configuration

### Weather Data
- **Source**: Open-Meteo API (free, no API key required)
- **Update frequency**: Every hour in auto mode
- **Fallback**: Manual weather control when offline

---

## Installation

```
;install https://github.com/kurogedelic/avonlea
```

---

## Credits

- Script / Engine: Leo Kuroshita @kurogedelic
- Weather API: Open-Meteo
- Inspiration: L. M. Montgomery
