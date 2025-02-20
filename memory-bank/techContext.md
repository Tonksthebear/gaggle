# Tech Context

This document outlines the technologies used in the project, the development setup, technical constraints, and dependencies. It serves as a guide for understanding the technical choices made and facilitates future troubleshooting and improvements.

## Technologies Used

- **Turbo**: Used for accelerated page updates.
- **Stimulus**: Used for lightweight JavaScript interactions.
- **TailwindCSS**: Used for utility-first styling. The project doesn't need to have tailwind because the styles come with the gem. If you want to contribute, you have to have the tailwind gem and have it running with the options `-i app/assets/stylesheets/application.css -o app/assets/gaggle/builds/application.css`
- **Importmap**: Used for managing JavaScript dependencies without Node.js.
