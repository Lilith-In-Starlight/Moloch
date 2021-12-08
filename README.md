# Moloch
![logo](https://user-images.githubusercontent.com/56773311/133911301-11890dbc-70ca-4ebd-bc92-5d5ac83ebf82.png)

*In any system optimizing for X, the opportunity arises to throw any value under the bus for optimized X.*

Moloch is the roguelike of all the horrible futures. Instead of health points, the player's human (or otherwise applicable) conditions are (somewhat) simulated to make for a fleshly experience. Fell from too high? I sure hope you don't need those knees!

You are a child who was sacrificed by your parents to the god at the top of The Ancient Tower. The tradeoff is simple: Throw away what you love most, and I can give you power. You refuse to let yourself be murdered by the people and the creatures inhabiting the tower, and in a desperate attempt to survive, you begin your ascent.

If you like this project you can join it's [Discord Server](discord.com/invite/aYZ3K5FDQ3)

Please scroll to the bottom if you're a Mac user and you're getting the "file is broken you should throw it to the bin" error

## Controls

- **Movement:** WASD
- **Jump:** Space
- **Open chests, pick up items:** S
- **Hold onto poles:** W, S
- **Use wand:** Left click
- **Organize inventory:** Left click; right click to throw away
- **Change selected wand:** Numbers from 1 to 6; Scroll wheel
- **Display extra item information:** Shift
- **Instantly die:** G
- **Cover bleeding wounds:** R
- **Pause:** Escape

### Controller

- **Movement:** Left Stick
- **Jump:** L1
- **Open chests, pick up items:** Left Stick Down
- **Hold onto poles:** Xbox A, Sony X, DS B
- **Use wand:** R1
- **Move In Inventory:** D-PAD
- **Select Wand/Spell:** L2
- **Drop Wand/Spell:** R2
- **Instantly die:** Select and Pause at the same time
- **Cover bleeding wounds:** Xbox B, Sony Circle, DS A
- **Pause:** Pause

## Features
### A fleshly health system
Instead of health points, Moloch's health system is based on different kinds of conditions, some of which might not even kill you, but can make the game impossible to play. The clearest example is fall damage: In Moloch, when you fall from dangerous heights, you can lose your legs, rendering you unable to walk or jump for the rest of the run, and depending on how the run was going, this might mean you have to restart.

This is done for every entity, not only the player.

### Fuck Around And Find Out
In Moloch, the only permanent upgrade you have between runs is knowledge about the consequences of your actions. Also the consequences of actions that are unrelated to you. One way to learn is by having other people help you understand things. The other is messing with things and seeing what your brand new kind of death looks like.
 
### Custom wands
Moloch allows you to collect spells, letting you move them from wands and create your ultimate weapon of mass destruction. Careful, though! Some spells generate heat, which might give you a heat stroke. There are also different modifiers that let you make your wands more powerful and more dangerous, just place one before the spells it'll affect and watch chaos unfold.

### Destructible levels
Mostly everything can be destroyed if you have the right spells for it. Mostly. This means that, with the right equipment, nothing stops you from skipping rooms entirely or digging out of the world and miserably ending your run by falling to the void.

## Code Documentation
Under the hood, Moloch does weird stuff with classes to keep everything tidy and separate (this kind of thing is why spells and wands can be used by entities other than the player). If you want to know how this weird stuff works, here's a hopefully-not-so-outdated documentation: https://hackmd.io/@katie-and/HJlqEQMVK/https%3A%2F%2Fhackmd.io%2F%40katie-and%2FBJ4uZQMVF

## License
The MIT license only applies to the source code. The visual assets are licensed under [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). Licenses for the sound effects are stated in AUDIO-LICENSES.md.

## Help, I'm having this weird issue on Mac
So, since apple sucks, it'll flag apps downloaded form the internet with an extended attribute so it can ask you if you trust the file you're about to run. And then fail to ask you if you want to run it. Simply run `xattr -cr [path to moloch]` in the command line and that should do the trick.
