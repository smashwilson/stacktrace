# Stacktrace for Atom

*Navigate stacktraces within Atom!*

[![Build Status](https://travis-ci.org/smashwilson/stacktrace.svg?branch=master)](https://travis-ci.org/smashwilson/stacktrace?branch=master)

Given a stacktrace from a supported language, this package gives you:

 * A mile-high view of the full trace, with a few lines of context on each stack
   frame;
 * Highlighting and navigation tools to walk up and down the stack while you're
   looking at the full files.
 * *[planned]* Intelligent mappings from paths from other systems to yours. If it looks like
   a ruby gem path, it'll map into your `${GEM_HOME}`; if it looks like a
   virtualenv path, it'll map into your virtualenv.

## Installation

```apm install stacktrace```

## Obligatory Animated Gif

![walkthrough](https://cloud.githubusercontent.com/assets/17565/4100060/aa761e90-307e-11e4-83c8-e4bf04c20d95.gif)

## Commands

Stacktrace is a **Bring Your Own Keybinding** :tm: package. Rather than try to guess a set of bindings that won't collide with any other package, or that aren't six-key chords, I'm not providing any default keybindings.

To set hotkeys for stacktrace commands, invoke `Application: Open Your Keymap` from the command palette, and add a section like this one:

```coffee
'.workspace':
  'alt-s enter': 'stacktrace:from-selection'
  'alt-s p': 'stacktrace:paste'
  'alt-s up': 'stacktrace:to-caller'
  'alt-s down': 'stacktrace:follow-call'
```

## Language Support

Stacktraces are currently recognized in the following languages:

 * Ruby
 * (Java|Coffee)script

## Countdown to 1.0

In the true spirit of README-driven development, these are the features that I'd
like to see in place before I mark it 1.0.

- [x] Accept stacktraces pasted into a dialog you call up from the command
  palette.
- [x] Present a view that gives you bits of context around each frame of a
  specific stack.
- [x] Pluggable stacktrace recognition and parsing code.
- [ ] Map parsed frames to source files on the local filesystem.
- [x] While a stacktrace is active, highlight individual lines from the trace
  in open editors.
- [x] Provide commands for next-frame, previous-frame, and turning it off.
- [x] Show a stacktrace navigation view as a bottom panel with next, previous
  and stop buttons.
