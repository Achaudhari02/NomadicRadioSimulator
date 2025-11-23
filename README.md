# NomadicRadioSimulator

# Context-Aware Audio Notification Simulator (Nomadic Radio–Style)

This project is a **context-aware audio notification simulator** inspired by the Nomadic Radio system.  
It uses **Processing**, **Beads**, **ControlP5**, and **FreeTTS** to sonify notification streams
(Twitter, email, text messages, phone calls, and voicemails) in real time.

The system adapts to four different user contexts — **Workout, Walking, Socializing, Presenting** — by
changing volume, filtering, text-to-speech usage, and background ambience to balance awareness and distraction.

---

## 🎧 Features

- **Real-time notification sonification** from JSON event streams.
- Supports 5 notification types:
  - Tweets
  - Emails
  - Text messages
  - Phone calls
  - Voicemails
- **Four user contexts** with different ambient sounds and policies:
  - Workout (gym)
  - Walking (outdoors)
  - Socializing (coffee shop)
  - Presenting (giving a talk)
- Uses a mix of:
  - **Auditory icons** (e.g., bird wings for tweets, mailbox for email, bell for texts, phone rings)
  - **Earcons** to convey sentiment and priority
  - **Programmatic audio** (sine/triangle wave–based cues)
  - **Text-to-speech** for high-priority notifications
  - **Filters, reverb, and envelopes** for mixing and expressiveness
- **Priority-based scheduling** using a `PriorityQueue` so higher-priority notifications are foregrounded and overlapping notifications are sequenced cleanly.
- UI built with **ControlP5**:
  - Radio buttons for context selection
  - Radio buttons for selecting JSON event streams
  - Checkboxes for enabling/disabling each notification type

---
