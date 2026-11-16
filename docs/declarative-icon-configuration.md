# Declarative icon configuration (prototype)

The experimental Plasma settings implementation and build instructions are
maintained in [Oxygen-Labs, `experimental/plasma-icon-configuration`](https://invent.kde.org/libraries/oxygen-labs/-/tree/master/experimental/plasma-icon-configuration).
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

## Opt-in symbolic actions

The Action Icons tab offers work-in-progress symbolic actions at 16, 22, 32
and 48 px. All four options default to false. The shipped index lists those
paths in `X-KDE-OptionalDirectories`, outside its active `Directories` list.
Their directory sections and source artwork remain available for installation.

The configuration installer validates optional paths using the same confinement
checks as normal directories. Each optional directory must have a rule that
excludes it under the declared default values. When saving, selected optional
directories are prepended to the installed `Directories` list, giving the
explicit selection priority over base artwork. Unselected directories and
their sections are omitted. Unchecking a size or restoring defaults removes
its symbolic action paths again. The retained source allows future changes.

This requires the matching Oxygen-Labs renderer with optional-directory
support. An older renderer that only accepts active directories cannot apply
this declaration. Normal desktops ignore the optional key and use the normal
artwork. Theme archives must include optional artwork and alias targets,
including padded 24 px sources for the 48 px symbolic links.

The copy operation is bounded, serialized with a user-icon lock, staged before
activation and refuses to overwrite an unrelated same-ID user theme. It rejects external
symlinks and special files. The original installation must remain available for
future reconfiguration; source changes become visible after another Save.
