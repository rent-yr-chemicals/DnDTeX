# DnDTeX
A LaTeX class for generating nicely formatted D&amp;D 5E character sheets.

This is very much a work in progress. Most of the internals are designed poorly and haphazardly. Expect things to break.

# Installing
To use this package, you'll need the `charactersheet5e.cls` class file, and the `gforeach.sty` and `statcalc.sty` packages. Download them, put them in your project directory; put them in your distribution's package directory if you want them available globally—y'all are smart, you can figure it out.

Additionally, you'll probably want some nicer fonts, as LaTeX's default sans-serif doesn't look great here. I've used Source Sans Pro for the samples, and included the font files in this repository, but use whatever you like. Font support is through the `fontspec` [package](https://ctan.org/pkg/fontspec?lang=en), so you'll need to compile with LuaLaTeX or XeLaTeX. I've only tried LuaLaTeX, but XeLaTeX should also work in theory. Again: y'all are smart, you'll figure it out.

Lastly, and most importantly, you'll need the blank 5E character sheet to use as a backdrop. This package *only* lays out content on top of the blank character sheet (and automates some calculations), you'll need to supply the blank one on your own. I haven't included one in this repository, as I'm not entirely clear on how Wizards of the Coast's copyright applies here, but they're freely available on [their official website](https://dnd.wizards.com/products/tabletop-games/trpg-resources/trpg-resources). Click "Fifth Edition Character Sheets" to download a zip archive with a few sheets, and find the one called "DnD_5E_CharacterSheet - Form Fillable.pdf".

The sample I've included assumes that the project directory contains a "resources" subdirectory with the font files and a blank character sheet called "background.pdf". If that doesn't make you happy, feel free to put them wherever and call them whatever you like, just change the appropriate lines in your `.tex` file.

# Usage
...

# License
All code in this repository is licensed under the WTFPL Version 2. Do whatever y'all want.

Source Sans Pro font files are shared under the [SIL Open Font License Version 1.1](http://scripts.sil.org/OFL).

This repository and its author are not affiliated with, endorsed, sponsored, or specifically approved by Wizards of the Coast LLC. Wizards of the Coast, Dungeons & Dragons, and their logos are trademarks of Wizards of the Coast LLC in the United States and other countries. © 2015 Wizards. All Rights Reserved. For more information about Wizards of the Coast or any of Wizards' trademarks or other intellectual property, please visit their website at www.wizards.com.
