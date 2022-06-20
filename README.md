# MissingTradeSkillsList
Addon For Turtle World Of Warcraft v1.16<br />
Shows the missing recipes/skills for a tradeskill and where to get them

Supported TradeSkills: All but enchanting!<br />
Beware: Not all trainer skills have the correct minimum skill required or price


![MTSL for First Aid](https://i.imgur.com/UEn9CId.png)
![MTSL for Alchemy](https://i.imgur.com/jacvhFN.png)

## TurtleWoW Changes to the original MissingTradeSkillList
* AdvancedTradeSkillWindow Addon Support
* Engineering
    * Portable Wormhole Generator : Stormwind

## Known Bugs
7: ToggleButton does not correctly move when viewing or hiding tradeskillframe & craftframe at same time<br />
8: Error when opening a CraftWindow before a TradeSkillFrame<br />
11: When using mousewheel over addon, still zooms in & out in the world, except when over listframe<br />
12: Not all trainer skills have the correct minimum skill required or price

## Resolved Bugs
1: List of missing skills does not update automaticaly when you learn a new skill<br />
2: LuaError on scrollbar when swapping to new tradeskill window<br />
3: Text in MissingSkillsList is not justified to left<br />
4: Price info on FirstAid Skills is not correct for some skills<br />
5: Selected MissingSkill is not visible colored in list<br />
6: Update Event not always triggered when learning a new skill<br />
9: Show all multiple types of sources for a missing skill, only 1 now<br />
10: Selected skill is gone when scrolling

## Version History
vTWoW_0.0.0: fixes  
v0.23: 	Added all skills for professions but Enchanting<br />
v0.22: 	Added 50 tailoring skills<br />
v0.21: 	Added all mining skills<br />
v0.20: 	Refactored lua files and data structure, fixed bug 9, 10<br />
v0.16: 	Added all missing cooking recipes, changed data structure<br />
v0.15: 	Added 30 missing cooking recipes, changed structure NPCs<br />
v0.14:	Fixed bug 4, started cooking support<br />
v0.13: 	Fixed bug 5, removed crafting for now, added first bracket 1-75 as skilllevel<br />
v0.12:	Fixed bugs 3,6 and started support for craft skills (enchanting)<br />
v0.11:	Fixed bugs 1, 2<br />
v0.10:  Works for First Aid
