# Oxygen Icons

Oxygen Icons is a freedesktop.org compatible icon theme originally developed for the KDE Plasma desktop environment in combination with the Oxygen Style. It features smooth gradients, soft shadows, and a slightly glossy look.

![Screenshot of KMail with the Oxygen style and icon theme](https://cdn.kde.org/screenshots/oxygen/kmail-oxygen.png)

## Declarative icon configuration (prototype)

The experimental Plasma settings implementation and build instructions are
maintained in [pinheiro/oxygen2, `plasma-icon-configuration`](https://invent.kde.org/pinheiro/oxygen2/-/tree/master/plasma-icon-configuration).
That directory contains a patch against Plasma Workspace **v6.7.4**, including
the generic renderer and regression tests, plus an opt-in CMake build/installer.
Enable `INSTALL_PATCHED_ICON_SETTINGS=ON` there to build the patched settings;
installation backs up replaced files and provides a rollback command. See its
README for dependencies, distribution-specific paths and installation commands.
This feature requires that patched
Plasma implementation; Oxygen itself needs no compiled configuration component.
Unpatched desktops continue to use Oxygen normally and ignore the extra
configuration metadata.

Oxygen supplies only data: `index.theme` declares
`X-KDE-IconConfiguration=DeclarativeV1`, and `icon-settings.json` describes
the configuration title, description, tabs, checkboxes, defaults and actions.
No theme-side executable, C++, Python, script or compiled UI is needed.

The corresponding Plasma System Settings implementation provides a generic
Qt Widgets renderer. For example, a checkbox is declared as:

```json
{
  "id": "symbolic22",
  "type": "checkbox",
  "label": "Include 22 px symbolic artwork",
  "default": true
}
```

Checkboxes belong to `pages`, each with a title and a controls array. All UI
text is plain text. Controls describe only UI and defaults. A separate top-level
`installation` object requests changes to the user's theme installation:

```json
{
  "type": "userThemeCopy",
  "rules": [
    {
      "when": {"control": "symbolic22", "equals": false},
      "operation": {
        "type": "omitDirectories",
        "directories": ["applets/22x22"]
      }
    }
  ]
}
```

Plasma validates the requested installation type, condition, operation and
paths. This rule says: when `symbolic22` is false, omit `applets/22x22` and its
index entries from the user copy. External themes can use their own control IDs,
directories and conditions, including omission when a checkbox is true.
A control can trigger multiple rules, and each rule may list several
registered directories. Rules must not overlap. The only supported control is
`checkbox`; the permitted installation is `userThemeCopy`, with conditional
`omitDirectories` operations. Unknown fields, action types,
unsupported versions, escaping paths and invalid data are rejected.

Save applies settings to **Oxygen**, preserving its name, translations and
theme ID. System-wide themes get a same-ID user override, normally
`~/.local/share/icons/oxygen/`; there is no separate configured-theme tile.
Source artwork is
copied, not linked; aliases are dereferenced only within the original theme.
Output contains no symlinks or executable files. System-wide root-owned themes
work identically as long as their artwork and metadata are readable; no write
permission on the source is needed. System-installed artwork is read-only
to this operation. The system fixes the output path; theme data cannot choose
destinations, run commands, load plugins or request administrator access.

User choices are INI booleans in the generated `index.theme` under
`[X-KDE-IconConfigurationValues]`. The managed source is recorded under
`[X-KDE-GeneratedIconConfiguration]`; reopening that copy uses the original
declaration, so disabled artwork can be restored. Restore Defaults uses the
declared checkbox defaults. Cancel writes nothing; Save applies the settings
and activates the same theme immediately, without requiring the enclosing Apply.
If the theme was originally user-installed, its original artwork is retained
under `~/.local/share/icons/.icon-config-sources/<theme-id>/` before replacing
the visible installation. This hidden source is not a second theme tile.
The pencil is also available for declarative system-wide installations; it
requests a per-user override, not permission to edit the packaged installation.
The dialog identifies its original source directory.

The pencil appears only for a supported declaration and an installed generic
System Settings renderer. Editing this JSON needs no compilation. The common
renderer is part of Plasma, not Oxygen. This is a proposed KDE extension, not a
feature of unmodified released Plasma. Older desktops ignore the metadata.

Normal KDE fallback remains unchanged. Another enabled size or an inherited
theme may still provide symbolic artwork. These are artwork-directory controls,
not strict logical requested-size rules. The applet controls cover 16, 22, 24
and 32 px. The 64 px display-layout artwork is always included.
GTK/private loaders retain their own fallback rules.

A future **Actions** tab is planned to select symbolic rather than colorful
action artwork at 16, 22, 32 and 48 px. It is not enabled yet: the current
schema supports directory omission only, requires a real installation rule
for every checkbox and does not support inactive placeholder tabs. Adding that
tab requires renderer/schema support and a defined action-artwork switching
operation; omitting colorful action directories is not an equivalent replacement.

The following tab is reserved for future usage, not part of the active
`icon-settings.json`. Defaults retain colorful action artwork. Do not activate
these controls until their installation operation is implemented:

```jsonc
// For future usage: symbolic action selection is not implemented yet.
// Proposed entry in the "pages" array:
// {
//   "title": "Actions",
//   "controls": [
//     {
//       "id": "symbolicActions16",
//       "type": "checkbox",
//       "label": "Use symbolic action icons at 16 px",
//       "default": false
//     },
//     {
//       "id": "symbolicActions22",
//       "type": "checkbox",
//       "label": "Use symbolic action icons at 22 px",
//       "default": false
//     },
//     {
//       "id": "symbolicActions32",
//       "type": "checkbox",
//       "label": "Use symbolic action icons at 32 px",
//       "default": false
//     },
//     {
//       "id": "symbolicActions48",
//       "type": "checkbox",
//       "label": "Use symbolic action icons at 48 px",
//       "default": false
//     }
//   ]
// }
```

The copy operation is bounded, serialized with a user-icon lock, staged before
activation and refuses to overwrite an unrelated same-ID user theme. It rejects external
symlinks and special files. The original installation must remain available for
future reconfiguration; source changes become visible after another Save.
