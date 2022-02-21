# GenshinImpactQoLBinds
An AutoHotkey script providing quality of life improvements.

--------

Current features:
- Elemental vision bound to `mouse4`
- Quick loot when holding `F`
- `CapsLock` AutoRun Toggle(holding `W`)
- Holding the `tilde(~)` key allows using the `mouse wheel` to change camera pitch (useful for looking down when gliding and aiming with archers with low mouse sensitivity)
- [^1] `R` acts as a Confirm button in menus, currently clicks on: all `confirm` buttons, `claim` buttons, `BP claim` buttons, `BP Claim All` button, `teleport` button, `navigate` button in the map and quest journal
- [^2] Dialog options can be selected with `number keys`, this only works if you're already in the dialog and not for selecting an option while running around(sorry, this seems to be impossible to achieve without major bugs at the time)
- Admin mode check (required to send keys to the game always running in admin mode)

-----

[^1]: This feature relies on [ImageSearch](https://www.autohotkey.com/docs/commands/ImageSearch.htm) that requires you to have the same(or close to it) screen resolution as the screen that the _`hint`_ was taken from due to the way the ingame buttons get blur.<br>
Currently provided _`hints`_ created with a resolution of 1920x1080.<br>
If any confirm button does not get picked up:
    1) make a screenshot of the whole screen with the menu that contains the confirm button
    2) crop the screenshot to only include the same area as the original _`hint`_ but how it looks with your resolution.
    3) replace it in the `GenshinControlHints/` folder

[^2]: This feature uses [PixelSearch](https://www.autohotkey.com/docs/commands/PixelSearch.htm) with a set of very precise coordinates to detect the dialog options being on the screen and select the correct one in correspondence to the button pressed.<br>
It is planned to shift from using "Absolute" coordinates to a ratio multiplied by the screen size that will in theory allow resolution independent coordinates (ETA unknown)
