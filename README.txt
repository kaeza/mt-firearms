
Firearms Mod for Minetest
=========================

This mod provides several firearms to be used on PvP servers, along with some
related items to create an FPS-like game.

These are the guns provided:

  M9
    A .45 caliber pistol, capable of semiautomatic fire.
    Average damage, average rate of fire, average accuracy, medium range.
    Useful as a secondary weapon.

  Benelli M3
    A pump action shotgun. Uses buckshot 12 gauge shells.
    Brutal damage at short range, low damage at medium range, rather low rate
    of fire, low accuracy, medium range. Just your average shotgun.

  M4
    A semi- and full-auto assault rifle, chambered for the 5.56mm NATO round.
    Average damage, high rate of fire, high accuracy, medium to long range.

  Arctic Warfare Precision Rifle ("AWP")
    A bolt-operated rifle with telescopic sights.
    Deadly damage, very low rate of fire, very low accuracy, near perfect
    accuracy when zoomed, long range.

Additionally, the following items are provided:

  Night Vision Goggles
    Brightens up your vision. Able to see even on pitch black rooms.

  Medkit
    Heals 8HP (4 hearts).

  Armor
    Reduces damage from non-armor-piercing bullets. Has no effect on other
    weapons such as swords.


Controls
========

Left Click              Shoot
Right Click             Secondary action; depends on weapon.
Shift + Left Click      Reload
Shift + Right Click     Switch fire mode/subweapon.


Notes
=====

For the "zoom" feature to work, you need a patched version of Minetest. This
mod comes with a patch that must be applied to the sources and allows changing
the FOV (or "zoom") by this or other mods. Otherwise, the zoom only works in
single player.

How to apply such a patch or compile Minetest from sources is outside the scope
of this document. Use a web search engine or ask in the forum topic.


API
===

There's an Application Program Interface so other mods can define their own
weapons and items. See `API.txt' for more information.


About this document
===================

Copyright (C) 2013 Diego Martínez <kaeza>

Distributed under the same terms as firearms modpack itself.
See `doc/LICENSE.txt' for the full license text.
