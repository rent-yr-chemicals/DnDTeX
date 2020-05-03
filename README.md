# DnDTeX
A LaTeX class for generating nicely formatted D&amp;D 5E character sheets.

This is very much a work in progress. Most of the internals are designed poorly and haphazardly. Expect things to break.

# Installing
To use this package, you'll need the `charactersheet5e.cls` class file, and the `gforeach.sty` and `statcalc.sty` modules. Download them, put them in your project directory; put them in your distro's package directory if you want them available globally—y'all are smart, you can figure it out.

Additionally, you'll probably want some nicer fonts, since LaTeX's default doesn't look great here. I've used Source Sans Pro for the samples and included the font files in this repository, but use whatever you like. Font support is through the `fontspec` [package](https://ctan.org/pkg/fontspec?lang=en), so you'll need to compile with LuaLaTeX or XeLaTeX. I've only tried LuaLaTeX, but XeLaTeX should also work in theory. Again: y'all are smart, you'll figure it out.

Lastly, and most importantly, you'll need the blank 5E character sheet to use as a backdrop. This package *only* lays out content on top of the blank character sheet (and automates some calculations), you'll need to supply the blank one on your own. I haven't included one in this repository (since I'm not entirely clear on how Wizards of the Coast's copyright applies here), but they're freely available on [their official website](https://dnd.wizards.com/products/tabletop-games/trpg-resources/trpg-resources). Click "Fifth Edition Character Sheets" to download a zip archive with a few sheets, and find the one called "DnD_5E_CharacterSheet - Form Fillable.pdf".

The sample I've included assumes the project directory includes a "resources" subdirectory with the font files and a blank character sheet called "background.pdf". If that doesn't make you happy, feel free to put them wherever you like, just change the appropriate lines in your `.tex` file.

# Usage
The basic document format is
```latex
\documentclass{charactersheet5e}
\BackgroundImage{path/to/blank/character/sheet.pdf}

\newfontfamily{\altsffamily}{YourFont}
\newfontfamily{\altsffamilysemi}{YourFont Semibold Version} % optional but recommended

% ...
% Character info commands... (see below)
% ...

\begin{document}
\MakeCharacterSheet
\end{document}
```
The only commands that are *strictly* necessary are `\BackgroundImage` and `\MakeCharacterSheet`—as long as these are present, the document should compile (though it won't be very interesting). The rest of the preamble contains commands to define your character traits (name, class, stats, equipment, etc.). Skimming through the sample sheet should give a decent sense of things; read below for more detailed information.

**Note**: due to TikZ's positioning protocols, you'll need to compile twice for any content to be displayed.

## Commands
### Setup and Formatting

* `\BackgroundImage{<path to blank character sheet>}`: Specifies the background file. Path syntax is the same as `\includegraphics`: accepts a relative or absolute path, absolute paths must be enclosed in an extra set of braces

* Fonts: Specified with `fontspec`. The class uses a mix of LaTeX's default sans-serif font (for the extra-large, bold numbers) and an alternate user-defined font (for basically everything else). The user font is called as `\altsffamily` (normal, bold, italic, bold-italic) and `altsffamilysemi` (semibold, used for some extra-large text like the character name). For the most part, fields will choose their font automatically, no user action necessary—the user just needs to define these families at the beginning of the document (see sample sheet). If no font definition is provided, the class will fall back on the default sans-serif font.

### Basic Character Details

These should all be pretty self explanatory:

* `\CharacterName{<name>}`
* `\Level{<value>}`
* `\Class{<character class>}`
* `\Background{<character background>}`
* `\Race{<character race>}`
* `\Alignment{<character alignment>}`
* `\PlayerName{<name>}`
* `\ExperiencePoints{<value>}`

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
* `\ProficientSave{<ability name>}`: Tells the program which saving throws you're proficient in. Valid arguments are `STR`, `DEX`, `CON`, `INT`, `WIS`, and `CHA`. Call this once for each saving throw with proficiency.
* `\ProficientSkill{<skill name>}`: Operates like `\ProficientSave`; tells the program which skills you're proficient in. Call once for each skill with proficiency.
* `\SkillBonus{<skill name>}{<value>}`: Any additional modifier (positive or negative) to add to a skill. This is added on top of ability modifiers and (if applicable) proficiency bonus.

After calling the above, all skill modifiers will be calculated automatically.

For `\ProficientSkill` and `\SkillBonus`, valid arguments are:

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
  * Skill names are case sensitive—`Acrobatics` is valid, but not `acrobatics`.
  * Skill names are *not* space-sensitive. All spaces are ignored, so `AnimalHandling` and `Animal Handling` are equally valid.
  * There is one exception to the case-sensitive rule: `SleightofHand` is valid as well as `SleightOfHand` (and therefore also `Sleight of Hand` and `Sleight Of Hand`). There's absolutely no good reason for this besides code aesthetics.

`\SkillBonus` supports automatic parsing of formulas and stat names. So, for example, calling
```latex
\ProficientSkill{Stealth}
\SkillBonus{Stealth}{Proficiency}
```
adds a *double* Proficiency bonus to the Stealth modifier (once from `\ProficientSkill` and once from `\SkillBonus`). Likewise, calling
```latex
\ProficientSkill{Animal Handling}
\SkillBonus{Animal Handling}{Proficiency+3}
```
adds Proficiency+Proficiency+3 to Animal Handling.

A number of other commands support this mechanic as well; see later for more detailed documentation.

### Passive Wisdom
* `\PassiveWisdom{<value>}`: Sets the passive wisdom score. This should generally just be 10+Perception, but the command is here in case you want to change that for some reason. Supports automatics stat/formula parsing, so feel free to just call `\PassiveWisdom{10+Perception}` and forget about it.

### Inspiration
* `\Inspiration{<true/false>}`: Whether your character has inspiration. Calling with `true` (case-insensitive) will place a mark in the "Inspiration" box; *any* other argument (or an empty argument) will evaluate to false and give no mark.

### Combat Stats
Initiative is calculated automatically from the dexterity modifier. Commands for other combat stats are:

* `\ArmorClass{<value>}`: Sets the armor class. Supports automatic stat/formula parsing.
* `\Speed{<value>}`: Sets the speed. Self explanatory.
* `\HitPoints{<current value>}{<max value>}`: Sets the character's hit points. Can be omitted or arguments can be empty, in which case nothing will be printed.
* `\TemporaryHitPoints{<value>}`: Sets temporary hit points. Nothing will be printed if omitted, or if `<value>` is empty or 0.
* `\HitDice{<hit dice>}{<total>}`: Sets the hit dice.
* `\DeathSaveSuccesses{<value>}`: The current number of successful death saving throws
* `\DeathSaveFails{<value>}`: The current number of failed death saving throws

### Weapons
* `\Weapon{<weapon name>}{<attack bonus>}{<damage>}{<damage type>}`: Adds a weapon in the "Attacks & Spellcasting" box. The `<attack bonus>` field supports automatic stat/formula parsing.
 
`\Weapon` can be called multiple times; weapons will be printed in the order they are called. The official character sheet from Wizards of the Coast only includes three weapon boxes. However, `\Weapon` *can* be called more than three times; in this case, additional boxes will be drawn, and any content in the text box below (`\AttackAndSpellcasting`) will automatically be shifted downwards to compensate.

### Money
Coin values are set with:

* `\CopperPieces{<value>}`
* `\SilverPieces{<value>}`
* `\ElectrumPieces{<value>}`
* `\GoldPieces{<value>}`
* `\PlatinumPieces{<value>}`

Commands can be called with an empty argument or omitted entirely; in either case, the displayed value defaults to zero.

### Other - Page One
The rest of the fields on page one ("Equipment", "Features & Traits", etc.) are "text box" fields. Each one corresponds to a TikZ node at the appropriate place on the page; arguments are simply passed "as-is" to each node. Put pretty much anything you want in here.

* `\OtherProficienciesAndLanguages{<content>}`
* `\AttacksAndSpellcasting{<content>}`
* `\Equipment{<content>}`
* `\PersonalityTraits{<content>}`
* `\Ideals{<content>}`
* `\Bonds{<content>}`
* `\Flaws{<content>}`

As noted above, content in the "Attacks & Spellcasting" box will automatically be shifted downwards if more than three weapons are added with `\Weapon`.

`\Equipment` spans the entire width of the box, including the part covered up by the coin boxes. To avoid overlap, enclose the narrower part in the `indented` environment:
```latex
\Equipment{%
    \begin{indented}
        This is narrower text, it fits next to the coin values.
    \end{indented}
    This is full-width text, it fits underneath the coin values at the bottom of the box.
}
```
See the sample sheet for example usage.

### Page Two - Character Appearance

Fields describing the character appearance at the top of page two are:

* `\Age{<age>}`
* `\Height{<height>}`
* `\Weight{<weight>}`
* `\Eyes{<eyes>}`
* `\Skin{<skin>}`
* `\Hair{<hair>}`

The larger "Character Appearance" box is defined with:

* `CharacterAppearance{<content>}`

`<content>` can be pretty much anything. In addition to text, it supports `\includegraphics` and, for the artistically inclined, TikZ pictures. By default, font formatting here may not match the rest of the document, so you might need to set it back to the correct font (presumably `\altsffamily`) manually.

### Page Two - Other

The rest of the fields on page two are text boxes; rules are the same as described above under "Other - Page One":

* `\Backstory{<content>}`
* `\AlliesAndOrganizations{<content>}`
* `\AdditionalFeaturesAndTraits{<content>}`
* `\Treasure{<content>}`

Additionally, `\AlliesAndOrganizations` can be called with the following optional arguments:

* `\AlliesAndOrganizations[Name]{<name>}`
* `\AlliesAndOrganizations[Symbol]{<content>}`

These fill out the "Symbol" inset in the "Allies & Organizations" box. When called with `[Symbol]`, `<content>` supports all the same features as `\CharacterAppearance` described above—text, graphics, TikZ pictures, etc.

Note that, unlike the "Equipment" box on page one, text in the "Allies & Organizations" box *will* wrap around the "Symbol" inset automatically.

### Page Three - Spellcasting

Basic spellcasting stats at the top of page three are:

* `\SpellcastingClass{<class>}`
* `\SpellcastingAbility{<ability>}`: Valid arguments are `STR`, `DEX`, `CON`, `INT`, `WIS`, and `CHA`.

Spell Save DC and Spell Attack Bonus are calculated automatically from Spellcasting Ability.

Spells are added with:

* `\Cantrip{<text>}`: Adds a cantrip.
* `\Spell{<level>}{<text>}{<prepared>}`: Adds a spell at the specified level. Valid arguments for `<level>` are `Level One`, `Level Two`, ..., `Level Nine` (case-sensitive, space-sensitive). `<prepared>` fills in the "prepared" marks next to each spell. An argument of either `true` or `prepared` (not case-sensitive) will fill in the mark; any other value (including an empty argument) will leave the mark blank.

The class assumes each spell/cantrip only occupies one line. If you need more than one line per spell, you'll need to deal with it manually.

Spell slots are set with:

* `\SpellSlots{<level>}{<total>}{<remaining>}`: Sets the slots at the specified level. Valid arguments for `<level>` are the same as for `\Spell`. Draws `<total>` spell slot markers, with `<remaining>` drawn boldly and the rest grayed-out.

### Miscellaneous Tools

A few additional commands are included for formatting convenience. They're not necessary, but use them if you want them.

* `conditions`: A list environment for indicating when a particular attack/effect/etc. applies. Seen in the sample sheet under "Sneak attack". Example:
```latex
Do this thing if:
\begin{conditions}
    \item Something is true
    \item Something else is true
    \item ...
\end{conditions}
```

* `feature`: A list environment for class/race/background features. Seen in the sample sheet in the "Features & Traits" box. Example:
```latex
\begin{feature}{A Class Feature}
    \item One of this feature's effects
    \item Another effect
    \item ...
\end{feature}
```

* `\spacer[<dimension>]`: Prints a gray, horizontal line; nice for separating fields within text boxes. Seen in the sample sheet under "Equipment" and "Other Proficiencies & Languages". The optional `<dimension>` argument sets the vertical space after the spacer; default is `0.35ex`.

* `\plus` and `\minus`: Formatted + and - signs for stat modifiers. LaTeX's default +/- look too big when they're not inside an equation; these sometimes look better. Use to taste.

## Automatic Formula and Stat Parsing
A few commands can automatically parse formulas in their arguments, as well as automatically recognize the names of stats and substitute these for the corresponding values. Commands with this ability built in are:

* `\SkillBonus`
* `\PassiveWisdom`
* `\ArmorClass`
* `\Weapon`: 2nd argument (Attack Bonus) only

In addition to these commands, the `\calculate` macro is available if you'd like to use this capability anywhere else in the document. Usage is:

* `\calculate{<formula>}`: evaluates `<formula>` and prints the result.
* `\calculate*{<formula>}{<macro>}`: evaluates `<formula>` and stores the result in `<macro>`; nothing is printed.

The un-starred version should work in *most* parts of the document; due to its horrifyingly insane design, it will break occasionally. I haven't tested every possible command/environment, but I've confirmed that it doesn't work inside `\Spell` or `\Cantrip`. In these cases, use the starred version outside the offending command, then insert the result:
```latex
% This will break:
\Spell{Level One}{...\calculate{<a formula>}...}{}

% Do this instead:
\calculate*{<a formula>}{\myresult}
\Spell{Level One}{...\myresult...}{}
```
These issues will hopefully be fixed at some point in a later update. Hopefully.

The command `\getstat` is also available as an alias to `\calculate`; the two are functionally identical in every way. I'm not sure why I included it, but if you think one makes for more aesthetic code than the other, the choice is there.

### Syntax
Recognized stat names are:

* Abilities (score and modifiers, respectively):
  * `STR`, `STR mod`
  * `DEX`, `DEX mod`
  * `CON`, `CON mod`
  * `INT`, `INT mod`
  * `WIS`, `WIS mod`
  * `CHA`, `CHA mod`
* Skills:
  * `Acrobatics`
  * `Animal Handling`
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
  * `Sleight Of Hand` or `Sleight of Hand`
  * `Stealth`
  * `Survival`
* Proficiency bonus: `Proficiency`

Names are case-sensitive. All spaces are ignored.

Internally, calculations are performed with the `pgfmath` package. As such, all mathematical operations supported there *should* be supported here as well. At the very least, this includes basic arithmetic (`+`,`-`,`*`,`/`) and `min`/`max` functions. I can't think of any reason why you'd *need* to get more complicated than that, but if you *really want* to calculate, say, the hyperbolic cosine of your stealth modifier, you should be able to. For a full list of (theoretically) supported functions, see the official [PGF/TikZ documentation](http://ctan.math.washington.edu/tex-archive/graphics/pgf/base/doc/pgfmanual.pdf), pp. 697–709.

Example usage:
```latex
\DEX{16} % -> DEX mod = 3
\Proficiency{2}

\calculate{DEX mod + Proficiency} % = 5
\calculate{DEXmod+Proficiency} % equally valid, maybe less readable?

\calculate{12 + min(DEX mod,2)} % = 14

\calculate{sqrt(factorial(DEX mod)) + cosh(Proficiency)/pi} % = 3

\calculate*{DEX mod + 7}{\myresult} % ...
\myresult % prints 10
```

**Note**: By default, all calculations are performed as floating-point, then the final result is rounded **down** to the nearest integer. If you'd rather round up or to the nearest integer, wrap your formula in `ceil(...)` or `round(...)` respectively. There's currently no way to return a floating point value, although I can't think of why you'd need to.

# License
All code in this repository is licensed under the WTFPL Version 2. Do whatever y'all want.

Source Sans Pro font files are shared under the [SIL Open Font License Version 1.1](http://scripts.sil.org/OFL).

This repository and its author are not affiliated with, endorsed, sponsored, or specifically approved by Wizards of the Coast LLC. Wizards of the Coast, Dungeons & Dragons, and their logos are trademarks of Wizards of the Coast LLC in the United States and other countries. © 2015 Wizards. All Rights Reserved. For more information about Wizards of the Coast or any of Wizards' trademarks or other intellectual property, please visit their website at www.wizards.com.
