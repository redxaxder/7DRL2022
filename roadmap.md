
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
- brazier
- bookshelf
- wall torch

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
