---
description: Use Playwright to crawl a site and validate UI for visual issues
allowed-tools: mcp__plugin_playwright_playwright__*
---

Use Playwright to crawl the local development site and check for visual/UI issues.

## Configuration

- Base URL: `http://localhost:3000` (or as specified in arguments)
- If arguments are provided, use them as the base URL

## Validation Checklist

For each page visited, check for:

1. **Content overlap** - Text or elements overlapping each other
2. **Broken links** - Links that don't navigate or return errors
3. **Missing images** - Images that fail to load
4. **Layout issues** - Elements outside viewport, broken grid/flex layouts
5. **Navigation functionality** - Dropdowns, menus working properly
6. **Responsive issues** - Content cut off or misaligned

## Process

1. Navigate to the homepage
2. Take a snapshot to understand the page structure
3. Click through main navigation links systematically
4. For each page:
   - Take an accessibility snapshot
   - Check for console errors
   - Verify all visible links are valid
   - Look for visual anomalies in the snapshot
5. Test dropdown menus and interactive elements
6. Check both light and dark mode if a theme toggle exists

## Reporting

After crawling, provide a summary:

### Pages Visited
- List each URL checked

### Issues Found
- Describe any problems with severity (critical/warning/minor)
- Include the page URL and element reference

### All Clear
- If no issues found, confirm the site looks good

## Notes

- Focus on structural/functional issues, not design opinions
- Skip external links (just verify they have valid href)
- If the dev server isn't running, report that immediately
