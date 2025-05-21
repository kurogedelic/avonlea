# Avonlea Changes

## Sound Engine Updates (2025-05-21)
- Added moon phase-linked shimmer effect
  - Moon phase now affects brightness and frequency of shimmer
  - Fuller moon creates brighter, higher-frequency shimmer sounds
- Added wind sound generation that responds to wind speed
  - Wind parameter now affects both visual animation and audio
  - Uses resonant filtered noise for realistic wind sounds
- Changed encoder assignments for better usability
  - E2 now controls filter depth instead of glint/shimmer
  - Shimmer effect is now primarily controlled by moon phase
- General audio refinements for better spatial feel

## Visual Improvements (Previous update)
This commit includes the following changes:

## Bug Fixes
- Fixed `math.random()` usage in `avonlea_visual.lua` to ensure integer arguments instead of floating point values
- Fixed the tree drawing function to prevent "screen event Q full!" errors

## Visual Improvements
- Implemented simpler tree rendering using vertical lines similar to reeds
- Added more tree groups for a fuller forest appearance
- Optimized visual elements for better performance
- Trees now use a very dark but visible level (1) for better visibility
- Updated README.md with comprehensive information about features

## Repository Update
- Changed repository path to: github.com/kurogedelic/avonlea

## Next Steps
- Refine moon display and visibility
- Further optimize animation performance
