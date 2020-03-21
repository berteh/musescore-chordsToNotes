# musescore-chordsToNotes

The [harmony playback feature is now available in MuseScore 3](https://github.com/musescore/MuseScore/pull/5129#issuecomment-601717806), development of this plugin is thus stopped, thanks for you feedback and positive comments in the past.

A better looking alternative for MuseScore 2 is https://musescore.org/en/project/notes-chord-texts

# ARCHIVE

This plugin for [MuseScore 2.0](http://musescore.org/) expands chords annotations into a few notes in voice 4, directly playable by MuseScore.

No styles, variations, bells or whistles: it's really plain, but does work.

## How-To

- Check out if you rather use [improved version](https://github.com/berteh/musescore-chordsToNotes/issues/9#issue-368060822) by @Bacchushlg, with
> * automatic creation of a new staff line (only one initial staff is accepted in the moment)
> * correct chord length according to the distance to the next chord symbol
> * some additional chords and synonyms (as found in several scores that I tested)
- [Download](https://github.com/berteh/musescore-chordsToNotes/archive/master.zip) and [install the plugin](https://musescore.org/en/handbook/plugins-0#installation) to your MuseScore 2.0+ install. Only the [qml file]([https://github.com/berteh/musescore-chordsToNotes/raw/master/chordsToNotes.qml) is needed, but the examples (in [test/](https://github.com/berteh/musescore-chordsToNotes/tree/master/test)) are useful to try it out quickly.
- enable the chordsToNotes plugin in ``plugins > plugin manager`` dialog, restart MuseScore.
- open a score with chords, make sure MuseScore has parsed them all by hitting F2 (transpose to anything) and SHIFT-F2 (to transpose back)... or simply transpose to a prime (or just to the current key) - so nothing is really changed
- run the plugin via ``plugin > Create-Notes-From-Chords``
- enjoy your new voice 4 with notes generated from the chords, and use [MuseScore shortcuts](see https://musescore.org/en/handbook/note-input) to quickly change the proposed chords to you liking (eg ctrl up/down to move a note up/down one octave)

## Issues and limitations

- I would like to generate these new notes in a new staff instead of new voice in current staff. Any suggestion how to do so is welcome.
- I would like to display notes with the proper length (eg whole, half,...). Any suggestion to get note length info from cursor chord/rest is welcome.

## Support

Kindly report issues or requests in the [issue tracker](https://github.com/berteh/musescore-chordsToNotes/issues).
