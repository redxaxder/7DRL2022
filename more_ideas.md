
TIP messages:
  disregard tactics, mash controls
  as everyone known, wizards are highly flammable

item stacking:
  - items of the same type stack (up to 3)

throw happens in recently pressed direction

other enemies throw themselves in front of the king to prevent his death
  - king swaps with them before getting killed
  - they suffer his fate
  - visual indicator for king
  - GOLDEN SPARKLES

visual indicator for stairs

enemy tripping effect:
  - resets player run speed when running past

ninja
  - yellow ability
  - if it would be killed, stealths instead and creates a log in his place

poison status effect:
  - for enemeies:
    - countdown to death
    - communicated through flashing green
    - rate of flash communicates progress
  - for player:
    - random debuff (for after rage ends)

trapper
  - purple ability
  - places a trap
    - traps are represented by ^
    - color coded
    - explosive trap (red): explodes when player steps on it (fire!)
    - tripwire (white): trips player
    - boulder trap (brown): rocks fall. leaves rubble
    - rolling boulder trap (grey):
         only spawned next to wall.
         creates rolling boulder
         injurs and knocks player back
    - poison gas (green):
         aoe application of poison effect
         player gains 1 turn of a random debuff (for after rage ends)

assassin
  - speedy
  - swappable
  - lurks around player's periphery
  - approaches/attacks if there are enough enemies near the player
  - poisoned knife
  - flees otherwise
  - yellow (once) ability: throw a bottle of poison

swappable:
  - does not block pathing for other (non-swappable) enemies
  - if they would move here, trade places with this unit
  - probably: ranger, rogue, priest, tourist

wizard:
  - shoots over tables/chairs
    - except tables that have been knocked over
  - fireball passing over table/chair ignites it

knight:
  - might drop shield (~1%?)
  - when held by player:
    - convert damage taken into knockback (consumed on use)

stuns / interrupts:
  - stops channeling
  - enemy loses turn

shockwave:
  - nudge all furniture in radius 1 (max norm)
  - visual effect
  - interrupt
  - stun

floor smashing:
  - some floor spaces can become rubble
  - rubble influences enemy movement (they lose a turn entering, avoid by default)
  - rubble applies trip to player

more furniture stuff:
  - "smashed to pieces" events do a shockwave
  - bookshelf
    - spawns adjacent to a wall
    - spawns a bunch of books when destroyed
    - books are an item
      - when in rage: throw it
      - when calm: also throw it
  - brazier
    - fire!
    - nudge: tipped over. starts fires
    - collides after knockback: ignites
    - drops hot coals
    - hot coals:
      - ignites things (check flammability)
      - remains for some number of turns
    - as an item:
      - ignites player if boozed
      - use during rage: throw. thrown coal has a 100% ignite chance
      - use during calm: drop
      - while held during rage: +1 fatigue / turn
      - while held during recovery: recovery doesn't increase
  - wall torch
    - it is inside the wall
    - approach wall to pick it up and weild it as a weapon
    - knocking furniture INTO a wall torch causes fire
    - attack sets things on fire
    - pattern same as punch
  - statue
    - of the king
    - nudge: immobile
    - knockback: the usual
    - not flammable
    - blocks projectiles (fireball)
    - spawns toward middle of room
  - weapon rack
    - contains a weapon
    - otherwise, as table
    - spawns on edge of room
  - chandelier
    - square area of floor tiles of max tile brightness
    - acts as light source
    - there is a paired rope along a wall of the same room
    - all interactions with the rope cause chanelier to fall
    - chance for fire
    - crushes things below
    - triggers shockwave
  - window
    - only spawns along outside walls
    - emits glass shards when broken
    - knockback items pass through the window
    - light source
    - glass breaking sound effect
    - wilhelm scream?
    - if player is knocked back, they grab the edge
      - can climb back in

currently we fill rooms by repeatedly drawing from the spawn distribution
  - we could make the ditribution more lumpy
  - have a higher chance do draw pre-esixting enenmies

room types:
  - kitchen
    - stove
    - pan (item)
    - knife (item)
    - pan (item)

fire:
  - lighting effect!
  - flickering!
  - particles!
  - normal maps for our sprites

valkyrie:
  - start yellow
  - change from yellow to purple
  - summoning is a channeled ability

priest needs a buff. archaeologist needs a buff.

archaeologist idea:
  - they have two modes:
    - calm/ terrified
  - calm mode: approach other enemies like the priest
  - terrified mode: flee toward the nearest door and open it
  - become calm upon opening a door
    - or time limit without refreshing terrified
  - they become terrified if they step on blood
     - or if something dies next to them
  - "The archeologist lets out a terrified shriek and starts to flee"

fatigue counts upward while in rage
  - 1 per turn
  - a perk chain reduces it by half (20/15/15)
  - rebalance fatigue effects to compensate


should actually graph the exp curve and compare is to the total exp available in a run
target number of perks in a run!


different running indicator:
  - not running: a dot icon
  - running: an icon with a number of arrows equal to run speed
             the arrows point in the running direction

UI should display current floor

vault:
  - trampling an enemy doesnt interrupt the run
  - trampling an enemy extends the run by 1
  - trampling an enemy extends the run by your run speed

combustion:
  - 20% chance to catch fire
  - 100% chance to catch fire
  - burning causes additional rage
  - 100% chance to ignite adjacent enemies while burning

shock:
  - 20% chance to shockwave on attack
  - 100% chance to shockwave on attack
  - shockwave radius
  - trigger shockwave when running into a wall

reduce debuff duration:
  5/10/15

desperate strike:
  - area attack triggered on leaving rage

inventory:
  - perk: double stack size

instinct:
  - clues point way toward particular kinds of items
  - consumable
  - fountain
  - exit
  - weapon
  - notify when there are nearby hiding enemies
    - exclamation point above player's head


skulls:
  - suuper rare drop (~1%?)
  - thrown item
  - perks:
    - higher skull chance
    - flaming skulls:
        skulls you throw have a chance to be on fire
    - alas poor yorick?
    - skull chalice: holding skull increases fountain recovery

scavenger:
  - chance to preserve enemy equipment
    - knight: shield
    - wizard: brandy
    - rogue: knife (thrown item)
    - assassin: bottle of poison (thrown. aoe poison effect)
    - ninja: shuriken/kunai (thrown item)
    - tourist: camera (thrown item)
    - valkyrie: spear
    - samurai: longsword
    - archaeologist: shovel (dig through wall. passive item. consumed)
    - caveman: club (is hammer)
    - ranger: turkey
    - priest: prayer book (thrown item; flammable)
    - monk: water
    - healer: water



running:
  - when running into a wall, keep momentum and rotate run direction
  - crash through walls at speed 4
    - shrapnel (if there is a torch, it is flaming shrapnel)
    - spawns rubble
    - if crashes through outer wall:
        player grabs ledge. move to get back in

clothesline:
  - unlock
  - two-sided
  - +1
  - refreshed by vault


katas:
  - special effect triggered by sequence of actions
  - trigger: up!, down!, up!
    effect: area knockback
  - trigger: up, up, down
    effect: leap down
  - carnage tornado:
      trigger: up!, left!, down!, right!
      effect: big aoe attack
  - trigger: up!, left!, right!, up!
    effect: gain rage
  - effect: gain some free turns
  - effect: gain temporary buff?
  - perk: shorten kata length
  - perk: skip a blood requirement in a kata
     

more context-based movement:
  - kick off of walls
  -             furniture
  -             items
  -             enemies


altars:
  - cover in blood to trigger something
  - grooves are initially not visible
  - lines displayed when covered in blood
  - when fully covered, unlocks a kata for the player
  - perk: blood channeling
     - blood also covers adjacent grooves



improvization:
  - weild FURNITURE
    - "you pick up the chair"
    - "you pick up the ..."
    - "you tear the door off its hinges"
    - one time use
    - attack pattern same as axe
    - brazier ignites and drops coals
  - pickup is free action
  - weild LIVING ENEMY
    - one time use
    - attack pattern as whip
    - animate throwing the enemy
    - if rage is lost, enemy is released
  - catch projectiles from rangers
    - throwable item
  - (20% / 100%) reflect fireball from wizard
    - (does not block damage)

throw:
  - thrown items pass through an additional target
  - thrown items pass through any number of targets
  - shockwave on final impact
  - throw weapon if not holding an item
  - throw at enemies when aligned







   *
  / \
 *   *
  \ /
   *


consumables:
   - water (+recovery)          |  - fatigue
   - apple (-fatigue)           |  + fatigue   + recovery
   - turkey (----- fatigue)     |  + fatigue   + recovery




