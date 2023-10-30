# Termcut - Terminal client for Shortcut

This is a minimal terminal client (TUI) for the project management
tool Shortcut.

The goal is to provide a fast way to browser epics and their stories,
and to allow creating or switching to the associated feature branch of
a story.

It's a view-only client with this specific Git feature on top, and is
not meant to be a fully functional Shortcut client.

## Quick start

1) Clone this repo and create an alias to the `run` script in the root, eg.

```
alias sc='~/projects/termcut/run'
```

2) Create a Shortcut API token
[here](https://app.shortcut.com/gomore/settings/account/api-tokens)
and store it in `~/.shortcut-api-token`.

When starting the tool, you should be able to see a list of epics. See
the help line at the bottom for keyboard shortcuts.

## Notes

This was built for a "hack day" at work to play with curses and the
Shortcut API. The code is messy in places and the tool is far from
finished.
