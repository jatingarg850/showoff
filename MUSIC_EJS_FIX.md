# Music.ejs Fix - Script Tag Issue

## Problem
The `</script>` tag was placed at line 820, closing the script prematurely. All functions after that line were outside the script tag, causing JavaScript errors.

## Solution
Move the `</script>` tag to the very end of the file, after ALL JavaScript functions.

## Steps to Fix

1. Open `server/views/admin/music.ejs`
2. Find line 820 where it says `</script>`
3. Delete that line
4. Go to the end of the file (before `</body>`)
5. Add `</script>` there

## Correct Structure

```html
<!DOCTYPE html>
<html>
<head>
    ...styles...
</head>
<body>
    ...HTML content...
    
    <script>
        let currentPage = 1;
        let totalPages = 1;
        
        // ALL JAVASCRIPT FUNCTIONS HERE
        
        document.addEventListener('DOMContentLoaded', () => {
            loadMusic();
            loadStats();
        });
        
        async function loadMusic() { ... }
        function displayMusic() { ... }
        // ... all other functions ...
        
    </script>  <!-- THIS SHOULD BE AT THE END -->
</body>
</html>
```

## Quick Fix Command

If using VS Code:
1. Press Ctrl+H (Find and Replace)
2. Find: `    </script>\n\n        document.addEventListener`
3. Replace with: `        document.addEventListener`
4. Go to end of file before `</body>`
5. Add `    </script>`

## Verification

After fixing:
- Refresh the page
- Check browser console (F12) for errors
- Music grid should load
- Play button should work
