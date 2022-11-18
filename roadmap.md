
V 0.2 plans:

+ fire for sure
  + particles
  + flickering
  + lighting
    + normal maps
    + rework rage bulbs into something that doesn't interact with fire lighting
  + spreading
    + a burning object knocked past an enemy should light them on fire
  X brandy interaction
    + Re-up fire duration if you smash brandy in your face when already on fire
  + Fire enrages and fatigues player
  + rogues with a dodge stop, drop, and roll to extinguish
    + make sure to change the combat log
  + Things that die from fire shouldn't splatter blood
x wizard shoots over tables/chairs
x fireball ignites furniture
+ water should put out the PC fire
+ water should clear alchohol soak
+ brazier
  + Need a class of non-flammable furniture that is grey
  + Hot coals should do stuff when you are holding them
  + handle knockback animation ala tables and chairs
+ bookshelf
+ wall torch
  + don't pick-upable torches in the middle of the room
  + be able to pick up a torch from the wall
  + turn off effects when we pick up the torch
  + dial back particles, kill smoke
  + wall sconces get bloody like a wall
  + don't let things get knocked through wall sconce
- things light up when they die
- sounds are jank
- animations are jank (e.g. when a fireball hits an enemy, the death animation
  does not line up with the fireball animation)
+ should update ui after dropping hot coals while calm
+ torches visible in unexplored rooms starting from the second floor

V 0.3 plans:

- other enemies throw themselves in front of the king to prevent his death
- visual indicator for king
- visual indicator for stairs
- weapon rack
- valkyrie changes
- priest buff
- fatigue counts upward while in rage
- running indicator
- display current floor
- consumable rebalance

BUGS:
  + wall torch flames visible in out of bounds area
  - "collides with ." messages
    - having trouble reproducing
  + consumed by flames on exiting rage
  - desync between body state changes and animations
  + pathing is jank
  - rangers can shoot through walls
  + trampling does not splat
  + furniture is not furniture-colored
  + lethal knockback does not animate
  - splat sound effect missing

technical debt ideas:
  - individual scenes for images
  - manual side-arguments
  - import constants
  - animation system rework
  - weak refs for removal detection
    - use in scheduler
    - use in location service

QOL stuff:
- An option to dial back particle effects
- Better fire deaths, unsatisfying how enemies just disappear
  - Also, we should stop emitting particles and only free enemies
    when particles are all gone
- Some kind of separator on the log so that you can tell the most
  recent turn from older turns at a glance

Strech Goals:
- dial up the anger along a curve like the zoom
- fireproof doors spawn on higher levels
- explosive items
  * molotov cocktails
  * straight up bombs
- fire perks
  * fire damage gives more rage than normal damage
  * less fatigue on fire damage
- Something to not kill
  * capital M for martyr
  * shields all its allies on death
- Ninja mob that spawns in the walls and reveals when you go near


- statues
  - calm: nudge
  - angry:
     - if there is room to knock it back, knock it back
     - knockback passes through targets unless blocked
     - statue stays intact
     - if there is no room to knock it back, heroic vandalism
- vases
  - calm: you tip over the vase. it collapses into a pile of glass. oops!
  - angry: you smash the vase. glass is scattered everywhere.
  - maybe chance for item drop

- ragdoll redemption plan:
  - instead of doing a bunch of state handoff from actor to ragdoll when it dies,
    the ragdoll will act as the "body" of the actor (as its child) while the actor
    is alive. and when the actor dies, the body will be given to the actor's parent
    and a timer will let the ragdoll make its final preparations
