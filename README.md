# OCS plugins and apps for Godot
This repo contains all of One Cat Studio's plugins and apps. All of them are functionality that is commonly used in game development.
To make it to this repo, a plugin/app must be easy to use and integrate into any particular project.

Feel free to check this repo's wiki for the docs!

## OCS Font Manager v. 0.9
Font Manager is a singletone for Godot that simplifies font management. Instead of creating numerous .tres files, it allows to register locales and font presets (somewhat similar to Bootstrap).
By adding rules (called overrides) each locale, having a particular font, can be adjusted for all it's presets to cover font differences in general sizes and outline sizes.


## OCS Fast Lib v 0.01
OCS Fast Lib's purpose is to simplify math, geometry and other commonly faced routines. It's basically a header file with math functions that check conditions or calculate stuff that is often used in game development.


## OCS Version Controlled Saves v.0.2
OCS VCSaves is a singletone for savefile version control and resolving deltas between savefiles (e.g. on device and in cloud). It also repairs savefiles that belong to older game version and are structurally outdated, preventing crashes even when game savefile structure changes.

------------

### ReadMe Last updated: May 31, 2022