# Avonlea

A tranquil ambient visual scene for norns, inspired by the Lake of Shining Waters from "Anne of Green Gables".

> "the Lake of Shining Waters was blue — blue — blue;  
> not the changeful blue of spring, nor the pale azure of summer,  
> but a clear, steadfast, serene blue,  
> as if the water were past all modes and tenses of emotion  
> and had settled down to a tranquillity unbroken by fickle dreams."

**Current Status**: This version is visual-only. The sound engine is being developed separately and will be integrated in a future update.

---

### Features

- **Atmospheric Lake Scene**:
  - Twinkling stars in the night sky with occasional shooting stars
  - Distant trees on hillsides silhouetted against the night sky
  - Lake surface with moonlight reflections
  - Reeds swaying gently at the water's edge
  
- **Realistic Moon Display**:
  - Accurate moon phase based on real date and time
  - Proper positioning in the sky with altitude and azimuth
  - Visual effects like brightness that change with moon phase
  
- **Weather Effects**:
  - Wind speed parameter affecting reed movement and water ripples
  - Visual animations that respond to environmental changes

---

### Controls

#### Visual Control
- **E1** — Wind Speed: controls animation speed of reeds and water ripples

#### Interaction
- **K2** — Toggle moon information display and debug info
- **K3** — Update to current system time

---

### Installation

```bash
;install https://github.com/kurogedelic/avonlea
```

(in maiden's REPL)

---

### Development Roadmap

- **Current**: Visual-only ambient scene
- **In Progress**: Sound engine development using SuperCollider
- **Planned**: Integration of visual and sound elements with:
  - Moon phase affecting sound brightness and timbre
  - Wind speed controlling both animations and sound textures
  - Full ambient soundscape with generative elements

---

### Credits
Developed by kurogedelic