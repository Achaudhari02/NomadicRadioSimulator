Assignment Description of Events:

Twitter: timestamp, tweet author, tweet text, priority (1-4 where 1 is lowest priority and 4 is highest), number of retweets, number of favorites
Email: time stamp, email sender, email text, priority (1-4 where 1 is lowest priority and 4 is highest), email content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)
Text message: time stamp, text sender, text, priority (1-4 where 1 is lowest priority and 4 is highest), text content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)
Phone call: time stamp, caller (name or phone number), priority (1-4 where 1 is lowest priority and 4 is highest)
Voice Mail: time stamp,  caller (name or phone number), voicemail message as text, priority (1-4 where 1 is lowest priority and 4 is highest), voicemail content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)


JSON Format for Events:

type: string -> "Tweet", "Email", "TextMessage", "PhoneCall", "VoiceMail"
timestamp: in milliseconds from sketch start, e.g. 200 = 0.2 seconds
sender: string of sender/tweet author/caller name/id
priority: int from 1-4 (low to high)

//optional parameters
message: string, content of message/tweet, should be omitted for PhoneCall event
contentSummary: int from 1-3, should be omitted for Tweet and PhoneCall events
retweets: number of retweets, should be omitted for non-Tweet events
favorites: number of favorites, should be omitted for non-Tweet events

