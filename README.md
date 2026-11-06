# Minimap Stats

A small World of Warcraft: Forever addon (interface 16001) that adds an FPS, latency and durability line under the minimap's coordinate text:

```
62.0 fps  ·  45ms/52ms  ·  Dur 87%
```

It's meant as a lightweight replacement for Titan Panel's Performance and Repair plugins, for anyone using Forever's default UI without Titan Panel.

## What it shows

- **FPS:** to one decimal place. Red below 20, yellow from 20 to 29, green at 30 and up.
- **Latency:** home/world in milliseconds. Green below 300, yellow from 300 to 599, red at 600 and up.
- **Durability:** total durability of your equipped gear, i.e. the sum of current durability divided by the sum of maximum durability across every equipped item (the same calculation TitanRepair uses).

FPS and latency refresh once a second. Durability refreshes only when your durability or equipment changes.

The colour thresholds match Titan Panel's defaults.

## Settings

Open **Options → AddOns → Minimap Stats**, or type `/mstats`. Each of the three readouts has its own checkbox. All are on by default, and changes apply immediately and are saved per account.

## How it attaches

Forever's coordinate text is `MinimapCluster.MinimapContainer.PlayerCoords`. Blizzard rewrites it every 0.1 seconds, so this addon doesn't touch it. Instead it adds its own text anchored just below, in the same font. Blizzard's frame is never modified, so there's no taint risk, and the line follows the minimap if you move or resize it in Edit Mode.

If the coordinate frame isn't found, the line falls back to sitting under the minimap.

## Install

Copy the `MinimapStats` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then restart the game or `/reload`.
