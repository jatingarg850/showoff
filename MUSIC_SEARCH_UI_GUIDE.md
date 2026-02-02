# Music Search - UI Visual Guide

## Screen Layout

```
┌─────────────────────────────────────────┐
│  ← Select Background Music              │  ← App Bar
├─────────────────────────────────────────┤
│                                         │
│  🔍 Search by title, artist, or genre.. │  ← NEW: Search Bar
│                                         │
├─────────────────────────────────────────┤
│  Filter by Genre & Mood                 │
│  ┌──────────────────┬──────────────────┐│
│  │ Genre ▼          │ Mood ▼           ││  ← Existing Filters
│  └──────────────────┴──────────────────┘│
├─────────────────────────────────────────┤
│                                         │
│  ◯ Song Title 1                    3:45 │
│    Artist Name  [Pop] [Happy]           │
│                                         │
│  ◉ Song Title 2                    4:12 │  ← Selected
│    Artist Name  [Rock] [Energetic]      │
│                                         │
│  ◯ Song Title 3                    3:30 │
│    Artist Name  [Jazz] [Calm]           │
│                                         │
├─────────────────────────────────────────┤
│  [Continue with Selected Music]         │
│  [Skip Music]                           │
└─────────────────────────────────────────┘
```

## Search Bar States

### Empty State
```
┌─────────────────────────────────────────┐
│ 🔍 Search by title, artist, or genre... │
└─────────────────────────────────────────┘
```

### Active State (Typing)
```
┌─────────────────────────────────────────┐
│ 🔍 love                              ✕  │
└─────────────────────────────────────────┘
```

### Focused State
```
┌─────────────────────────────────────────┐
│ 🔍 love                              ✕  │  ← Purple border
└─────────────────────────────────────────┘
```

## Search Results Examples

### Example 1: Search "love"
```
Search Results for "love":

◯ Love Song                          3:45
  John Smith  [Pop] [Happy]

◯ Lovely Day                         4:12
  Bill Withers  [Soul] [Happy]

◯ Love Me Like You Do                3:30
  Ellie Goulding  [Pop] [Romantic]
```

### Example 2: Search "pop"
```
Search Results for "pop":

◯ Pop Music                          3:45
  Various Artists  [Pop] [Happy]

◯ Popular                            4:12
  Nada Surf  [Rock] [Energetic]

◯ Popcorn                            3:30
  Hot Butter  [Electronic] [Happy]
```

### Example 3: Search "john"
```
Search Results for "john":

◯ Love Song                          3:45
  John Smith  [Pop] [Happy]

◯ Imagine                            4:12
  John Lennon  [Rock] [Calm]

◯ John's Theme                       3:30
  Composer  [Classical] [Calm]
```

## Empty State Examples

### No Results (Search Active)
```
┌─────────────────────────────────────────┐
│                                         │
│              🎵                         │
│                                         │
│          No music found                 │
│                                         │
│      Try a different search term        │
│                                         │
└─────────────────────────────────────────┘
```

### No Results (Filters Only)
```
┌─────────────────────────────────────────┐
│                                         │
│              🎵                         │
│                                         │
│          No music found                 │
│                                         │
│          Try different filters          │
│                                         │
└─────────────────────────────────────────┘
```

## Color Scheme

| Element | Color | Hex |
|---------|-------|-----|
| Search Icon | Purple | #701CF5 |
| Border (Normal) | Light Gray | #E0E0E0 |
| Border (Focused) | Purple | #701CF5 |
| Clear Button | Gray | #808080 |
| Placeholder Text | Gray | #999999 |
| Input Text | Black | #000000 |

## Interaction Flow

### User Types in Search
```
User Types "love"
        ↓
_searchController listener triggered
        ↓
_filterMusic() called
        ↓
_filteredMusicList updated
        ↓
setState() called
        ↓
ListView rebuilds with filtered results
        ↓
User sees results instantly
```

### User Clears Search
```
User clicks X button
        ↓
_searchController.clear() called
        ↓
_filterMusic() called
        ↓
_filteredMusicList = _musicList
        ↓
setState() called
        ↓
ListView rebuilds with all music
        ↓
User sees all music again
```

## Responsive Design

### Mobile (Portrait)
```
┌──────────────────────┐
│ ← Select Music       │
├──────────────────────┤
│ 🔍 Search...      ✕  │
├──────────────────────┤
│ Genre ▼  Mood ▼      │
├──────────────────────┤
│ ◯ Song 1        3:45 │
│   Artist [Pop]       │
│                      │
│ ◉ Song 2        4:12 │
│   Artist [Rock]      │
├──────────────────────┤
│ [Continue]           │
│ [Skip]               │
└──────────────────────┘
```

### Tablet (Landscape)
```
┌────────────────────────────────────────────────┐
│ ← Select Music                                 │
├────────────────────────────────────────────────┤
│ 🔍 Search by title, artist, or genre...    ✕  │
├────────────────────────────────────────────────┤
│ Genre ▼              Mood ▼                    │
├────────────────────────────────────────────────┤
│ ◯ Song 1                                  3:45 │
│   Artist Name  [Pop] [Happy]                   │
│                                                │
│ ◉ Song 2                                  4:12 │
│   Artist Name  [Rock] [Energetic]              │
├────────────────────────────────────────────────┤
│ [Continue with Selected Music]  [Skip Music]   │
└────────────────────────────────────────────────┘
```

## Accessibility Features

### Touch Targets
- Search bar: 48px minimum height
- Clear button: 48px minimum touch area
- Music items: 56px minimum height
- Buttons: 56px height

### Visual Indicators
- Focus state: Purple border (2px)
- Selection: Purple circle with checkmark
- Hover: Subtle background change
- Disabled: Grayed out appearance

### Text Contrast
- Input text on white: High contrast (black)
- Placeholder text: Medium contrast (gray)
- Labels: High contrast (black)
- Hints: Medium contrast (gray)

## Animation & Transitions

### Search Results Update
- Duration: Instant (< 100ms)
- Type: Smooth list rebuild
- Effect: No visible lag

### Clear Button Appearance
- Duration: 200ms
- Type: Fade in/out
- Effect: Smooth transition

### Empty State
- Duration: 300ms
- Type: Fade in
- Effect: Smooth appearance

## Keyboard Behavior

### Mobile Keyboard
- Appears when search bar focused
- Dismisses when user taps outside
- Search continues while keyboard open
- Clear button visible above keyboard

### Desktop Keyboard
- Standard text input behavior
- Tab navigation supported
- Enter key can submit (if needed)
- Escape key can clear (optional)

## Performance Indicators

### Loading State
```
┌─────────────────────────────────────────┐
│                                         │
│          ⟳ Loading...                   │
│                                         │
└─────────────────────────────────────────┘
```

### Search in Progress
- No loading indicator (instant filtering)
- Results update in real-time
- No blocking UI

## Summary

The music search UI:
- ✅ Matches app design language
- ✅ Provides clear visual feedback
- ✅ Supports all screen sizes
- ✅ Accessible to all users
- ✅ Responsive and performant
- ✅ Intuitive and easy to use
