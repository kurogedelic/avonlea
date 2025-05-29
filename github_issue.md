# Empty "Visual Parameters" section in parameter menu

## Description
There's an empty "Visual Parameters" separator in the parameter menu that doesn't contain any actual parameters.

## Steps to reproduce
1. Open Avonlea script
2. Navigate to parameters menu
3. Observe the "Visual Parameters" section

## Current behavior
- "Visual Parameters" separator appears in menu
- No parameters are listed under this section
- Immediately followed by "Moon Settings" section

## Expected behavior
Either:
- Remove the empty separator, or
- Add actual visual parameters under this section

## Code location
File: `avonlea.lua`, line 196

```lua
-- Add wind parameter (connect with engine's wind parameter)
params:add_separator("Visual Parameters")

-- Add date and time settings
params:add_separator("Moon Settings")
```

## Suggested fix
**Option 1: Remove empty separator**
```lua
-- Add date and time settings
params:add_separator("Moon Settings")
```

**Option 2: Add placeholder comment**
```lua
params:add_separator("Visual Parameters")
-- TODO: Add visual parameters in future update

params:add_separator("Moon Settings")
```

## Impact
- Minor UI/UX issue
- Doesn't affect functionality
- May confuse users expecting parameters in this section