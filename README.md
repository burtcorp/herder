# Herder

Herder is a utility that can be used to send SNS notifications from an EMR job flow. You add it as a step, tell it which topic to post to and what subject to use, and it will post the job flow ID (a.k.a. cluster ID) as the message body.
