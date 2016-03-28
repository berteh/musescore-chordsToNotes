//=============================================================================
//  MuseScore - Chords to Staff notation plugin
//
//  Copyright (C) 2015 Berteh - https://github.com/berteh/musescore-chordsToNotes/
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//
//  documentation: https://github.com/berteh/musescore-chordsToNotes/
//  support: https://github.com/berteh/musescore-chordsToNotes/issues
//=============================================================================

import QtQuick 2.0
import MuseScore 1.0

MuseScore {
      version:  "0.2"
      description: "This plugin expands chords into a few notes in an additional staff, directly playable by MuseScore. No styles, variations, bells or whistles: it's really plain."    
      menuPath: "Plugins.Create-Notes-From-Chords"

      /** return harmony of segment if any, null if none */
      function getSegmentHarmony(segment) {
            if (segment.segmentType != Segment.ChordRest) 
                  return null;
            var aCount = 0;
            var annotation = segment.annotations[aCount];
            while (annotation) {
                  if (annotation.type == Element.HARMONY)
                        return annotation;
                  annotation = segment.annotations[++aCount];     
            }
            return null;
      } 

      /** convert tpc to midi note info in the form [base pitch class, midi number, letter, alteration]      
      docs at
       https://musescore.org/en/plugin-development/tonal-pitch-class-enum
       http://www.tonalsoft.com/pub/news/pitch-bend.aspx */
      function tpcToMIDI(tpc) {
            var referenceC = 48; //48 for C in octave -1, inc-/de-crease by 12 for each octave up/down.          
            var classes = [3,10,5,0,7,2,9,4,11,6,1,8];
            var letters = ['F','C','G','D','A','E','B'];

            var cls = classes[((tpc-2+12)%12)+3]; //tpc to class
            var midi = (( ((tpc-2+12)%12) *7)%12) + referenceC;   //tpc to midi number
            var letter = letters[(tpc+1)%7];
            var alt = "";
            if (tpc<6) alt = "bb";
            else if (tpc<13) alt = "b";
            else if (tpc<20) alt = "";
            else if (tpc<27) alt = "#";
            else alt = "##";

            return [cls, midi, letter, alt];
      }

      /** create and return a new Note element with given (midi) pitch, tpc1, tpc2 and headtype */
      function createNote(pitch, tpc1, tpc2, head){
          var note = newElement(Element.NOTE);
          note.pitch = pitch;
          note.tpc1 = tpc1;
          note.tpc2 = tpc2;
          if (head) note.headType = head; 
          else note.headType = NoteHead.HEAD_AUTO;
          //console.log("  created note with tpc: ",tpc1," ",tpc2," pitch: ",pitch);
          return note;
      }

      /** returns the list of semitones that compose the chord variant "str".
        must first be called case sensitive to have "m" handled as minor */  
      function chordSuffixToSemitoneNumbers(str, case_insensitive) { //adapted from Scott Davies music.js, would prefer to use parsing mechanism of MuseScore but it seems not accessible from QML API
          var chords = [
            [ ["", "M", "maj", "major"], [0, 4, 7], "Major" ],
            [ ["m", "-", "min", "minor"], [0, 3, 7], "Minor" ],
            [ ["7"], [0, 4, 7, 10], "Dominant Seventh" ],
            [ ["min7", "m7", "minor7"], [0, 3, 7, 10], "Minor Seventh"],
            [ ["maj7", "t", "Major7"], [0, 4, 7, 11], "Major Seventh"],
            [ ["sus4", "sus"], [0, 5, 7], "Suspended Fourth"],
            [ ["7sus4", "7sus"], [0, 5, 7, 10], "Seventh Suspended Fourth"],
            [ ["6", "maj6", "major6"], [0, 4, 7, 9], "Sixth"],
            [ ["min6", "m6", "minor6"], [0, 3, 7, 9], "Minor Sixth"],
            [ ["dim", "dim7", "diminished", "o"], [0, 3, 6], "Diminished Seventh"],
            [ ["aug", "+", "augmented"], [0, 4, 8], "Augmented"],
            [ ["7-5", "7b5"], [0, 4, 6, 10], "Seventh Diminished Fifth"],
            [ ["7+5", "7#5"], [0, 4, 8, 10], "Seventh Augmented Fifth"],
            [ ["m7-5", "m7b5", "0"], [0, 3, 6, 10], "Half Diminished Seventh"],
            [ ["m/maj7"], [0, 3, 7, 11], "Minor/Major Seventh"], 
            [ ["maj7+5", "maj7#5"], [0, 4, 8, 11], "Major Seventh Augmented Fifth"],
            [ ["maj7-5", "maj7b5"], [0, 4, 6, 11], "Major Seventh Diminished Fifth"],
            [ ["9"], [0, 4, 7, 10, 14], "Ninth" ],
            [ ["m9"], [0, 3, 7, 10, 14], "Minor Ninth"],   
            [ ["maj9"], [0, 4, 7, 11, 14], "Major Ninth"],
            [ ["7+9", "7#9"], [0, 4, 7, 10, 15], "Seventh Augmented Ninth"],
            [ ["7-9", "7b9"], [0, 4, 7, 10, 13], "Seventh Diminished Ninth"],
            [ ["7+9-5", "7#9b5"], [0, 4, 6, 10, 15], "Seventh Augmented Ninth Diminished Fifth"],
            [ ["6/9", "69"], [0, 4, 7, 9, 14], "Sixth/Ninth"],
            [ ["9+5", "9#5"], [0, 4, 8, 10, 14], "Ninth Augmented Fifth"],
            [ ["9-5", "9b5"], [0, 4, 6, 10, 14], "Ninth Diminished Fifth"],
            [ ["m9-5", "m9b5"], [0, 3, 6, 10, 14], "Minor Ninth Diminished Fifth"],
            [ ["11"], [0, 4, 7, 10, 14, 17], "Eleventh"],
            [ ["m11"], [0, 3, 7, 10, 14, 17], "Minor Eleventh"],
            [ ["11-9", "11b9"], [0, 4, 7, 10, 13, 17], "Eleventh Diminished Ninth"],
            [ ["13"], [0, 4, 7, 10, 14, 17, 21], "Thirteenth"],
            [ ["m13"], [0, 3, 7, 10, 14, 17, 21], "Minor Thirteenth"],
            [ ["maj13"], [0, 4, 7, 11, 14, 17, 21], "Major Thirteenth"],
            [ ["add9", "(add9)"], [0, 4, 7, 14], "Major (Add Ninth)" ],
            [ ["madd9", "m(add9)"], [0, 3, 7, 14], "Minor (Add Ninth)"],
            [ ["sus2"], [0, 2, 7], "Suspended Second" ],
            [ ["5"], [0, 7], "Power Chord" ]
          ];


            for (var i = 0; i < chords.length; ++i) {
                var names = chords[i][0];
                for (var j = 0; j < names.length; ++j) {
                  var name = names[j];
                  if (name == str || (case_insensitive &&(name.toLowerCase() == str.toLowerCase()))) { 
                      return chords[i][1]; 
                  }
                }
            }
            if (!case_insensitive) {
                return chordSuffixToSemitoneNumbers(str, true);
              } else {
                return null;
            }
      }

      /** returns tpc of note that is #semitone half-tones higher than rootTPC
            eg: semitoneToTPC (tpc of C#, 4) = tpc of E# */
      function semitoneToTPC(rootTpc, semitone){
            var semiToTpcDiff = [0, 7, 2, -3, 4, -1, -6, 1, 8, 3, -2, 5];
            return (rootTpc + semiToTpcDiff[semitone%12]);
      }

      /** touch/dirty all chords & redo layout to make sure they are all parsed.
          TODO find a way to implement, so far nothing below seems to work */
      function touchChords(){
            console.log("redoing layout of score to parse chords.");
            curScore.doReLayout; //no effect

            var cursor = curScore.newCursor();
            cursor.rewind(0);
            var segment, harmony, chord;

            while (segment = cursor.segment) {                                     
                  harmony = getSegmentHarmony(segment);
                  if (harmony) {
                        harmony.dirty = true;
                        harmony.setDirty;
                        curScore.setPlaylistDirty;
                        curScore.doLayout();

                        segment.setDirty;
                        curScore.doLayout();
                  }

                  cursor.next();
            }
      }


      onRun: {
            if (typeof curScore === 'undefined') {
                  console.log("Generating no Notes from Chords. Please open a score before calling execution this function.");
                  Qt.quit();
            }     
            
            console.log("Generating Notes from Chords");

            //todo: layout all chords, to make sure they are parsed. https://musescore.org/en/node/64031#comment-292216            
            //touchChords(); //todo fix: does not work, how to parse all chords?

            var cursor = curScore.newCursor();
            cursor.rewind(0); // beginning of score
            
            var voice=3; var old_voice=0;
            var segment, harmony, chord, time, tpc, duration, head, text, info, cls, pitch, letter, alt, suffix, semitones;

            while (segment = cursor.segment) {                                     
                  harmony = getSegmentHarmony(segment);
                  if (harmony) {
           
                        time = cursor.tick;
                        chord = harmony.parent.elementAt(0);
                        duration = chord.duration;
                        if (cursor.isChord ) head = chord.notes[0].headType; //todo fix: how to get "effective" note head type when "HEAD_AUTO" is used in source chord?
                        else if (cursor.isRest ) head = NoteHead.HEAD_AUTO; //todo fix: how to get rest length and convert to note head type?
                        text = harmony.text; // todo fix: where to find chord text if MuseScore did not parse/recognize the Harmony name?
                        console.log("got harmony ",text," at time ", time," with root: ",harmony.rootTpc," bass: ",harmony.baseTpc);
                        //if (head==255) console.log("!  harmony length could not be found, kindly file bug report to help");
                        
                        //create new Chord in same segment //todo create in new staff
                        var tempChord = newElement(Element.CHORD);

                        //add explicit bass note if any
                        if (harmony.baseTpc > -2){
                              info = tpcToMIDI(harmony.baseTpc);
                              pitch = info[1];
                              tempChord.add( createNote(pitch, harmony.baseTpc, harmony.baseTpc, head ));
                        }

                        //add root note
                        tpc = harmony.rootTpc;
                        info = tpcToMIDI(tpc);
                        cls = info[0]; pitch = info[1]; letter = info[2]; alt = info[3];
                        tempChord.add( createNote(pitch, tpc, tpc, head ));                        

                        //add other notes //todo how to use MuseScore parsing features to get list of degrees/semitones directly?
                        if(text) {
                              suffix = text.substring(alt.length+1);//get rid of Root (&opt. alteration)
                              suffix = suffix.replace(/^(.*?)(\/[A-G][b#]*)$/, "$1");//get rid of Bass if any
                              
                              semitones = chordSuffixToSemitoneNumbers(suffix, false);
                              if (semitones) {
                                    var semiTpc = 0;
                                    for (var s = 1; s < semitones.length; ++s) {//skip semitone[0], root is already added
//                                          console.log("  adding semitone: ",semitones[s]);  
                                          semiTpc = semitoneToTPC(tpc, semitones[s]);
                                          tempChord.add( createNote(pitch+semitones[s], semiTpc, semiTpc, head ));                             
                                    }                                    
                              }     
                              else console.log("!  semitones not found for chord ",text," with suffix: ",suffix,", please file a bug report to help manage more chords suffix");
                        } else console.log("!  MuseScore has not parsed/recognized the chord notation, please click once on it to force MS to parse it, and rewrite if needed");

                        //add full chord
                        tempChord.duration = duration;  //play duration                      
                        tempChord.visible = true;
                        cursor.voice = voice;
                        cursor.add(tempChord);
                        cursor.voice = old_voice;                      
                  }
                  cursor.next();
            }
      
            console.log("generation complete");     
            Qt.quit();
      }
}
