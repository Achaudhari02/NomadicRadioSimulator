import beads.*;
import controlP5.*;
import java.util.*;

AudioContext ac;
ControlP5 p5;
NotificationServer server;
Gain masterGain;
SpeechWrapper speech;

// Background sound players
SamplePlayer gymContext, walkingContext, socializingContext, presentingContext;
Gain backgroundGain;

// Event type toggles
boolean TweetBool = true;
boolean EmailBool = true;
boolean TextBool = true;
boolean CallsBool = true;
boolean VoicemailsBool = true;


// Context states
enum Context {
  GYM, WALKING, SOCIALIZING, PRESENTING
}
Context currContext = Context.GYM;


// Priority queue for notifications
PriorityQueue<Notification> notificationQueue;

void setup() {
  size(800, 600);
  background(200);

  // Initialize audio context and master gain
  ac = new AudioContext();
  masterGain = new Gain(ac, 1, 0.5);
  ac.out.addInput(masterGain);

  // Initialize background sounds gain
  backgroundGain = new Gain(ac, 1, 0.3);
  masterGain.addInput(backgroundGain);

  // Setup context background sounds
  gymContext = getSamplePlayer("gym_ambience.wav");
  walkingContext = getSamplePlayer("walking_ambience.wav");
  socializingContext = getSamplePlayer("socializing.wav");
  presentingContext = getSamplePlayer("presentation.wav");

  gymContext.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  walkingContext.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  socializingContext.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  presentingContext.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  backgroundGain.addInput(gymContext);
  backgroundGain.addInput(walkingContext);
  backgroundGain.addInput(socializingContext);
  backgroundGain.addInput(presentingContext);

  // Initially pause all but gym sound
  walkingContext.pause(true);
  socializingContext.pause(true);
  presentingContext.pause(true);

  // Initialize ControlP5
  p5 = new ControlP5(this);
    // Context selection
  p5.addRadioButton("chooseContext")
    .setPosition(20, 20)
    .setSize(50, 50)
    .addItem("Gym", 0)
    .addItem("Walking", 1)
    .addItem("Socializing", 2)
    .addItem("Presenting", 3)
    .activate(0);

  // Event stream selection
  p5.addRadioButton("chooseData")
    .setPosition(150, 20)
    .setSize(50, 50)
    .addItem("Data 1", 0)
    .addItem("Data 2", 1)
    .addItem("Data 3", 2);

  // Event type toggles
  p5.addCheckBox("toggleData")
    .setPosition(300, 20)
    .setSize(50, 50)
    .addItem("Tweets", 0)
    .addItem("Emails", 1)
    .addItem("Texts", 2)
    .addItem("Calls", 3)
    .addItem("Voicemails", 4)
    .activate(0)
    .activate(1)
    .activate(2)
    .activate(3)
    .activate(4);

  // Initialize notification server and speech
  server = new NotificationServer();
  speech = new SpeechWrapper();

  // Initialize notification queue with priority comparator
  notificationQueue = new PriorityQueue<>(10, (n1, n2) ->
    Integer.compare(n2.getPriorityLevel(), n1.getPriorityLevel()));

  // Add notification listener
  server.addListener(new AudioNotificationListener());

  ac.start();
}



void chooseContext(int value) {
  // Pause all background sounds
  gymContext.pause(true);
  walkingContext.pause(true);
  socializingContext.pause(true);
  presentingContext.pause(true);

  // Set current context and activate appropriate background sound
  switch(value) {
  case 0:
    currContext = Context.GYM;
    gymContext.pause(false);
    backgroundGain.setGain(0.3f);
    break;
  case 1:
    currContext = Context.WALKING;
    walkingContext.pause(false);
    backgroundGain.setGain(0.2f);
    break;
  case 2:
    currContext = Context.SOCIALIZING;
    socializingContext.pause(false);
    backgroundGain.setGain(0.15f);
    break;
  case 3:
    currContext = Context.PRESENTING;
    presentingContext.pause(false);
    backgroundGain.setGain(0.1f);
    break;
  }
}

void chooseData(int value) {
  server.purgeTasksAndCancel();
  String filename = "ExampleData_" + (value + 1) + ".json";
  server.loadAndScheduleJSONData(loadJSONArray(filename));
}

void toggleData(float[] values) {
  TweetBool = values[0] == 1.0;
  EmailBool = values[1] == 1.0;
  TextBool = values[2] == 1.0;
  CallsBool = values[3] == 1.0;
  VoicemailsBool = values[4] == 1.0;
}

class AudioNotificationListener implements NotificationListener {

  private Static pitchUp;
  private Static pitchDown;
  private Static pitchNormal;

  public AudioNotificationListener() {
    pitchUp = new Static(ac, 2.0f);
    pitchDown = new Static(ac, 0.25f);
    pitchNormal = new Static(ac, 1.0f);
  }
  public void notificationReceived(Notification notification) {
    // Check if this type of notification is enabled
    if (!isNotificationTypeEnabled(notification)) return;

    // Add to priority queue
    notificationQueue.add(notification);

    // Process queue
    notificationQueue();
  }

  private boolean isNotificationTypeEnabled(Notification notification) {
    if(currContext == Context.PRESENTING){
      if(notification.getPriorityLevel() < 3){
        return false;
      }
    }
    switch(notification.getType()) {
    case Tweet:
      return TweetBool;
    case Email:
      return EmailBool;
    case TextMessage:
      return TextBool;
    case PhoneCall:
      return CallsBool;
    case VoiceMail:
      return VoicemailsBool;
    default:
      return false;
    }
  }

private void notificationQueue() {
  if (!notificationQueue.isEmpty()) {
    Notification notification = notificationQueue.poll();
    
    // Play the current notification
    playNotificationSound(notification);
    
    // Schedule processing of next notification after a delay
    Timer timer = new Timer();
    timer.schedule(new TimerTask() {
      @Override
      public void run() {
        notificationQueue(); 
      }
    }, getNotificationDuration(notification));
  }
}

private long getNotificationDuration(Notification notification) {
  switch(notification.getType()) {
    case Tweet:
      return 2000; // 800ms for tweet sounds
    case Email:
      return 2500; // 1.2s for email sounds
    case TextMessage:
      return 2000; // 1s for text sounds
    case PhoneCall:
      return 3500; // 1.5s for call sounds  
    case VoiceMail:
      return 2300; // 1.3s for voicemail sounds
    default:
      return 2500; // Default 1s delay
  }
}

  private void playNotificationSound(Notification notification) {
    // Base gain for the notification sound
    float baseGain = contextGain();

    switch(notification.getType()) {
    case Tweet:
      tweet(notification, baseGain);
      break;
    case Email:
      email(notification, baseGain);
      break;
    case TextMessage:
      text(notification, baseGain);
      break;
    case PhoneCall:
      call(notification, baseGain);
      break;
    case VoiceMail:
      voicemail(notification, baseGain);
      break;
    }
  }

  private float contextGain() {
    switch(currContext) {
    case GYM:
      return 0.8f;
    case WALKING:
      return 0.6f;
    case SOCIALIZING:
      return 0.4f;
    case PRESENTING:
      return 0.01f;
    default:
      return 0.5f;
    }
  }

  private void tweet(Notification notification, float baseGain) {
    // Bird wings flapping sound
    SamplePlayer wingSound = getSamplePlayer("bird_wings.wav");
    Gain wingGain = new Gain(ac, 1, baseGain);
    wingGain.addInput(wingSound);
    masterGain.addInput(wingGain);

    // Priority-based frequency modulation
    WavePlayer sine = new WavePlayer(ac, 440.0f * notification.getPriorityLevel(), Buffer.SINE);
    Gain sineGain = new Gain(ac, 1, 0.001f * baseGain);
    sineGain.addInput(sine);
    Envelope sineEnv = new Envelope(ac,0.0f);
    sineEnv.addSegment(1.0f,10);
    sineEnv.addSegment(1.0f,500);
    sineEnv.addSegment(0.0f,200);
    sineGain.setGain(sineEnv);
    
    // using HighPass to make sounds more softer and quite
    BiquadFilter lpFilter = new BiquadFilter(ac,BiquadFilter.HP,5000,0.5f);
    lpFilter.addInput(sineGain);
    masterGain.addInput(lpFilter);

    // High priority tweets get text-to-speech
    if (notification.getPriorityLevel() >= 3 && useSpeech()) {
      speech.textToSpeechAudio("Tweet from " + notification.getSender());
    }
  }

  private void email(Notification notification, float baseGain) {
    // Mailbox sound
    SamplePlayer mailSound = getSamplePlayer("mailbox_open.wav");
    Gain mailGain = new Gain(ac, 1, baseGain);
    mailGain.addInput(mailSound);
    masterGain.addInput(mailGain);

    // Sentiment-based earcon
    SamplePlayer jingle = getSamplePlayer("base_jingle2.wav", true);
    Gain jingleGain = new Gain(ac, 1, 0.2f * baseGain);

    //jingle.setPitch(new Static(ac,1.0f));
    if (notification.getContentSummary() == 1) {
      jingle.setPitch(pitchNormal);
      jingle.setPitch(pitchUp);
      println("Positive sentiment - pitching jingle up");
    } else if (notification.getContentSummary() == 3) {
      jingle.setPitch(pitchNormal);
      jingle.setPitch(pitchDown);
      println("Negative sentiment - pitching jingle down");
    } else {
      jingle.setPitch(pitchNormal);
      println("Neutral sentiment - using base pitch");
    }

    jingleGain.addInput(jingle);
    masterGain.addInput(jingleGain);



    // High priority emails get text-to-speech
    if (notification.getPriorityLevel() >= 3 && useSpeech()) {
      speech.textToSpeechAudio("Email from " + notification.getSender());
    }
  }

  private void text(Notification notification, float baseGain) {
    // Bell sound
    SamplePlayer bellSound = getSamplePlayer("bell.wav",true);
    Gain bellGain = new Gain(ac, 1, baseGain);
    bellGain.addInput(bellSound);
    masterGain.addInput(bellGain);

    SamplePlayer jingle = getSamplePlayer("base_jingle.wav", true);
    Gain jingleGain = new Gain(ac, 1, 0.2f*baseGain);
    if (notification.getContentSummary() == 1) {
      jingle.setPitch(pitchUp);
      bellSound.setPitch(pitchUp);
      println("Positive sentiment text - pitching jingle up");
    } else if (notification.getContentSummary() == 3) {
      jingle.setPitch(pitchDown);
      bellSound.setPitch(pitchDown);
      println("Negative sentiment text - pitching jingle down");
    } else {
      jingle.setPitch(pitchNormal);
      bellSound.setPitch(pitchNormal);
      println("Neutral sentiment text - using base pitch");
    }
    
    jingleGain.addInput(jingle);
    masterGain.addInput(jingleGain);
    // Apply attack/decay envelope based on priority
    float attackTime = notification.getPriorityLevel() >= 3 ? 500.0f : 250.0f;
    float decayTime = notification.getPriorityLevel() >= 3 ? 500.0f : 250.0f;
    Envelope envelope = new Envelope(ac, 0.0f);
    envelope.addSegment(1.0f, attackTime);
    envelope.addSegment(0.0f, decayTime);
    jingleGain.setGain(envelope);

    // High priority texts get text-to-speech
    if (notification.getPriorityLevel() >= 3 && useSpeech()) {
      speech.textToSpeechAudio("Message from " + notification.getSender());
    }
  }

  private void call(Notification notification, float baseGain) {
    // Phone ring sound repeated based on priority
    for (int i = 0; i < notification.getPriorityLevel(); i++) {
      SamplePlayer ringSound = getSamplePlayer("phone_ring.wav");
      Gain ringGain = new Gain(ac, 1, baseGain);
      ringGain.addInput(ringSound);
      
      SamplePlayer ringSound2 = getSamplePlayer("phone_ring2.wav");
      Gain ringGain2 = new Gain(ac,1,baseGain * 0.5);
      ringGain2.addInput(ringSound2);

      // Add reverb for lower priority calls
      if (notification.getPriorityLevel() <= 2) {
        Reverb reverb = new Reverb(ac);
        reverb.setSize(0.9f);
        reverb.setDamping(0.5f);
        reverb.addInput(ringGain);
        masterGain.addInput(reverb);
      } else {
        masterGain.addInput(ringGain2);
      }
    }

    // High priority calls get text-to-speech
    if (notification.getPriorityLevel() >= 3 && useSpeech()) {
      speech.textToSpeechAudio("Call from " + notification.getSender());
    }
  }

  private void voicemail(Notification notification, float baseGain) {
    // Short ring + beep
    SamplePlayer vmSound = getSamplePlayer("voicemail_ring.wav");
    Gain vmGain = new Gain(ac, 1, baseGain);
    vmGain.addInput(vmSound);
    masterGain.addInput(vmGain);

    // Pulsating tone based on priority
    float pulseRate = 4.0f * notification.getPriorityLevel();
    WavePlayer sine = new WavePlayer(ac, 220.0f, Buffer.SINE);
    Gain sineGain = new Gain(ac, 1, 0.2f * baseGain);
    sineGain.addInput(sine);

    // Modulate amplitude with envelope
    Envelope pulseEnv = new Envelope(ac, 0.0f);
    pulseEnv.addSegment(1.0f, 10000.0f / pulseRate);
    pulseEnv.addSegment(0.0f, 10000.0f / pulseRate);
    sineGain.setGain(pulseEnv);
    if(notification.getPriorityLevel() <= 2){
      Reverb reverb = new Reverb(ac);
      reverb.setSize(0.1f);
      reverb.setDamping(0.9f);
      reverb.addInput(sineGain);
      masterGain.addInput(reverb);
    
    }else{
      masterGain.addInput(sineGain);
    }


    // High priority voicemails get text-to-speech
    if (notification.getPriorityLevel() >= 3 && useSpeech()) {
      speech.textToSpeechAudio("Voicemail from " + notification.getSender());
    }
  }

  private boolean useSpeech() {
    // Only use speech for workout and walking contexts
    return currContext == Context.GYM || currContext == Context.WALKING;
  }
}

void draw() {
  // Update visualization if needed
  background(1);
}
