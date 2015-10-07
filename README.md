# Herder

Herder is a utility that can be used to send SNS notifications from an EMR job flow. You add it as a step, tell it which topic to post to and what subject to use, and it will post the job flow ID (a.k.a. cluster ID) as the message body.

## Usage

To use Herder you need to build a JAR and upload it to somewhere where EMR can read it:

```
$ git clone git@github.com:burtcorp/herder.git
$ cd herder
$ bundle install
$ rake build
$ aws s3 cp build/herder.jar s3://some-bucket/and/a/path/herder.jar
```

You only need to do this once, the JAR can be used in any job flow.

To get notified when a job flow completes you add Herder as the final step when launching your cluster:

```
$ aws emr create-cluster … --steps … 'Type=CUSTOM_JAR,Name=notify-complete,ActionOnFailure=CONTINUE,Jar=s3://some-bucket/and/a/path/herder.jar,Args=notify,--topic-arn,arn:aws:sns:us-north-3:1234567890:emr-notifications,--subject,"Hello from EMR"'
```

The `…` after `--steps` is where your primary steps go, and the argument that comes after is the step description for Herder. Let's break that down:

* `Type=CUSTOM_JAR`: This tells EMR that it should run an application with `hadoop jar …`.
* `Name=notify-complete`: This is the name of the step, and it can be anything.
* `ActionOnFailure=CONTINUE`: What should EMR do if this step fails (for example if the cluster doesn't have permissions to publish to the SNS topic). If the step is the last one it doesn't matter what you choose here.
* `Jar=s3://some-bucket/and/a/path/herder.jar`: The location of the JAR file to run, it must be readable by the cluster, just as with your own job JAR.
* `Args=…`: The arguments to pass to the application. EMR will run Herder as `hadoop jar herder.jar $Args`. The first argument must be `notify`, and after that you need to specify `--topic-arn ARN` and (optionally) `--subject SUBJECT`.

Make sure your cluster has the right permissions to publish to the SNS topic you specify.

## Copyright

© 2015 Burt AB, see LICENSE.txt (BSD 3-Clause).
