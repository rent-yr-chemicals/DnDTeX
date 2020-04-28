\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{charactersheet5e}

%\ifx\directlua\@undefined\ClassError{charactersheet5e}{Error - LuaLaTeX required for font support}{}\stop\fi

\LoadClass[12pt]{article}

\RequirePackage[ansiapaper,left=0in,right=0in,top=0in,bottom=0in,nohead,nofoot]{geometry}

\RequirePackage{eso-pic}							%Background
\RequirePackage{graphicx}							%Background, general utility
\RequirePackage[contents={},opacity=0]{background}	%Background
\RequirePackage{fontspec}							%Font controls

\RequirePackage{tikz}
	\usetikzlibrary{shapes.geometric}
	\usetikzlibrary{calc}
	\usetikzlibrary{decorations.pathmorphing}
	
\RequirePackage{wrapfig}								%Figures inside nodes
\RequirePackage{textcomp}

\RequirePackage{xcolor}							%Colored text
\RequirePackage{enumitem}							%Environments for features, etc.
\RequirePackage{amsmath,amsbsy,textcomp}			%Honestly? No idea, but I probably put it here for a reason

% Custom Packages

\RequirePackage{gforeach}
\RequirePackage{statcalc}

% Font stuff

\renewcommand{\familydefault}{\sfdefault}

\AtBeginDocument{%
\@ifundefined{altsffamily}{\let\altsffamily\relax}{\relax}
\@ifundefined{altsffamilylight}{\let\altsffamilylight\relax}{\relax}
\@ifundefined{altsffamilysemi}{\let\altsffamilysemi\relax}{\relax}
}

% Formatting

\pagestyle{empty}

\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\baselineskip}{2pt}

% Background
	
\newcommand{\backgroundimage}[4][]{
	\edef\background@xoffset{#2}
	\edef\background@yoffset{#3}
	\put(\background@xoffset,\background@yoffset){
		\parbox[b][\paperheight]{\paperwidth}{%
			\vfill
			\centering
			\includegraphics[width=\paperwidth,height=\paperheight,#1]{#4}
			\vfill
		}
	}
}

\newcommand{\drawbackgroundgrid}{ %%% GRID FOR SETTING UP TIKZ NODES, IGNORE %%%
	\backgroundsetup{%
		position={0,0},opacity=\background@gridopacity,placement=center,angle=0,scale=1,contents={%
			\begin{tikzpicture}
				\draw[step=1in, line width=1.5pt, black] (0cm,0cm) grid (\paperwidth,\paperheight);
				\draw[help lines, step=0.25in,ultra thin] (0cm,0cm) grid (\paperwidth,\paperheight);
			\end{tikzpicture}
		}
	}
	\BgThispage
}

\def\drawbackground{\@ifstar{\drawbackground@star}{\drawbackground@nostar}}
\newcommand{\drawbackground@star}[4][]{\def\background@gridopacity{0.2}\drawbackground@main[#1]{#2}{#3}{#4}}
\newcommand{\drawbackground@nostar}[4][]{\def\background@gridopacity{0.0}\drawbackground@main[#1]{#2}{#3}{#4}}


\newcommand{\drawbackground@main}[4][]{
	\AddToShipoutPicture*{\backgroundimage[#1]{#2}{#3}{#4}}
	\drawbackgroundgrid
	\BgThispage
}

\def\@backgroundimage@path{background.pdf}
\newcommand{\BackgroundImage}[1]{\def\@backgroundimage@path{#1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	MISC FORMATTING TOOLS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\DeclareRobustCommand{\plus}{\raisebox{.4\height}{\scalebox{.6}{+}}}
\DeclareRobustCommand{\minus}{\raisebox{.4\height}{\scalebox{.8}{-}}}

\DeclareRobustCommand{\fmod}[1]{%
	%
	\count255=#1%
	\relax%
	\ifnum\count255<0%
		\multiply\count255 by -1%
		-%
	\else%
		\plus%
	\fi%
	\the\count255%
}

\newcommand{\spacer}[1][1pt]{{\color{black!20}\vspace{-3.5pt}\hrulefill}\par\vspace{#1}}

\newenvironment{feature}[1]{%
	{\bfseries #1}
	\begin{itemize}[
				topsep=0.75ex,
				itemsep=0.5ex,
				itemindent=0pt,
				parsep=0pt,
				labelindent=0pt,
				labelwidth=1em,
				labelsep=0.5em,
				leftmargin=1em
	]
}%
{%
	\end{itemize}
	\vspace{2pt}
}

\newenvironment{conditions}{%
	\begin{enumerate}[
		topsep=1ex,
		itemsep=0.75ex,
		parsep=0pt,
		leftmargin=1.5em,
		labelsep=0.3em,
		label={\upshape\alph*\hspace{0.5pt})}
	]
}%
{%
	\end{enumerate}
}

\newenvironment{indented}[1][0.62in]{%
	\hfill\begin{minipage}[t]{\dimexpr\textwidth-0.62in}\raggedright%
}%
{%
	\xdef\tpd{\the\prevdepth}
	%
	\end{minipage}
	
	\prevdepth\tpd	%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	COMMANDS FOR CHARACTER STATS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\@CharacterName{}
\def\@Class{}
\def\@Level{}
\def\@Background{}
\def\@PlayerName{}
\def\@Race{}
\def\@Alignment{}
\def\@ExperiencePoints{}

\newcommand{\CharacterName}[1]{\def\@CharacterName{#1}}
\newcommand{\Class}[1]{\def\@Class{#1}}
\newcommand{\Level}[1]{\def\@Level{#1}}
\newcommand{\Background}[1]{\def\@Background{#1}}
\newcommand{\PlayerName}[1]{\def\@PlayerName{#1}}
\newcommand{\Race}[1]{\def\@Race{#1}}
\newcommand{\Alignment}[1]{\def\@Alignment{#1}}
\newcommand{\ExperiencePoints}[1]{\def\@ExperiencePoints{#1}}

%%% ABILITIES %%%

\def\@abilities{STR,DEX,CON,INT,WIS,CHA}

\newcommand{\def@ability}[2]{
	\expandafter\def\csname @#1\endcsname{#2}
	\pgfmathparse{int(floor((#2-10)/2))}
	\expandafter\edef\csname #1@mod\endcsname{\pgfmathresult}
	% initialize save proficiency to 0, overriden by calls to \ProficientSave
	\expandafter\edef\csname #1@save@proficiency\endcsname{0}
}

% \addstat uses \pgfkeys, which doesn't work inside a \foreach loop b/c of local scope, so we're
% getting around that using a (poorly) homebrewed global version \gforeach. there's absolutely
% a better way to do this, but I've sunk too much effort into this method to admit defeat and start fresh :P
\gforeach \@ability in \@abilities{
	\expandafter\edef\csname\@ability\endcsname##1{\expandafter\noexpand\expandafter\def@ability\expandafter{\@ability}{##1}}
	\addstat{\@ability}{\expandafter\noexpand\csname @\@ability\endcsname}
	\addstat{\@ability mod}{\expandafter\noexpand\csname\@ability @mod\endcsname}		
}

\STR{10}
\DEX{10}
\CON{10}
\INT{10}
\WIS{10}
\CHA{10}

\newcommand{\ProficientSave}[1]{
	\expandafter\gdef\csname #1@save@proficiency\endcsname{\@Proficiency}
}

%%% SKILLS %%%

%\def\@skills{%
%	Acrobatics/DEX,
%	AnimalHandling/WIS,
%	Arcana/INT,
%	Athletics/STR,
%	Deception/CHA,
%	History/INT,
%	Insight/WIS,
%	Intimidation/CHA,
%	Investigation/INT,
%	Medicine/WIS,
%	Nature/INT,
%	Perception/WIS,
%	Performance/CHA,
%	Persuasion/CHA,
%	Religion/INT,
%	SleightOfHand/DEX,
%	Stealth/DEX,
%	Survival/WIS%
%}

\def\@skills{%
	Acrobatics/DEX,
	AnimalHandling/WIS,
	Arcana/INT,
	Athletics/STR,
	Deception/CHA,
	History/INT,
	Insight/WIS,
	Intimidation/CHA,
	Investigation/INT,
	Medicine/WIS,
	Nature/INT,
	Perception/WIS,
	Performance/CHA,
	Persuasion/CHA,
	Religion/INT,
	SleightOfHand/DEX,
	Stealth/DEX,
	Survival/WIS%
}

\newcommand{\initialize@skill}[2]{
	\expandafter\xdef\csname#1@base@mod\endcsname{\expandafter\noexpand\csname#2@mod\endcsname}
	% initialize to 0, overriden by calls to \ProficientSkill and \SkillBonus
	\expandafter\xdef\csname#1@proficiency\endcsname{0}
	\expandafter\xdef\csname#1@bonus\endcsname{0}
}

% using \gforeach for \addstat again, see above
\gforeach \@skill/\@ability in \@skills{
	\addstat{\@skill}{%
		\expandafter\noexpand\csname\@skill @base@mod\endcsname%
		+\expandafter\noexpand\csname\@skill @proficiency\endcsname%
		+\expandafter\noexpand\csname\@skill @bonus\endcsname%
	}
	\initialize@skill{\@skill}{\@ability}
}

% just for aesthetics, "Sleight of Hand" looks nicer than "Sleight Of Hand"
\addstat{Sleight of Hand}{\noexpand\SleightOfHand@base@mod+\noexpand\SleightOfHand@proficiency+\noexpand\SleightOfHand@bonus}

\newcommand{\ProficientSkill}[1]{
	% silly unnecessary hack to strip spaces from argument
	% so we can say, e.g., \ProficientSkill{Sleight Of Hand} instead of \ProficientSkill{SleightOfHand}
	\statcalc@stripspaces{#1}{\arg@nospaces}
	% silly hack to accept "Sleight of Hand" for "Sleight Of Hand"
	\def\temp@SoH{SleightofHand}
	\ifx\arg@nospaces\temp@SoH
		\def\arg@nospaces{SleightOfHand}
	\fi
	\expandafter\def\csname\arg@nospaces @proficiency\endcsname{\@Proficiency}
}

\newcommand{\SkillBonus}[2]{
	% same silly hacks, see above
	\statcalc@stripspaces{#1}{\arg@nospaces}
	\def\temp@SoH{SleightofHand}
	\ifx\arg@nospaces\temp@SoH
		\def\arg@nospaces{SleightOfHand}
	\fi
	\calculate*{#2}{\@tempresult}
	\expandafter\edef\csname\arg@nospaces @bonus\endcsname{\@tempresult}
}

%%% PASSIVE WISDOM %%%
\def\@passive@wisdom{10}
\newcommand{\PassiveWisdom}[1]{\def\@passive@wisdom{\calculate{#1}}}

%%% INSPIRATION %%%

\newcommand{\Inspiration}[1]{
	\lowercase{\def\@temp{#1}}
	\def\@true{true}
	\ifx\@temp\@true
		\def\@Inspiration{black}
		\def\@Inspiration@Inner{gray}
	\else
		\def\@Inspiration{black!8}
		\def\@Inspiration@Inner{white}
	\fi
}

% Defaults in case \Inspiration is never called:
\def\@Inspiration{black!8}		
\def\@Inspiration@Inner{white}

%%% PROFICIENCY %%%

\def\@Proficiency{0}
\newcommand{\Proficiency}[1]{\def\@Proficiency{#1}}
\addstat{Proficiency}{\noexpand\@Proficiency}


%%% OTHER PROFICIENCIES %%%

\def\@Other@Proficiencies@and@Languages{}
\newcommand{\OtherProficienciesAndLanguages}[1]{\long\def\@Other@Proficiencies@and@Languages{#1}}

%%% COMBAT %%%

\def\@Armor@Class{0}
\def\@Speed{0}
\newcommand{\ArmorClass}[1]{\def\@Armor@Class{\calculate{#1}}}
\newcommand{\Speed}[1]{\def\@Speed{#1}}

\newcommand{\HitDice}[2]{
	\def\@Hit@Dice{#1}
	\def\@Hit@Dice@Total{#2}
}
\newcommand{\HitPoints}[2]{
	\def\@Hit@Points{#1}
	\def\@Hit@Points@Total{#2}
}

\newcommand{\TemporaryHitPoints}[2]{
	\def\@Temp@Hit@Points{#1}
	\def\@Temp@Hit@Points@Total{#2}
	\count255 = #1
	\ifnum\count255 > 0
		\def\@Temp@Hit@Points@Opacity{1.0}
	\else
		\def\@Temp@Hit@Points@Opacity{0.0}
	\fi
}

\HitDice{}{}
\HitPoints{}{}
\TemporaryHitPoints{0}{0}


\newcount\DeathSaveSuccess@count
\newcount\DeathSaveFail@count
\DeathSaveSuccess@count = 0
\DeathSaveFail@count = 0

\newcommand{\DeathSaveSuccesses}[1]{
	\DeathSaveSuccess@count = #1
}

\newcommand{\DeathSaveFails}[1]{
	\DeathSaveFail@count = #1
}

\DeathSaveSuccesses{0}
\DeathSaveFails{0}

\def\@Weapons{}

\newcommand\Weapon[4]{%
 	% \pgfmathparse breaks inside \edefs, so token registers needed to
 	% prevent premature expansion of stat lookups with \calculate or \get.
 	% probably could be avoided by refactoring code, but eh... it compiles.
	\newtoks\toks@oldlist
	\newtoks\toks@argone
	\newtoks\toks@argtwo
	\newtoks\toks@argthree
	\newtoks\toks@argfour
	
	\toks@oldlist=\expandafter{\@Weapons}
	\toks@argone=\expandafter{#1}
	\toks@argtwo=\expandafter{#2}
	\toks@argthree=\expandafter{#3}
	\toks@argfour=\expandafter{#4}
	
	\ifx\@Weapons\@empty
		\edef\@Weapons{{\the\toks@argone}/{\the\toks@argtwo}/{\the\toks@argthree}/{\the\toks@argfour}}
	\else
		\edef\@Weapons{\the\toks@oldlist,{\the\toks@argone}/{\the\toks@argtwo}/{\the\toks@argthree}/{\the\toks@argfour}}
	\fi
}

\def\@Attacks@and@Spellcasting{}
\newcommand{\AttacksAndSpellcasting}[1]{\long\def\@Attacks@and@Spellcasting{#1}}

%%% GEAR %%%

\def\@Equipment{}
\newcommand{\Equipment}[1]{\long\def\@Equipment{#1}}

\def\defcurrency#1#2{
	\def\temp{#2}
	\ifx\temp\empty
		\def#1{{\color{black!8}000}}
	\else
		\count255 = #2
		\ifnum\count255 > 99
			\def#1{#2}
		\else\ifnum\count255 > 9
			\def#1{{\color{black!8}0}#2}
		\else	\ifnum\count255 > 0
			\def#1{{\color{black!8}00}#2}
		\else
			\def#1{{\color{black!8}000}}
		\fi\fi\fi
	\fi
}

\newcommand{\CopperPieces}[1]{\defcurrency\@Copper@Pieces{#1}}
\newcommand{\SilverPieces}[1]{\defcurrency\@Silver@Pieces{#1}}
\newcommand{\ElectrumPieces}[1]{\defcurrency\@Electrum@Pieces{#1}}
\newcommand{\GoldPieces}[1]{\defcurrency\@Gold@Pieces{#1}}
\newcommand{\PlatinumPieces}[1]{\defcurrency\@Platinum@Pieces{#1}}

\CopperPieces{}
\SilverPieces{}
\ElectrumPieces{}
\GoldPieces{}
\PlatinumPieces{}

%%% PERSONAL DETAILS %%%

\def\@Personality@Traits{}
\def\@Ideals{}
\def\@Bonds{}
\def\@Flaws{}

\newcommand{\PersonalityTraits}[1]{\long\def\@Personality@Traits{#1}}
\newcommand{\Ideals}[1]{\long\def\@Ideals{#1}}
\newcommand{\Bonds}[1]{\long\def\@Bonds{#1}}
\newcommand{\Flaws}[1]{\long\def\@Flaws{#1}}

%%% FEATURES AND TRAITS %%%

\def\@Features@and@Traits{}
\newcommand{\FeaturesAndTraits}[1]{\long\def\@Features@and@Traits{#1}}

%%% CHARACTER APPEARANCE %%%

\def\@Age{}
\def\@Height{}
\def\@Weight{}
\def\@Eyes{}
\def\@Skin{}
\def\@Hair{}

\newcommand{\Age}[1]{\def\@Age{#1}}
\newcommand{\Height}[1]{\def\@Height{#1}}
\newcommand{\Weight}[1]{\def\@Weight{#1}}
\newcommand{\Eyes}[1]{\def\@Eyes{#1}}
\newcommand{\Skin}[1]{\def\@Skin{#1}}
\newcommand{\Hair}[1]{\def\@Hair{#1}}

\newsavebox\@CharacterAppearance
\long\def\CharacterAppearance@content{}

\newcommand{\CharacterAppearance}[1]{%
	\long\def\CharacterAppearance@content{#1}%
	\begin{lrbox}{\@CharacterAppearance}%
		\altsffamily\CharacterAppearance@content%
	\end{lrbox}%
}

%%% BACKSTORY %%%

\def\@Backstory{}
\newcommand{\Backstory}[1]{\long\def\@Backstory{#1}}

%%% ALLIES AND ORGANIZATIONS %%%

\def\@AlliesAndOrganizations{}
\def\AlliesAndOrganizations@name{}
\newsavebox\AlliesAndOrganizations@symbol
\def\AlliesAndOrganizations@symbol@content{}


\newcommand{\AlliesAndOrganizations}[2][]{%

	\edef\temp@arg{#1}
	\def\temp@name{Name}
	\def\temp@symbol{Symbol}
	
	\ifx\temp@arg\empty
		\long\def\@AlliesAndOrganizations{#2}
	\else\ifx\temp@arg\temp@name
		\def\AlliesAndOrganizations@name{#2}
	\else\ifx\temp@arg\temp@symbol
		\long\def\AlliesAndOrganizations@symbol@content{#2}
		\begin{lrbox}{\AlliesAndOrganizations@symbol}%
			\altsffamily\AlliesAndOrganizations@symbol@content
		\end{lrbox}
	\else
		\relax
	\fi\fi\fi
	
	\undef\temp@arg
	\undef\temp@name
	\undef\temp@symbol
}

%%% ADDITIONAL FEATURES AND TRAITS %%%
\def\@AdditionalFeaturesAndTraits{}
\newcommand{\AdditionalFeaturesAndTraits}[1]{\long\def\@AdditionalFeaturesAndTraits{#1}}

%%% TREASURE %%%
\def\@Treasure{}
\newcommand{\Treasure}[1]{\long\def\@Treasure{#1}}

%%% SPELLCASTING STATS %%%
\def\@SpellcastingClass{}
\newcommand{\SpellcastingClass}[1]{\def\@SpellcastingClass{#1}}
\def\@SpellcastingAbility{}
\newcommand{\SpellcastingAbility}[1]{\def\@SpellcastingAbility{#1}}

%%% CANTRIPS %%%

\def\@cantrips{}

\newcommand{\Cantrip}[1]{
\ifx\@cantrips\@empty
	\edef\@cantrips{#1}
\else
	\edef\@cantrips{\@cantrips,#1}
\fi
}

%%% SPELLS %%%

\def\spellcasting@levels{One,Two,Three,Four,Five,Six,Seven,Eight,Nine}

\foreach \@level in \spellcasting@levels{
	\expandafter\xdef\csname Level\@level @spells\endcsname{}
	\expandafter\xdef\csname level\@level @key\endcsname{Level \@level}
	\expandafter\xdef\csname Level\@level @Slots@Total\endcsname{0}
	\expandafter\xdef\csname Level\@level @Slots@Expended\endcsname{0}
}

\newcommand{\Spell}[3]{

	\edef\temp@levelarg{#1}
	\lowercase{\edef\temp@prepared{#3}}
	\def\temp@preparedkey{prepared}
	\def\temp@true{true}
	
	\ifx\temp@prepared\temp@preparedkey
		\def\prepared@fill{black}
	\else\ifx\temp@prepared\temp@true
		\def\prepared@fill{black}
	\else
		\def\prepared@fill{none}
	\fi\fi
	
	\foreach \@level in \spellcasting@levels{
		\edef\temp@levelkey{\csname level\@level @key\endcsname}
		\ifx\temp@levelkey\temp@levelarg
			\edef\temp@spells@level{\csname Level\@level @spells\endcsname}
			\ifx\temp@spells@level\@empty
				\expandafter\xdef\csname Level\@level @spells\endcsname{{#2}/\prepared@fill}
			\else
				\expandafter\xdef\csname Level\@level @spells\endcsname{\csname Level\@level @spells\endcsname,{#2}/\prepared@fill}
			\fi
		\fi
	}
	
	\undef\temp@levelarg
	\undef\temp@prepared
	\undef\temp@preparedkey
	\undef\temp@true
}

\newcommand{\SpellSlots}[3]{

	\edef\temp@levelarg{#1}
	
	\foreach \@level in \spellcasting@levels{
		\edef\temp@levelkey{\csname level\@level @key\endcsname}
		\ifx\temp@levelkey\temp@levelarg
			\expandafter\xdef\csname Level\@level @Slots@Total\endcsname{#2}
			\expandafter\xdef\csname Level\@level @Slots@Remaining\endcsname{#3}
		\fi
	}
	\undef\temp@levelarg
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	PUT EVERYTHING TOGETHER
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\MakeCharacterSheet}{

	\drawbackground[page=1]{-3.88}{0}{\@backgroundimage@path}
	
	\begin{tikzpicture}[%
		remember picture,
		overlay,
		shift=(current page.north west),
		xshift=-3.88pt,
		yscale=-1,
		every node/.style={anchor=west,inner sep=0},
		x=1in,
		y=1in
	]
		%Name
		\node at (0.7in,1.02in) [
			text width=2.75in,
			text height=18pt,
			text depth=6pt,
			shape=rectangle
		] {\huge\altsffamilysemi\@CharacterName};
		
		%Class and level, Background, Player Name, Race, Alignment, Experience Points
		\begin{scope}[
			every node/.style={
				anchor=west,
				inner sep=0pt,
				text depth=4pt,
				text height=12pt,
				shape=rectangle,
				draw=none
			}
		]	
			\ifx\@Level\@empty
				\def\Level@text{}
			\else
				\def\Level@text{Lvl \@Level~}
			\fi
			\ifx\@ExperiencePoints\@empty
				\def\ExperiencePoints@text{}
			\else
				\def\ExperiencePoints@text{\@ExperiencePoints~XP}
			\fi
			\node at (3.79,0.815) [text width=1.5in] {\large\altsffamily\Level@text\@Class};
			\node at (5.36,0.815) [text width=1.27in] {\large\altsffamily\@Background};
			\node at (6.71,0.815) [text width=1.245in] {\large\altsffamily\@PlayerName};
			\node at (3.79,1.175) [text width=1.5in] {\large\altsffamily\@Race};
			\node at (5.36,1.175) [text width=1.27in] {\large\altsffamily\@Alignment};
			\node at (6.71,1.175) [text width=1.245in] {\large\altsffamily\ExperiencePoints@text};
		\end{scope}
	
		%Ability scores
		%Strength
		\node at (0.6,2.33) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@STR};
		\node at (0.72,2.68) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\STR@mod};
		%Dexterity
		\node at (0.6,3.33) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@DEX};
		\node at (0.72,3.68) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\DEX@mod};
		%Constitution
		\node at (0.6,4.32) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@CON};
		\node at (0.72,4.67) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\CHA@mod};
		%Intelligence
		\node at (0.6,5.32) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@INT};
		\node at (0.72,5.67) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\INT@mod};
		%Wisdom
		\node at (0.6,6.31) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@WIS};
		\node at (0.72,6.665) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\WIS@mod};
		%Charisma
		\node at (0.6,7.3) [text width=0.5in,align=center,shape=rectangle] {\Huge\bfseries\@CHA};
		\node at (0.72,7.66) [text width=0.2in,align=right,shape=rectangle] {\bfseries\fmod\CHA@mod};
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	SAVING THROWS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\def\bulletystep{0.1875}
		\def\modxoffset{0.12}
		\def\modyoffset{-0.02}
		
		\coordinate (current) at (1.5032,2.9345);
	
		\foreach \@ability in \@abilities{
	
			\edef\@saveproficiency{\csname\@ability @save@proficiency\endcsname}
			\calculate*{\@ability mod + \@saveproficiency}{\@mod}
	
			\ifnum\@saveproficiency> 0
				\def\@fill{black}
			\else
				\def\@fill{none}
			\fi
			
			\node at (current) [shape=circle,fill=\@fill,minimum size=0.09in,anchor=center] {};
			
			\node at ($(current)+(\modxoffset,\modyoffset)$) [%
					text width=0.16in,
					text height=8pt,
					text depth=1.5pt,
					align=flush right,
					shape=rectangle,
					draw=none
				]{%
					\footnotesize\fmod{\@mod}%
				};
				
			\coordinate (current) at ($(current)+(0,\bulletystep)$);
		}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	SKILLS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
		\coordinate (current) at (1.5032,4.5355);
		
		\foreach \@skill/\@ability in \@skills{
				
			\edef\@skillproficiency{\csname\@skill @proficiency\endcsname}
			
			\ifnum\@skillproficiency > 0
				\def\@fill{black}
			\else
				\def\@fill{none}
			\fi
			
			\calculate*{\@skill}{\@mod}
			
			\node at (current) [shape=circle,fill=\@fill,minimum size=0.09in,anchor=center] {};
			
			\node at ($(current)+(\modxoffset,\modyoffset)$) [%
					text width=0.16in,
					text height=8pt,
					text depth=1.5pt,
					align=flush right,
					shape=rectangle,
					draw=none
				]{%
					\footnotesize\fmod{\@mod}%
				};
				
			\coordinate (current) at ($(current)+(0,\bulletystep)$);
		}
				
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	PASSIVE WISDOM
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		\node at (0.4,8.33) [text width=0.5in,align=center,shape=rectangle] {\Large\bfseries\@passive@wisdom};
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	INSPIRATION
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\node at (1.546,1.9392) [anchor=center,minimum size=0.2in,shape=star,star points=12,fill=\@Inspiration] {};
		\node at (1.546,1.9392) [anchor=center,minimum size=0.14in,shape=star,star points=12,fill=\@Inspiration@Inner] {};
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	PROFICIENCY
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\node at (1.546,2.465) [text width=0.5in,anchor=center,align=center,shape=rectangle] {\Large\bfseries\fmod{\@Proficiency}};
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	ARMOR CLASS/SPEED/INITIATIVE
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\begin{scope}[
			every node/.style={
				anchor=center,
				text width=0.5in,
				align=center,
				shape=rectangle,
				draw=none
			}
		]
		
			\node at (3.493,2.15) {%
				\Large\bfseries{\@Armor@Class}
			};
			\node at (4.23,2.2) {%
				\huge\bfseries\fmod{\DEX@mod}%
			};
			\node at (5.089,2.2) {%
				\ifx\@Speed\@empty\relax\else{\huge\bfseries\@Speed}\\[-0.06in]\tiny\altsffamily$\text{ft}/\text{turn}$\fi%
			};
	
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	HIT POINTS AND HIT DICE
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		\begin{scope}[
			every node/.style={
				anchor=south west,
				inner sep=0.025in,
				text height=7pt,
				text depth=0pt,
				shape=rectangle,
				draw=none
			}
		]
			\node at (4.0905,2.8831) [text width=1.19357in] {\footnotesize{\@Hit@Points@Total}};
			\node at (3.4838,4.5579) [text width=0.608in] {\footnotesize{\@Hit@Dice@Total}};	
		\end{scope}
	
		\begin{scope}[
			every node/.style={
				anchor=west,
				inner sep=0,
				text width=2.05in,
				minimum height=0.35in,
				align=center,
				shape=rectangle,
				draw=none
			}
		]	
			\ifx\@Hit@Points\@empty
				\ifx\@Hit@Points@Total\@empty
					\relax
				\else
					\node at (3.275,3.15) {%
						\Huge\bfseries\@Hit@Points\color{black!20}{\normalsize\ / \@Hit@Points@Total}%
					};
				\fi
			\else
				\node at (3.275,3.15) {%
					\Huge\bfseries\@Hit@Points\color{black!20}{\normalsize\ / \@Hit@Points@Total}%
				};
			\fi
			\node at (3.275,3.9) [opacity=\@Temp@Hit@Points@Opacity] {%
				\Huge\bfseries\@Temp@Hit@Points\color{black!20}{\normalsize\ / \@Temp@Hit@Points@Total}%
			};
		\end{scope}
		
		\node at (3.275,4.75)
			[
				anchor=west,
				text width=0.85in,
				minimum height=0.3in,
				align=center,
				shape=rectangle,
				draw=none
			]
			{%
				\Large\bfseries\@Hit@Dice%
			};
			
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	DEATH SAVING THROWS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\begin{scope}[
			every node/.style={
				minimum size=0.12in,
				anchor=center,
				shape=circle,
				inner sep=0pt,
				fill=black
			}
		]
		
			\coordinate (success coordinate) at (4.9225,4.539);
			\coordinate (failure coordinate) at ($(success coordinate) + (0,0.208)$);
				
			\foreach \@DeathSave in {0,...,2}{
				\ifnum\DeathSaveSuccess@count=\@DeathSave
					\breakforeach
				\else
					\node at (success coordinate) {};
					\coordinate (success coordinate) at ($(success coordinate) + (0.1785,0)$);
				\fi
			};
			
			\foreach \@DeathSave in {0,...,2}{
				\ifnum\DeathSaveFail@count=\@DeathSave
					\breakforeach
				\else
					\node at (failure coordinate) {};
					\coordinate (failure coordinate) at ($(failure coordinate) + (0.1785,0)$);
				\fi
			};
				
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	WEAPONS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		\def\here{here}
		\begin{scope}[
			every node/.style={
				anchor=south west,
				inner sep=2pt,
				text height=9.9pt,
				text depth=2pt,
				shape=rectangle
			}
		]
		
			\foreach [count=\row] \@Weapon/\@AtkBonus/\@Damage/\@DamageType in \@Weapons{
				
				\ifnum\row = 1
					\coordinate (row y) at (0,5.66608);
				\else\ifnum\row = 2
					\coordinate (row y) at (0,5.94958);
				\else\ifnum\row = 3
					\coordinate (row y) at (0,6.23653);
				\else
					\relax
				\fi\fi\fi

				\calculate*{\@AtkBonus}{\AtkBonus@calculated}
	
				\ifnum\AtkBonus@calculated > 0
					\def\@plusorminus{\plus}
				\else
					\def\@plusorminus{\relax}
				\fi
			
				\def\@boxfill{rgb,255:red,231;green,232;blue,232}
				\ifnum\row > 3			
					\fill[fill=\@boxfill] ($(3.15013,0)+(row y)$) -- ++(0.85555,0) -- ++(0.03275,-0.03275)
						-- ++(0,-0.18724) -- ++(-0.85555,0) -- ++(-0.03275,0.03275) -- cycle;
					\fill[fill=\@boxfill] ($(4.10071,0)+(row y)$) -- ++(0.4003,0) -- ++(0.03275,-0.03275)
						-- ++(0,-0.18724) -- ++(-0.4003,0) -- ++(-0.03275,0.03275) -- cycle;
					\fill[fill=\@boxfill] ($(4.59604,0)+(row y)$) -- ++(0.82975,0) -- ++(0.03275,-0.03275)
						-- ++(0,-0.18724) -- ++(-0.82975,0) -- ++(-0.03275,0.03275) -- cycle;
				\fi
				
				\node at ($(3.1447,0)+(row y)+(0,0.00547)$) [
					inner xsep=4pt,
					text width=0.8385in
				] 
				{%
					\altsffamily\footnotesize\@Weapon%
				};
					
				\node at ($(4.09515,0)+(row y)+(0,0.00547)$) [
					inner xsep=2pt,
					text width=0.3834in,
					align=center
				]
				{%
					\@plusorminus\AtkBonus@calculated
				};
				
				\node at ($(4.5905,0)+(row y)+(0,0.00547)$) [
						inner xsep=4pt,
						text width=0.8128in
				]
				{%
					\altsffamily\footnotesize\@Damage{\,\,\tiny{\@DamageType}}
				};
				
				% save last y-coordinate for positioning the text box in the next section
				% awkward, probably change this at some point
				\path let \p1=(row y) in (row y) node {\xdef\last@rowy{\y1}};
				\coordinate (row y) at ($(row y) + (0,0.28524)$);
			}
	
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	ATTACKS AND SPELLCASTING
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		\begin{scope}
			
			\ifx\@Weapons\@empty
				\def\last@rowy{6.23653in}
				\coordinate (row y) at ($(0,\last@rowy)+(0,0.28524)$);
			\fi
			
			% adjust text depth to compensate for extra weapons
			\newdimen\textdepth@adjusted
			\textdepth@adjusted=1.49in
			\advance\textdepth@adjusted by 6.23653in
			\advance\textdepth@adjusted by -\last@rowy
			
			\clip ($(3.15,0)+(row y)-(0,0.20177)$)
				node
					[
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},
						anchor=north west,
						text width=2.3in,
						text depth=\textdepth@adjusted,
						text height=6pt,
						align=flush left,
						shape=rectangle,
						draw=none
					]
				(thisnode)
					{%
						\scriptsize\altsffamily\@Attacks@and@Spellcasting
						
					};
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	EQUIPMENT AND MONEY
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		\begin{scope}
			\clip (3.17,8.24)
				node
					[
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},
						anchor=north west,
						text width=2.3in,
						text depth=2.165in,
						align=flush left,
						shape=rectangle,
						draw=none
					]
				(thisnode)
					{%
						%
						\scriptsize\altsffamily%
						%
						\@Equipment
			
					};
		\end{scope}
		
		\begin{scope}[
			every node/.style={
				inner sep=2,
				align=center,
				minimum height=0.30632in,
				text width=0.54693in,
				anchor=south west,
				shape=rectangle,
				draw=none
			}
		]
			\path (3.1385,8.2356)%
				\foreach \@Pieces in {
					\@Copper@Pieces,
					\@Silver@Pieces,
					\@Electrum@Pieces,
					\@Gold@Pieces,
					\@Platinum@Pieces
				}{
					++(0,0.3605) node {\Large\@Pieces}
				};
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	OTHER PROFICIENCIES & LANGUAGES
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\begin{scope}
			\clip (0.55,8.75)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},
						anchor=north west,
						text width=2.25in,
						text depth=1.68in,
						align=flush left,
						shape=rectangle,
						draw=none
					]
				(thisnode)%
					{%
						%
						\scriptsize\altsffamily%
						%
						\@Other@Proficiencies@and@Languages
					
					};
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	FEATURES AND TRAITS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\begin{scope}
			\clip (5.79,5.4)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=2.27in,%
						text depth=4.97in,%
						align=flush left,%
						shape=rectangle,%
						draw=none%
					]%
				(thisnode)%
					{%
						%
						\scriptsize\altsffamily%
						%
						\@Features@and@Traits
	
					};
		\end{scope}
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	PERSONAL DETAILS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\begin{scope}[
			every node/.style={
				anchor=north west,
				text width=2.11in,
				text height=6pt,
				inner sep=0pt,
				align=flush left,
				shape=rectangle,
				draw=none
			}
		]
		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	
			%	Personality Traits
			%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		
			\begin{scope}
				\clip (5.87,1.975)%
					node%
						[%
							append after command={%
								(thisnode.north west) rectangle (thisnode.south east)%
							},%
							text depth=0.6in%
						]%
					(thisnode)%
						{%		
							\scriptsize\altsffamily%
							%
							\@Personality@Traits
				
						};
			\end{scope}
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	
			%	Ideals
			%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
			\begin{scope}
				\clip (5.87,2.925)%
					node%
						[%
							append after command={%
								(thisnode.north west) rectangle (thisnode.south east)%
							},%
							text depth=0.45in%
						]%
					(thisnode)%
						{%		
							\scriptsize\altsffamily%
							%
							\@Ideals
					
						};
			\end{scope}
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	
			%	Bonds
			%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
			
			\begin{scope}
				\clip (5.87,3.7)%
					node%
						[%
							append after command={%
								(thisnode.north west) rectangle (thisnode.south east)%
							},%
							text depth=0.45in%
						]%
					(thisnode)%
						{%		
							\scriptsize\altsffamily%
							%
							\@Bonds
					
						};
			\end{scope}
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	
			%	Flaws
			%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
			\begin{scope}
				\clip (5.87,4.465)%
					node%
						[%
							append after command={%
								(thisnode.north west) rectangle (thisnode.south east)%
							},%
							text depth=0.345in%
						]%
					(thisnode)%
						{%		
							\scriptsize\altsffamily%
							%
							\@Flaws
					
						};
			\end{scope}
		
		\end{scope}
		
	\end{tikzpicture}
	
	\newpage
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	
	%	PAGE TWO
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	\drawbackground[page=2]{-3.88}{0}{\@backgroundimage@path}
	
	\begin{tikzpicture}[%
		remember picture,
		overlay,
		shift=(current page.north west),
		xshift=-3.88pt,
		yshift=0pt,
		yscale=-1,
		every node/.style={anchor=west,inner sep=0},
		x=1in,
		y=1in
	]
	
		%Name (Again)
		\node at (0.7in,1.02in) [
			text width=2.75in,
			text height=18pt,
			text depth=6pt,
			shape=rectangle,
			yshift=-0.042in,
			xshift=0.012in
		] {\huge\altsffamilysemi\@CharacterName};
		
		%Appearance
		\begin{scope}[
			every node/.style={
				anchor=west,
				inner sep=0pt,
				text depth=4pt,
				text height=12pt,
				shape=rectangle,
				draw=none,
				yshift=-0.042in,
				xshift=-0.0755in
			}
		]
			\node at (3.83,0.81) [text width=1.5in] {\large\altsffamily \@Age};
			\node at (5.36,0.81) [text width=1.27in] {\large\altsffamily \@Height};
			\node at (6.71,0.81) [text width=1.245in] {\large\altsffamily \@Weight};
			\node at (3.83,1.17) [text width=1.5in] {\large\altsffamily \@Eyes};
			\node at (5.36,1.17) [text width=1.27in] {\large\altsffamily \@Skin};
			\node at (6.71,1.17) [text width=1.245in] {\large\altsffamily \@Hair};
		\end{scope}
		
		%Appearance — Image
		\begin{scope}
			\clip (0.54,1.825)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=2.26in,%
						%text depth=3.05in,%
						minimum height=3.025in,
						align=center,%
						shape=rectangle,%
					]%
				(thisnode)%
					{%
						\usebox\@CharacterAppearance
					};
		\end{scope}
		
		%Backstory
		\begin{scope}
			\clip (0.54,5.375)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=2.26in,%
						text depth=5in,%
						align=justify,%
						shape=rectangle,%
						draw=none%
					]%
				(thisnode)%
					{%
						%
						\scriptsize\altsffamily%
						%
						\@Backstory
	
					};
		\end{scope}
		
		%Allies and Organizations
		\begin{scope}
			\clip (3.187,1.775)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=4.851in,%
						text depth=3.075in,%
						align=justify,%
						shape=rectangle,%
						draw=none%
					]%
				(thisnode)%
					{%
						%
						\newlength{\oldintextsep}%
						\setlength{\oldintextsep}{\intextsep}%
						\setlength{\intextsep}{0.011in}%
						\scriptsize\altsffamily%
						\begin{wrapfigure}{r}{0cm}%
							\begin{tikzpicture}
								\path (0,0) rectangle (2.2975,-2.3895);
							\end{tikzpicture}%
						\end{wrapfigure}%
						\setlength{\intextsep}{\oldintextsep}%
						\@AlliesAndOrganizations
						
					};
			\node at (5.9081, 2.3511) [
				anchor=south west,
				inner sep=2pt,
				text height=9.5pt,
				text depth=2pt,
				inner xsep=4pt,
				text width=1.8445in,
				align=center,
				opacity=1,
				shape=rectangle
			] 
			{%
				\altsffamily\footnotesize%
				\AlliesAndOrganizations@name%
				
			};
			
			\node at (5.9081, 2.405) [
				anchor=north west,
				text width=1.95559in,
				minimum height=1.5139in,
				align=center,
				shape=rectangle
			]
			{%
				\altsffamily\footnotesize%
				\usebox\AlliesAndOrganizations@symbol%
				
			};
			
		\end{scope}
		
		%Additional Features and Traits
		\begin{scope}
			\clip (3.187,5.225)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=4.85in,%
						text depth=2.72in,%
						align=justify,%
						shape=rectangle,%
						draw=none%
					]%
				(thisnode)%
					{%
						%
						\scriptsize\altsffamily%					
						\@AdditionalFeaturesAndTraits
						
					};
		\end{scope}
	
	
		%Treasure
		\begin{scope}
			\clip (3.187,8.405)%
				node%
					[%
						append after command={%
							(thisnode.north west) rectangle (thisnode.south east)%
						},%
						anchor=north west,%
						text width=4.85in,%
						text depth=2in,%
						align=justify,%
						shape=rectangle,%
						draw=none%
					]%
				(thisnode)%
					{%
						%
						\scriptsize\altsffamily%
						%
						\@Treasure
	
					};
		\end{scope}
	
	\end{tikzpicture}
	
	\newpage
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	
	%	PAGE THREE
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	\drawbackground[page=3]{-3.88}{0}{\@backgroundimage@path}
	
	\begin{tikzpicture}[%
		remember picture,
		overlay,
		shift=(current page.north west),
		xshift=-3.88pt,
		yshift=0pt,
		yscale=-1,
		every node/.style={anchor=west,inner sep=0},
		x=1in,
		y=1in
	]
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	BASICS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		%Spellcasting Class
		\node at (0.7in,1.02in) [
			text width=2.75in,
			text height=18pt,
			text depth=6pt,
			shape=rectangle,
			yshift=-0.042in,
			xshift=0.012in
		] {\huge\altsffamilysemi \@SpellcastingClass};
	
		%Spellcasting Ability
		\node at (3.97,0.9575) [align=center, text width=0.9465in,minimum height=0.42in, shape=rectangle]
			{\huge\altsffamilysemi \@SpellcastingAbility};
			
		\ifx\@SpellcastingAbility\@empty
			\relax
		\else	
			\edef\SpellcastingAbility@mod{\csname\@SpellcastingAbility @mod\endcsname}
			\calculate*{\SpellcastingAbility@mod+\@Proficiency+8}{\@SpellSaveDC}
			\calculate*{\SpellcastingAbility@mod+\@Proficiency}{\@SpellAttackBonus}
			
			%Spellcasting Save DC
			\node at (5.369,0.9475) [align=center, text width=0.9465in,minimum height=0.43in, shape=rectangle]
				{\huge\bfseries\@SpellSaveDC};
			
			%Spellcasting Attack Bonus
			\node at (6.81,0.9475) [align=center, text width=0.9465in,minimum height=0.43in, shape=rectangle]
				{\huge\bfseries\fmod{\@SpellAttackBonus}};
		\fi
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	CANTRIPS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		\begin{scope}[every node/.append style={text depth=0pt}]
	
		\path (0.64,2.54) ++(0,-0.19445)
			\foreach \@cantrip in \@cantrips{
				++(0,0.19445) node [anchor=south west]{\altsffamily\footnotesize \@cantrip}
			};
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		%	SPELLS
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		\coordinate (LevelOneSpells) at (0.68,5.11);
		\coordinate (LevelTwoSpells) at (0.68,8.0623);
		
		\coordinate (LevelThreeSpells) at (3.3051,2.5581);
		\coordinate (LevelFourSpells) at (3.3051,5.6913);
		\coordinate (LevelFiveSpells) at (3.3051,8.838);
		
		\coordinate (LevelSixSpells) at (5.9041,2.5581);
		\coordinate (LevelSevenSpells) at (5.9041,4.9158);
		\coordinate (LevelEightSpells) at (5.9041,7.2742);
		\coordinate (LevelNineSpells) at (5.9041,9.2288);
		
		\foreach \@level in \spellcasting@levels{
			
			\def\@One{One}
			\ifx\@level\@One
				\def\spells@topsep{-0.60875} % extra space to compensate for the "spell name" label on level one
			\else
				\def\spells@topsep{-0.3865}
			\fi
			
			\edef\temp@total{\csname Level\@level @Slots@Total\endcsname}
			\edef\temp@remaining{\csname Level\@level @Slots@Remaining\endcsname}
		
			\ifnum\temp@total>0
				\node at ($(Level\@level Spells)+(0.0675,\spells@topsep)$)
					[%
						anchor=west,
						minimum height=0.337in,
						text width=0.6in,
						align=center,
						shape=rectangle
					]
					{%
						\bfseries\Large \csname Level\@level @Slots@Total\endcsname
					};
					
				\coordinate (Spell Slots) at ($(Level\@level Spells)+(1.0175,\spells@topsep)$);
				
				\begin{scope}[every node/.append style={anchor=center,shape=star,star points=4}]
					\foreach \@slot in {1,...,\temp@total}{
					
						\ifnum\@slot>\temp@remaining
							\node at (Spell Slots) [star point ratio=0.3,rotate=45,minimum size=0.065in,fill=black!25]{};
							\node at (Spell Slots) [star point ratio=0.45,minimum size=0.075in,fill=black!25]{};
							\node at (Spell Slots) [star point ratio=0.3,rotate=45,minimum size=0.04in,fill=white]{};
							\node at (Spell Slots) [star point ratio=0.45,minimum size=0.05in,fill=white]{};
						\else
							\node at (Spell Slots) [star point ratio=0.3,rotate=45,minimum size=0.065in,fill=black]{};
							\node at (Spell Slots) [star point ratio=0.45,minimum size=0.075in,fill=black]{};
							\node at (Spell Slots) [star point ratio=0.3,rotate=45,minimum size=0.04in,fill=gray]{};
							\node at (Spell Slots) [star point ratio=0.45,minimum size=0.05in,fill=gray]{};
						\fi
						
						\coordinate (Spell Slots) at ($(Spell Slots)+(0.3,0)$);
					}
				\end{scope}
			\fi
			
			\edef\temp@spells{\csname Level\@level @spells\endcsname}
	
			\coordinate (current) at (Level\@level Spells);
			
			\foreach \@spell/\@prepared in \temp@spells{
				\node at (current) [anchor=south west]{\altsffamily\footnotesize \@spell};
				\node at ($(current)+(-0.1348,-0.0212)$)
					[%
						anchor=center,
						shape=circle,
						minimum size=0.08in,
						fill=\@prepared
					] {};
				\coordinate (current) at ($(current)+(0,0.19445)$);
			}
		}
		
		\end{scope}
		
	\end{tikzpicture}
}

\endinput