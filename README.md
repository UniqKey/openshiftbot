# Openshiftboy the friendly openshift hubot

Openshiftbot is a hubot focusing on monitoring activity and container patch levels within your openshift projects. It enables chatops culture where openshift events are displayed in chat channels where you work (e.g. Slack). Rather than slacking a question ”is the feature deployed” look at what openshiftbot has said else ask it a question. 

Currently the focus is getting something immediately useful for our deployments. You can always fork and customised to your purposes. We would consider refactoring it to be a plug-in if there is interest. 

Having the bot perform arbitrary writes seems a bit high risk. There is a hubot Jenkins Steps plugin that would seem a good idea for that doing Jenkins based promotions. This bot is intended to run with read-only access and tell you the appropriate commands to run if it thinks you should be patching your container images to match the lastest up stream LTS releases. 

### Features

- [x]  `oc status`
- [x] `oc version`
- [ ] cron check that `oc version` has matching client and server versions
- [ ] check local build tags against upstream latest tags
- [ ] poll `oc get events`, deduplicate and tell the room

### Setup On OpenShift Online

This hubot runs the oc command. That reads the kubeconfig file created by `oc login`. The openshift template mounts a secret called `kubconfig` into the deployment. To create that secret you need to perform an `oc login` and load the generated kubconfig file into an openshift secret using the provide secret. 

You probably want the bot to have read-only access to your projects. Jenkins hubots can do turnover approvals to release software and that's probably a safer route that having people run custom oc write commands from slack:

 1. Create a new openshift.com free account
 1. Add it as a collaborator to your main account and grant it only "view" access to your project 
 1. Backup your `~/.kube/config` and generate a new one by logging into openshift as the new read-only user. 
 1. Copy the newly generated kubconfig as `kubconfig` in the local director. That file name is in the .gitignore so that you won't accidently commit it. (We use `git secret` to encrypt it). 
 1. To be continued...
 

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
