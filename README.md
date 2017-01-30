# 200 Nights of Freedom - Glue

Ruby scripts to scrape finished typeform submissions and send emails to the submittors.
Also creates a GitHub pull request for the submission and invites the submittor to the MKE Slack.

## Getting Started

```bash
git clone https://github.com/MarchonMilwaukee/glue.git
cd glue
bundle install
```

You will need to copy the `config.sample.yml` to `config.yml` and fill in the missing config variables.
Contact nick@rokkincat.com to get access to the live credentials if needed.

```bash
rake oauth
```

This will give you a special URL to paste into your browser. 
Once you have given the correct permissions, you will get an access token from Gmail.
Paste that token into the CLI and hit enter.

```bash
rake scan
```

This will run the actual scan. THIS IS LIVE AND WILL SEND EMAILS


