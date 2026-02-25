# EatingNamNam

> This project is utter vibe coded nonsense.

A World of Warcraft addon that announces when you start and stop eating or drinking in group instances.

## Features

- Detects food, drink, and combined food & drink buffs on your character
- Sends a SAY message when you start eating/drinking and another when you finish
- Only announces in group instances (dungeons and raids) so you don't spam the world
- Supports multiple message pairs with random selection each session
- Messages are capped at 255 characters
- Pairs with empty start or stop messages are skipped
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
- **Manage message pairs** — Each pair has a start message (sent when you begin eating) and a stop message (sent when you finish). Add as many pairs as you like; a valid one is chosen at random each time. Use the **Add** button to create new pairs and the **X** button to remove them. Press Enter to save an edit, Escape to revert.

## Installation

Install using the [Wago app](https://addons.wago.io/addons/eatingnamnam).

## License

MIT
