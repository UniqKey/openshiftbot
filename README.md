# Openshiftbot the friendly openshift hubot

Openshiftbot is a hubot focusing on chatops culture where commands such as `promote webapp` are run from within the chat channels where you work (e.g. Slack). Rather than slacking a question ”is the feature deployed” look at what openshiftbot has said else ask it a question. 

Currently the focus is getting something immediately useful for our deployments. You can always fork and customised to your purposes. We would consider refactoring it to be a plug-in if there is interest. 

# Approach

Slack has a flexible `/remind #channel some message text every Monday` feature. This allows you to set up `robot.hear /some message (.*)\?/i` matchers that will trigger on a schedule and can scan for upstream container image patches or poll openshift to report on activity. 

The approach taking with pattern match on message to extract arguments to run shell scripts. In order to prevent problems it is recommended that your scripts are either read-only, idempotent or use the Jenkins Hubot plugin to run a well defined workflow. Generally forking a shell script would be too slow for a high performance NodeJS app and the schell scripts can run commands that are themselves slow. In practice chat messaging is an asynchronous interaction and NodeJS is just queuing work to run and a hubot per scrum team is likely to be responsive enough for real world CI/CD. 

### Features

- [x] `oc status`
- [x] `oc version`
- [x] check local s2i image tags against upstream latest tag
- [x] promote images between projects using `oc tag`
- [ ] report activity such as builds and promotions in a way that isn't spammy

### Setup On OpenShift Online

This hubot runs the oc command in bash. You probably want the bot to have read-only access to your projects:

 1. Create a new openshift.com free account and add it as a collaborator to your main account and grant it only "view" access to the projects that run your actual code. 
 1. `cp .env.example .env` then edit `.evn` with your real settings. That filename is in the `.gitignore` so that you wont accidently commit it. We use `git-secret.io` to gpg encrypt that file into a `.env.secret`. If you fork this repo delete that file and also the `.gitsecret` folder as those are our settings that you wont be using. 
 1. Import the latest Node.js 8 LTS builder image `oc import-image nodejs-8-rhel7:latest --from="registry.access.redhat.com/rhscl/nodejs-8-rhel7:latest" --confirm`
 1. Create a secret from your settings with `NAME=openshiftbot ./create-env-secret.sh .env`
 1. Create the hubot with `NAME=openshiftbot ./create-openshift.sh`
 
If you promote application containers between projects using `oc tag` and want to use the `./bin/promote.sh` to do this from commands in slack such as `@Openshiftbot promote webapp` then you need to give the hubot account the ability to create and update tags to the projects named as `PROMOTE_PROJECT_FROM` and `PROMOTE_PROJECT_TO` in your `.env` file: 

```oc project $PROMOTE_PROJECT_FROM
oc policy add-role-to-user registry-editor your-hubot-username
oc project $PROMOTE_PROJECT_TO
oc policy add-role-to-user registry-editor your-hubot-username
```

### Running openshiftbot Locally

You need a slack app oAuth token then you can start openshiftbot locally by running:

    % HUBOT_SLACK_TOKEN=xxx KUBECONFIG=~/.kube/config ./bin/hubot --adapter slack

See below for how to connect to other chat solutions such as Campfile or IRC. 

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    openshiftbot>

Then you can interact with openshiftbot by typing `openshiftbot help`.

    openshiftbot> openshiftbot help
    openshiftbot help - Displays all of the help commands that openshiftbot knows about.
    ...

##  Persistence

If you are going to use the `hubot-redis-brain` package (strongly suggested),
you will need to add the Redis to OpenShift and manually
set the `REDISTOGO_URL` variable to be the Redis service *.svc internal DNS name..

    % oc env dc openshiftbot REDISTOGO_URL="..."

If you don't need any persistence feel free to remove the `hubot-redis-brain`
from `external-scripts.json` and you don't need to worry about redis at all.

[redistogo]: https://redistogo.com/

## Adapters

Adapters are the interface to the service you want your hubot to run on, such
as Slack, Campfire or IRC. There are a number of third party adapters that the
community have contributed. Check [Hubot Adapters][hubot-adapters] for the
available ones.

If you would like to run a non-Slack or shell adapter you will need to add
the adapter package as a dependency to the `package.json` file in the
`dependencies` section.

Once you've added the dependency with `npm install --save` to install it you
can then run hubot with the adapter.

    % bin/hubot -a <adapter>

Where `<adapter>` is the name of your adapter without the `hubot-` prefix.

[hubot-adapters]: https://github.com/github/hubot/blob/master/docs/adapters.md

# Secrets

 1. `openshift.secrets.pub.key` is the public keys to encrypt secrets. 
 2. `openshift.secrets.key.secret` is the git-secret encoded version private key used to decrypt secrets.
 3. `openshift.secrets.key.gpg` is the private key symmetrically encrypted private key using `OPENSHIFT_SECRET`. 

The net effect is that you have to create a deployment with an env var `OPENSHIFT_SECRET` then gpg decrypt `openshift.secrets.key.gpg`. 

