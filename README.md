== INTRO

Application which stores activities and serve data in below modules.

* Ticket detail page
* Email delivery failure notification
* Ticket activity export schedule

= Activities includes User and System activities.
= User activities -> Any action performed by user on Freshdesk.
* Activity data is pushed to rabbitmq from helpkit is taken and are consumed by application and are inserted into DynamoDB and mysql.
* Only User activities are catagorized for dashboard.

= System activities -> Automated actions performed via dispatcher/supervisor/observer rules.
* System activities are stored only in DyanmoDB.

= Email delivery Failure notification -> Tracks the status of email added by agent as reply or forward
* Email activities are tracked for email sent out via mailgun and sendgrid, via webhooks.
* Once email is sent, email data with custom mail parameters are pushed to SQS with sent time.
* Webhook url should be configured with both mailgun and sendgrid portal.
* Email events received via webhook are processed and are pushed to Global SQS.
* From global SQS, its pushed to Pod specific SQS.
* Via SQS poller, Email failures are processed as activities and are inserted into DynamoDB.

== DATABASE
* AWS DynamoDB for Ticket activities
* Mysql for daily tables for Activity Export schedule

= Dynamic mysql tables(for Activity Export)
* Dashboard activities are stored in daily tables which are created dynamically for everday.
* Activities are inserted in current day table and also in next day table.
* Activities are inserted in next day table via triggers created on current day.
* Activities are queried in current day table.
* Previous day table and related triggers will be dropped while creating next day table.

== VERSION
* Ruby 2.1.5p273
* Rails 4.2.1
* aws-sdk 2.0.41
* delayed_job


== TASKS
= Thrift poller (mandatory for email events for querying DB)
* rake activity:thirft_poller

= SQS poller (for consuming activities)
* rake activity:poll

= SQS poller for delete activities request (usecase: Destroy tickets)
* rake activity:delete_activity

= Rake task for Dynamic table:
** Create current and next month table and triggers in current month table
* rake monthly_tables:create_tables

** Drop previous month table
* rake monthly_tables:drop_tables

== ERROR HANDLING
* Any exception occurred while processing the messages consumed in rake task are pushed back to its source(SQS/Rabbitmq) after introducing certain delay for each retry.
* For rabbitmq "RabbitMQ Delayed Message Plugin" is used for introducing delay between retries.
* Maximum 5 retries are allowed with the maximum delay of 300 seconds.
* After maximum retries, messages are pushed to SQS for failed activity and notification are sent via SNS.