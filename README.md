# musescore-chordsToNotes

This plugin for [MuseScore 2.0](http://musescore.org/) expands chords annotations into a few notes in voice 4, directly playable by MuseScore.

No styles, variations, bells or whistles: it's really plain, but does work.

## How-To

- [Download](https://github.com/berteh/musescore-chordsToNotes/archive/master.zip) and [install the plugin](https://musescore.org/en/handbook/plugins-0#installation) to your MuseScore 2.0+ install. Only the (qml file)[https://github.com/berteh/musescore-chordsToNotes/raw/master/chordsToNotes.qml] is needed, but the examples (in test/) are useful to try it out quickly.
- enable the chordsToNotes plugin in ``plugins > plugin manager`` dialog, restart MuseScore.
- open a score with chords, double-click on each chord to make sure MuseScore has parsed them
- run the plugin via ``plugin > Create-Notes-From-Chords``
- enjoy your new voice 4 with notes generated from the chords.

## Issues and limitations

- the need to double-click on each chord before running the plugin is a major annoyance. Any help to make MuseScore parse all chords automatically is welcome!
- would like to generate these new notes in a new staff instead of new voice in current staff. Any suggestion how to do so is welcome.
- would like to display notes with the proper length (eg whole, half,...). Any suggestion to get note length info from cursor chord/rest is welcome.

## Support

Kindly report issues or requests in the [issue tracker](https://github.com/berteh/musescore-chordsToNotes/issues).