# DnDTeX
A LaTeX class for generating nicely formatted D&amp;D 5E character sheets.

This is very much a work in progress. Most of the internals are designed poorly and haphazardly. Expect things to break.

# Installing
To use this package, you'll need the `charactersheet5e.cls` class file, and the `gforeach.sty` and `statcalc.sty` packages. Download them, put them in your project directory; put them in your distribution's package directory if you want them available globally—y'all are smart, you can figure it out.

Additionally, you'll probably want some nicer fonts, as LaTeX's default sans-serif doesn't look great here. I've used Source Sans Pro for the samples, and included the font files in this repository, but use whatever you like. Font support is through the `fontspec` [package](https://ctan.org/pkg/fontspec?lang=en), so you'll need to compile with LuaLaTeX or XeLaTeX. I've only tried LuaLaTeX, but XeLaTeX should also work in theory. Again: y'all are smart, you'll figure it out.

Lastly, and most importantly, you'll need the blank 5E character sheet to use as a backdrop. This package *only* lays out content on top of the blank character sheet (and automates some calculations), you'll need to supply the blank one on your own. I haven't included one in this repository, as I'm not entirely clear on how Wizards of the Coast's copyright applies here, but they're freely available on [their official website](https://dnd.wizards.com/products/tabletop-games/trpg-resources/trpg-resources). Click "Fifth Edition Character Sheets" to download a zip archive with a few sheets, and find the one called "DnD_5E_CharacterSheet - Form Fillable.pdf".

The sample I've included assumes that the project directory contains a "resources" subdirectory with the font files and a blank character sheet called "background.pdf". If that doesn't make you happy, feel free to put them wherever and call them whatever you like, just change the appropriate lines in your `.tex` file.

# Usage
The basic document format is
```latex
\documentclass{charactersheet5e}
\BackgroundImage{path/to/blank/character/sheet.pdf}

\newfontfamily{\altsffamily}{YourFont}
\newfontfamily{\altsffamilysemi}{YourFont Semibold Version} % optional but suggested

% ...
% Character info commands... (see below)
% ...

\begin{document}
\MakeCharacterSheet
\end{document}
```
The only commands that are *strictly* necessary to include are `\BackgroundImage` and `\MakeCharacterSheet`—as long as these are present, the document should compile (though it won't be very interesting). The rest of the preamble will contain commands to define various character traits (name, class, stats, equipment, etc.). Skimming through the sample sheet should give a decent sense of things; read below for more detailed information.

## Commands
### Setup and Formatting

* `\BackgroundImage{<path to blank character sheet>}`: Specifies the background file. Path syntax is the same as `\includegraphics`: accepts a relative or absolute path, absolute paths must be enclosed in an extra set of braces

* Fonts: specified with `fontspec`. The class uses a mix of LaTeX's default sans-serif font (for the extra-large, bold numbers) and an alternate, user-defined font (for basically everything else). The user-defined font is specified as `\altsffamily` (normal, bold, italic, bold-italic) and `altsffamilysemi` (semibold, looks better for some extra-large text). For the most part, fields using `\altsffamily` will do so automatically with no user action necessary; however, the user still needs to define these families at the beginning of the document. If no definition is provided, the class simply falls back on the default sans-serif.

### Basic Character Details

These should all be pretty self explanatory.

* `\CharacterName{<name>}`
* `\Level{<level number>}`
* `\Class{<character class>}`
* `\Background{<character background>}`
* `\Race{<character race>}`
* `\Alignment{<character alignment>}`
* `\PlayerName{<your name>}`
* `\ExperiencePoints{<points>}`

### Ability Scores

* `\STR{<strength score>}`
* `\DEX{<dexterity score>}`
* `\CON{<constitution score>}`
* `\INT{<intelligence score>}`
* `\WIS{<wisdom score>}`
* `\CHA{<charisma score>}`

It's not necessary to define the ability modifiers; these are calculated automatically.

### Proficiency, Skills, Saving Throws

These are largely done automatically. Necessary user input is:

* `\Proficiency{<value>}`: Defines your proficiency bonus
* `\ProficientSave{<ability name>}`: Tells the program which saving throws you're proficient in. The argument is one of: `STR`, `DEX`, `CON`, `INT`, `WIS`, `CHA`. Call this once for each saving throw with proficiency.
* `\ProficientSkill{<skill name>}`: Operates like `\ProficientSave`; tells the program which skills you're proficient in. Call once for each skill with proficiency.
* `\SkillBonus{<skill name>}{<value>}`: Any additional modifier (positive or negative) to add to a skill. This is added on top of ability modifiers and (if applicable) proficiency bonus.

After calling the above, all skill modifiers will be calculated for the user.

For `\ProficientSkill` and `\SkillBonus`, accepted skill names are:

* `Acrobatics`
* `AnimalHandling`
* `Arcana`
* `Athletics`
* `Deception`
* `History`
* `Insight`
* `Intimidation`
* `Investigation`
* `Medicine`
* `Nature`
* `Perception`
* `Performance`
* `Persuasion`
* `Religion`
* `SleightOfHand`
* `Stealth`
* `Survival`

#### Note:
  * Skill names are case sensitive—`Acrobatics` is accepted, but not `acrobatics`.
  * Skill names are *not* space-sensitive. All spaces are ignored, so `AnimalHandling` and `Animal Handling` are equally acceptable.
  * There is one exception to the case-sensitive rule: `SleightofHand` is accepted as well as `SleightOfHand` (and therefore also `Sleight of Hand` and `Sleight Of Hand`). There's no good reason for this besides code aesthetics.

`\SkillBonus` supports automatic parsing of equations and stat names. So, for example, calling
```latex
\ProficientSkill{Stealth}
\SkillBonus{Stealth}{Proficiency}
\ProficientSkill{Animal Handling}
\SkillBonus{Stealth}{Proficiency+3}

```
adds a *double* proficiency bonus to the Stealth modifier, and (obviously, maybe) double proficiency plus 3 to Animal Handling. A number of other commands support this mechanic as well; see later for more detailed documentation.

### Passive Wisdom
* `\PassiveWisdom{<value>}`: Sets the passive wisdom score. This should generally just be 10+Perception, but the command is here in case you want to change that for some reason. Supports automatics stat/equation parsing, so feel free to just call `\PassiveWisdom{10+Perception}` and forget about it.

### Inspiration
* `\Inspiration{<true/false>}`: Whether your character has inspiration. Calling with `true` (case-insensitive) will place a mark in the "Inspiration" box; *any* other argument (or an empty argument) will evaluate to false, and give no mark.

### Combat Stats
Initiative is calculated automatically from the dexterity modifier. Commands for other combat stats are:
* `\ArmorClass{<value>}`: Sets the armor class. Supports automatic stat/equation parsing.
* `\Speed{<value>`: Sets your speed. Self explanatory.
* `\HitPoints{<current HP>}{<max HP>}`: Sets the characters hit points. Can be left blank, in which case nothing will display on the final character sheet.
* `\TemporaryHitPoints{<current>}{<max>}`: Same as `\HitPoints`, but for the Temporary Hit Points box.
* `\HitDice{<hit dice>}{<total>}`: Sets the hit dice.
* `\DeathSaveSuccesses{<number>}`: The current number of successful death saving throws
* `\DeathSaveFails{<number>}`: The number of failed death saving throws

### Weapons
* `\Weapon{<weapon name>}{<attack bonus>}{<damage>}{<damage type>}`: Adds a weapon in the "Attacks and Spellcasting" box. The <attack bonus> field supports automatic stat/equation parsing.
 
`\Weapon` can be called multiple times, and weapons will be added to the character sheet in the order they are called. The official blank character sheet from Wizards of the Coast only includes three weapon boxes. However, `\Weapon` *can* be called more than three times; in this case, additional boxes will be drawn, and any text in below the weapon boxes in "Attack and Spellcasting" will be shifted downwards to compensate.

### Money
The player's coins are defined with:

* `\CopperPieces{<value>}`
* `\SilverPieces{<value>}`
* `\ElectrumPieces{<value>}`
* `\GoldPieces{<value>}`
* `\PlatinumPieces{<value>}`

Commands can be called with an empty argument, or omitted entirely; in either case, the displayed value defaults to zero.

# License
All code in this repository is licensed under the WTFPL Version 2. Do whatever y'all want.

Source Sans Pro font files are shared under the [SIL Open Font License Version 1.1](http://scripts.sil.org/OFL).

This repository and its author are not affiliated with, endorsed, sponsored, or specifically approved by Wizards of the Coast LLC. Wizards of the Coast, Dungeons & Dragons, and their logos are trademarks of Wizards of the Coast LLC in the United States and other countries. © 2015 Wizards. All Rights Reserved. For more information about Wizards of the Coast or any of Wizards' trademarks or other intellectual property, please visit their website at www.wizards.com.
