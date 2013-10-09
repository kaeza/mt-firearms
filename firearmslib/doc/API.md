
## FirearmsLib API ##

### Core Module ###

#### firearms.get_player_info ####

`get_player_info(player_or_name)`

Returns stored information about the player as a table. FirearmsLib
submodules add fields to this table. The FirearmsLib core only uses the
following fields:

* `name` -- Player name
* `current_weapon` -- The current weapon held by the player (an itemdef).

Please note that this information is temporary, and is lost when the server
shuts down. If you need persistent info, use
`[[#firearms.get_player_persistent_info]]`'.

''Arguments:''

* `player_or_name` -- Either a player object or a name.

''Return value:''

Player information as a table.

#### firearms.get_player_persistent_info ####

`get_player_persistent_info(player_or_name)`

Returns stored information about the player as a table. Contrary to
`{{{[[#firearms.get_player_info]]}}}', this information is stored into a
database, and is persistent across sessions.

''Arguments:''

|{{{player_or_name}}} |Either a player object or a name. |

''Return value:''

Player information as a table.

==== firearms.player_can_shoot ====

{{{ player_can_shoot(player_or_name) }}}

Returns whether the specified player can shoot right now.

''Arguments:''

|{{{player_or_name}}} |Either a player object or a name. |

''Return value:''

True if the player is ready to shoot, else false.

=== Module `firearms.weapon' ===

==== firearms.weapon.register ====

Registers a new weapon. This is a convenient wrapper around
`{{{minetest.register_craftitem}}}' that sets some fields to useful defaults
if not specified.

{{{ register(name, weapon_def) }}}

''Arguments:''

|{{{name}}} |Name of this weapon, in the format `modname:itemname'. |
|{{{weapon_def}}} |Information about this weapon. |

''Return value:''

None.

''See also:''

[[#Weapon Definition]]

=== Module `firearms.event' ===

==== firearms.event.register =====

Registers a new callback in the event system.

{{{ register(eventtype, callback }}}

''Arguments:''

|{{{eventtype}}} |Type of this event. |
|{{{callback}}} |Callback function. |

''Return value:''

None.

''See also:''

* [[#Events]]

==== firearms.event.trigger =====

Triggers an event, calling each registered callback in turn.

{{{ trigger(eventtype, ...) }}}

''Arguments:''

|{{{eventtype}}} |Event type to trigger. |
|{{{...}}} |Arguments to the event handlers. |

''Return value:''

If any callback returns a value other than {{{nil}}}, returns this value and
stops calling other callbacks, else returns {{{nil}}}.

''See also:''

* [[#Events]]

=== Module `firearms.shop' ===

==== firearms.shop.player_can_shop ====

{{{ player_can_shop(player_or_name, shop_pos) }}}

Returns whether the specified player can view the shop at `shop_pos'.

''Arguments:''

|{{{player_or_name |Either a player object or a name. |
|{{{shop_pos}}} |Shop position. |

''Return value:''

If player is allowed, returns true. If not, returns false plus a reason string.
