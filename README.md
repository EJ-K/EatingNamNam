# EatingNamNam

A World of Warcraft addon that announces when you start and stop eating or drinking in group instances.

<!-- TODO: Add wago.io link once published -->

## Features

- Detects food, drink, and combined food & drink buffs on your character
- Sends a SAY message when you start eating/drinking and another when you finish
- Only announces in group instances (dungeons and raids) so you don't spam the world
- Supports multiple message pairs with random selection each session
- Configurable through the WoW addon settings panel

## Usage

### Slash Commands

- `/enn` — Open the settings panel
- `/enn say` — Toggle SAY announcements on/off
- `/enn chat` — Toggle local chat messages on/off

### Settings Panel

Open the settings panel with `/enn` or find **EatingNamNam** in the addon section of the game settings.

From there you can:

- **Enable/disable SAY announcements** — Toggle whether messages are sent in group instances.
- **Manage message pairs** — Each pair has a start message (sent when you begin eating) and a stop message (sent when you finish). Add as many pairs as you like; one is chosen at random each time. Use the **Add** button to create new pairs and the **X** button to remove them.

## Installation

Install via [wago.io](https://wago.io) using the Wago app, or manually extract the `EatingNamNam` folder into your `World of Warcraft/_retail_/Interface/AddOns/` directory.

## License

MIT
