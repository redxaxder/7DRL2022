TODO:

- Make todo list


+ first pass of impl has:
  + only knights
    +t but no knockback
  + 1 level randomly chosen from a squaring
  + no items
  + rage
    + on entering rage: gain 20 rage
    + enter rage by either attacking or being attacked
    + when player is attacked: gain 10 rage and 5 fatigue
      + if fatigued and not in rage, dies
    + when player slays an enemy: gain 10 rage
  + fatigue
    + recover 1 fatigue per turn, and increase recovery rate each turn
    + just blocks rage
  + no character progression
  + handle pc death
  + all doorways are open
  + HUD: rage and fatigue levels
       + combat log
       + fatigue recovery rate
  + controls:
   + vim + wasd + arrows to move
   + . to pass
  + first dijktra map


- second pass:
   + 3 enemies
     + knight
     + monk
     + samurai
   + 3 levels
     + path to next level activates if you step on it
   + handle knockback
   + HUD: equipped weapon / item
   + yes to weapons
     + necrodancer style weapon use and management
     + sword: can attack one space diagonally. target selection ala necro whip
       + in direction player attacked
     + spear: as necro
     + broadsword: as necrodancer
       + direction based on lefthanded/righthanded
       + 70% chance character is right handed
   + yes to items
      + apple: recover 30 fatigue
      + turkey: recover all fatigue
      + water: adds 5 to fatigue recovery rate
      + space to use item
   + add doors
   + door handling when raged/calm
   + time system
      + only boost speed for player in rage
   + more fatigue effects
     + cant pick up items
   + exp and leveling system
       + triggered on exiting rage
   + a couple of perks:
       + when entering rage, start with more [10/20/30]
       + gain more rage from killing  [+1/2/3]
       + gain more rage from getting hit  [+3/6/9]
       + recovery: [+1/+1/+1] starting recovery after rage ends

other important things:
  - blood through doors
  - sometimes can't throw??
  - floating text numbers??
  - overlap player
  - sword -> club
  - animated projectiles
  + visual indicators for weapons
  + double item swap running
  + running vs items is jank
  + running mechanic
  + distinct weapon icons
  + smooth camera tracking
  + running animation speed
  + visibility
  + knockback should open doors
  + animate
  + telegraph monk knockback
  + message if trying to attack but can't
  + more clearly indicate rage / fatigue state
  + double death message
  + samurai behind open door waits in place
  + enemies pass through each other
  + attack passes through door
  + throw passes through door

- third pass:
  - wizard enemy sets things on fire
  - status effects
    - on fire. duration. indicate flame by flickering color between yellow/red/orange
        pc on fire: adds --- rage and --- fatigue each turn
    - doused in alchohol. player and wizard only. indicate by coloring purple
    - drunk. player only.
  - fire
    - all things have a flammability: this is their chance to catch fire
    - player: flammability 0, unless covered in alchohol
    - wizard: flammability 100
    - other enemies: flammability 5
    - furniture and doors: 80
    - burn for 5 turns
      - after burning, enemies Are dead. furniture or doors are ashes
    - while burning, roll to ignite adjacent spaces
    - burning enemy ai: move to adjacent space
  - ability to win
  - items:
    - brandy
  - the king
  - more fatigue effects
  - more perks: leap, tempo, charge


- fourth pass:
  - all the enemies
  - character advancement
  - fatigue effects
  - 6 levels of increasing size
  - map: add furniture


- other goals:
  - enemy mocking lines
  - specific alchohol names
  - blood trails
  - animations:
    - fireball
    - charge
    - knockback
  - screen shake?!
  - sound?!
  - splash screen


- mapgen:
  - use squarings db!


- game structure:
  - first level introduces how the game works
  - later on they become larger
  - scenario:
    - prison
      - 3 small levels
    - castle
      - 2 medium levels
    - royal quarters
      - 1 giant level
      - king is here. kill him to win

combat log:
  - fatigue recovery
  - rage gain
  - item pickup
  - 'smart action' messages
  - player attack
    - you strike the ----!
    - the knight blocks your strike! it is knocked back!
    - the --- is knocked back!
    - collision messages
      - the ___ collides with ___
  - enemy attack
      - individual attack messages
  - --- catches fire!
  - you eat the apple. delicious!
  - you choke down an entire turkey, bones and all. you feel in fighting shape.
  - [raged] you throw the [turkey/apple] at the XXXX [random available target]
  - you throw the [turkey/apple] on the ground
  - you drink the water. you feel your strength returning.
  - you smash the bottle of water against your face and wield the remaining shards
  - you smash the bottle of booze against your face and wield the remaining shards
  - you drink the booze. you're itching for a fight.

tasks:
  - load squaring as a map
  - populate map with doors/items/enemies
  - character input
    - movement (4 directions!)
    - 'smart' action selection
    - when moving into enemy, attack
      - if raging, slay
      - if not raging, "the ____ glares at you menacingly"
    - into furniture
      - if raging, smash (knockback?)
      - if not raging, "the ____ is too heavy"
    - into wall
      - if raging, "the wall refuses to get out of the way"
                   "the wall beckons for your fist
      - if not raging, "the wall blocks your escape"
    - into door
      - if raging, smash it open. knockback. flies off into what is behind it
      - if not raging, open it.
  - scheduling
  - handling knockback


- enemies
  - archaeologist
    - 2 modes: wander, flee
    - switch from wander to flee if there is violence
    - wandering gets promoted into an attack if bumps into player
    - if they are backed into a corner, they attack
    - opens doors if they are in the way
    - "the archaeologist fumbles with the doorknob"
    - "the archaeologist opens the door"
  - knight
    - first appearance: prison
    - ability: block
      - cooldown: 1
    - activation indicated by color
    - if attacked while blocking, is knocked back instead of slain
      (with usual consequences to others)
    - ai:
       - 25% chance to block instead of other action
       - approaches player if distant
       - attacks if block is on cooldown
  - ranger
    - attacks by telegraphing a tile that will be shot
    - blinking red X in space that will be shot
    - may target player space or nearby space
    - ai: cooperatively doesn't overlap with other rangers
    - attack cooldown: 3
    - arrack range: 8, taxi norm
    - states:
       - ready to fire
       - telegraphing
       - cooldown
    - ai:
       - ready: approach or shoot
       - telegraphing: do the attack!
       - cooldown: kite

  - wizard
    - attacks by shooting fireballs
    - prepares to fire when aligned with player
       - fires next turn, even if the player has moved
       - blinking wizard to telegraph fireball
    - ai:
        - when not aligned, moves to align
        - when aligned, prepares to fire

  - rogue
    - first appearance: prison
    - ability: dodge
      - use color to indiciate if ability is active
      - single use!
      - figure out dodge direction based on context
      - if there is nowhere to dodge to, no dodge!
    - ability: backstab
      - does double fatigue damage if you've just attacked elsewhere
    - ai: approach and attack
  - monk:
    - ability: knockback [3]
    - ai: approach and attack
  - tourist: camera reduces sight radius temporarily
    - ability: camera
      - applies blurry vision
      - attack from range 2-3
    - ai: move toward range 2-3, then photograph
      - applies blurry vision
      - debuff durations overlap
  - priest:
      - ability: barrier
        - "the priest starts chanting"
        - "the priest continues their chant"
        - "the priest completes their spell"
        - "a shining barrier materializes around XXX" x 10
        - radius (max norm) 2
        - effect: applies knight block effect to an enemy
      - ai:
        - if it has allies in range, starts chanting
        - otherwise, approaches the enemy closest to the player
        - if none, flees
  - samurai:
      - ability: charge
        - if they are aligned, attack with charge [5]
        - leaps over intervening enemies
      - ai: approach and attack
  - valkyrie:
    - ability: summon einherjar
       - single use
       - range: 3 [max norm]
       - cast time: 3
       - when in range of player, summons a ball [max norm: size 2] of random enemies around you
       - summoned valkyries cannot summon
     - ai: approach and attack
  - healer:
    - ability: removes rage instead of dealing damage
      - "the healer unleashes a wave of calming energy. -5 rage"
    - ai: approach and attack

fatigue :
  scaled effects:
  1: no rage: "fatigued"
  2: cant pick up items: "weak arms"
  3: radius 8 vision: "blurry vision"
  4: -1 vision: "blurry vision"
  5: -1 vision: "blurry vision"
  6: -1 vision: "blurry vision"
  8: slow [speed 2]: "limping"
  20: immobilized: "immobilized"
  threshold effects:
   : rage decay [+ fatigue/ 30 ] /turn: unnamed
   : weapon breaks [ fatigue > 100] while raged: unnamed





# Berserker
player goes into a rage when injured.
injuries do not do damage - player normally cannot be killed by attacks.
instead attacks (and some skills) apply fatigue.
after the rage ends, the player cannot rage again until fatigue recovers.
fatigue:
  - higher levels of rage (or fatigue?) introduce different fatigue effects
    - collapse
    - blind (or reduced vision)
    - unable to pick up items
    - slow (no diagonal movment?)
    - immobile (similar to collapse?)
    - hunger: if you eat something, it ends fatigue
    - if fatigue is high enough it causes rage to decay faster
    - makes your attacks less effective somehow
      - disable some perks you've gained?
    - disarmed
rage effects:
  - destroy environment
  - bust open doors
    - door flies out in a line and crushes anything in the way
  - throw enemy
  - extra life
  - perception changes:
    - IFF breakdown?
    - dialogue effects
    - enemy appearance
perks:
  - anatomy of a perk:
    - conditions to gain it:
      - leveling up?
      - level up from raging?
      - level up from plot advancement?
    - active abilities
    - passive abilities
    - cooldowns?
    - prerequisite perks?
  - when entering rage, start with more [could be set of perks: +10/20/30]
  - gain more rage from killing  [+1/2/3]
  - gain more rage from getting hit  [+3/6/9]
  - recovery: [+1/+1/+1] starting recovery after rage ends
  - rejuvenation: reduces fatigue on level-up
           [ -25%, -15%, -10% ]  cumulative: [ 25, 40, 50 ]
                                 recip:     1.33, 1.666, 2
  - leap: if after moving you're eligible to attack, make a free attack auto
           [+20%,100%]
  - tempo: after attacking, chance to not end turn
           [+20%,100%]
  - charge: when stepping directly toward an enemy, dash into them and attack
           [distance: 3, 5, infinite]
  - bull in the china shop: automatically kick doors and furniture
           [ cooldown: 5,1,0 ]
  - deep pockets: inventory is a stack of size 2
  - mean drunk: 5% chance to recover alchohol from enemies

knockback:
  - item travels at high speed in a line, crushing whatever is behind it
  - it splinters if it hits a wall
  - any furniture can be knocked back in this way when raging
    - doors
    - tables
    - chairs

combo system:
  - when you kill an enemy, you have n turns to kill another enemy
  - when combo breaks you gain fatigue
  - bonus rage for bigger combos

weapons:
  - bear hands: orthogonal attack
  - sword: can attack diagonally
  - broadsword: hits multiple spaces
    - XXX
    -  O
  - spear: 2 spaces orthogonally
  - hammer: othogonal + knockback
  - necrodancer style input

enemies:
  - one finger death punch style:
    - giant swarms of enemies that die in one hit
  - ranger: telegraphs an attack at a space
  - knight: invulnerable every nth turn
    - attacking knocks them back instead of killing
  - rogue:
    - has a dodge (with a cooldown)
    - steals items
    - maybe actually tries to kill you
    - poisons you?
  - monk: knocks player back
  - tourist: camera reduces sight radius temporarily
  - priest: some kind of protection / barrier
  - samurai: has a dash with a cooldown
  - wizard:
    - fireball
    - dodge it (or tank it!) for collateral damage
  - valkyrie:
    - summons big group of einherjar
  - healer:
    - attempts to magically soothe rage
  - archaeologist:
    - mook
other effects:
  - ruminate (increase rage)
items:
  - different effects if fatigued or raged
  - potions:
    - alchohol
      - flammable
      - induces drunkenness
      - drunk status effect:
        - when you gain rage, gain extra
      - throw to set fires
      - smash on your face to get yourself set on fire
    - water
      - recover from fatigue faster
      - recover from drunk
      - puts out fires if smashed or thrown
    - food
      - recover fatigue
player dies if attacked while fatigued (and not raging)
encouraging aggressive play:
  - combo mechanic ala crown trick?
    - combos could refresh abilities?
    - ex: an ability is usable once per rage, but is refreshed as combo reward
  - on losing rage, do an AoE attack
  - unlock things by reaching geater levels of rage
plot:
  - protagonist is angry drunk
  - captured farmer gets mad at guards after raid
    - wake up in prison
    - goal is revenge on owner of castle
    - finding other dead prisoners increases rage abilities somehow
  - king is big bad
    - holding amulet of yendor, which is discarded


vision system:
  - no los shenanigans
  - all open rooms are visible
  - enemies within within radius as visible?
  - vision norm: max norm

#####################
####    #     #######
####          #######
####    #     #######
####   @#K    #######
#####################



character advancement:
  choose from list of perks on level-up

exp system:
  cumulative exp bonus based on # enemies killed during this rage
  caps out at some level

  exp to gain a level: 300, 400, 500, 600, etc...






speeds:
   player rage speed: 6
   enemy speed: 3
   player non-rage speed: 3
   player slowed speed: 2

1|       *  *
2|    *     *
3|  *    *  *
4|    *
5|       *  *



pathing algo
  - generate dijkstra map for approaching player
    second one for wizards
       - sources are spaces orthogonal to player that are not across walls
    third one for priests
       - sources are enemies that are tied for closest taxi distance to player
    fourth one for fleeing locations
       - first, expent the player approach map through doors
       - then, as brogue, multiply the values by -1.2 or so
       - then, do "dijkstra easing" on the result



butler push web redxaxder/7drl2022:HTML5
