# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands
- **Local Development**: As this is a static site, you can run a simple local server:
  `python3 -m http.server 8000`
- **Deployment Target**: The project is designed to be hosted on an Ubuntu VM using Nginx. Files should be placed in `/var/www/html`.

## Architecture & Structure
- **Static Site**: A professional portfolio built with pure HTML and CSS.
- **Core Files**:
  - `index.html`: The primary landing page containing all main sections (Home, About, Services, Courses, Books, Community, Contact).
  - `style.css`: Contains all visual styling and responsive design layouts.
  - `images/`: Directory for all site assets.
  - `privacy.html` & `terms.html`: Static legal pages linked from the footer.
- **Navigation**: Uses internal anchor links (e.g., `#about`, `#services`) for single-page navigation.

## Project Constraints
- **Ownership Proof**: Per DMI rules, any deployment must include a personalized ownership line in the footer of `index.html` (replacing or following the original "Crafted with cloud excellence" line).
