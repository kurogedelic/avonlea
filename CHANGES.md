# Avonlea Changes

## Major Update (2025-05-21)
- Temporarily separated visual and audio components
  - Current version is visual-only while audio engine is being redeveloped
  - Removed audio engine dependencies to ensure stable operation
  - Fixed initialization issues with visual components

## Development Plans
- Developing improved audio engine separately with SuperCollider
- Will reintegrate sound with better integration between visual and audio elements
- Enhanced parameter mapping planned for future versions

## Previous Visual Improvements
- Fixed `math.random()` usage in `avonlea_visual.lua` to ensure integer arguments
- Fixed tree drawing function to prevent "screen event Q full!" errors
- Implemented simpler tree rendering using vertical lines similar to reeds
- Added more tree groups for a fuller forest appearance
- Optimized visual elements for better performance
- Trees now use a very dark but visible level (1) for better visibility

## Repository Update
- Changed repository path to: github.com/kurogedelic/avonlea

## Next Steps
- Develop standalone SuperCollider sound engine
- Create improved engine integration with Norns
- Reintegrate audio and visual components
- Further optimize performance
