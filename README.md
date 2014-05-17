# Stacktrace for Atom

*Navigate stacktraces within Atom!*

[![Build Status](https://travis-ci.org/smashwilson/stacktrace.svg?branch=master)](https://travis-ci.org/smashwilson/stacktrace?branch=master)

Given a stacktrace from a supported language, this package gives you:

 * A mile-high view of the full trace, with a few lines of context on each stack
   frame;
 * Highlighting and navigation tools to walk up and down the stack while you're
   looking at the full files.
 * Intelligent mappings from paths from other systems to yours. If it looks like
   a ruby gem path, it'll map into your `${GEM_HOME}`; if it looks like a
   virtualenv path, it'll map into your virtualenv.

## Countdown to 1.0

In the true spirit of README-driven development, these are the features that I'd
like to see in place before I mark it 1.0.

- [x] Accept stacktraces pasted into a dialog you call up from the command
  palette.
- [ ] Present a view that gives you bits of context around each frame of a
  specific stack. *(...)*
- [ ] Pluggable stacktrace recognition and parsing code.
- [ ] Map parsed frames to source files on the local filesystem.
- [ ] While a stacktrace is active, highlight individual lines from the trace
  in open editors.
- [ ] Provide commands for next-frame, previous-frame, and turning it off.
- [ ] Show a stacktrace navigation view as a bottom panel with next, previous
  and stop buttons.
