// shows an example of queuing and playing multiple sounds
// easily.  Note that this demo code expects a global
// "masterGain" variable to be declared elsewhere, which
// feeds into ac.out

import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;

// queue of sound filenames to play //<>//
Queue<String> soundsToPlay = new LinkedList<String>();
boolean isSoundPlaying = false;  //<>//

// load filenames for sounds into the global soundsToPlay Queue before calling PlaySounds()
// Note: You should have a way to prevent PlaySounds() from being called again while the current
// list of sounds is still playing. For example, you could use the global isSoundPlaying, or another
// global flag, to prevent PlaySounds from being called while the current list of sounds is still playing.
public void PlaySounds() {
  String soundFile = soundsToPlay.poll();
  
  if (soundFile != null) {
    // These SamplePlayers are set to killOnEnd
    SamplePlayer sound = getSamplePlayer(soundFile, true);
    sound.pause(true);
    masterGain.addInput(sound);
    
    // create endListener for first sound
    Bead endListener = new Bead() {
      public void messageReceived(Bead message) {
        // the message parameter is the SamplePlayer that triggered the
        // endListener handler, so cast it to SamplePlayer to use
        // use it's member functions
        SamplePlayer sp = (SamplePlayer) message;
        // necessary to remove this endListener or it could fire again - bug in Beads?
        sp.setEndListener(null);
        
        println("Done playing " + sp.getSample().getFileName());
        // Try to play next sound in the queue
        PlaySounds();
      }
    };
    
    // start playing first sound
    if (!isSoundPlaying) {
      println("isSoundPlaying = true");
    }
    isSoundPlaying = true;
    sound.setEndListener(endListener);
    sound.start();
  }
  else {
    isSoundPlaying = false;
    println("isSoundPlaying = false");
  }  
} //<>//
