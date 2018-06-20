###
robot.respond - requires a direct message to the robot. It is better to use this for commands. 
robot.hear - works when anyone, including a slack reminder, says something in the channel with the bot. This means that a repeating slack reminder into a channel can trigger hubot. To avoid those running accidents the actions should be readonly and the text matched should be quite specific.
###
module.exports = (robot) ->

     robot.respond /oc status -n (.*)/i, (msg) ->
       project = msg.match[1]
       @exec = require('child_process').exec
       command = "bin/oc.sh status -n "+project

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! not able to fetch OpenShift cluster status, Please check help `!oc help` " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc status..." +"```" + stdout + "```"

     robot.respond /oc version/i, (msg) ->
       @exec = require('child_process').exec
       command = "bin/oc.sh version"

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! not able to fetch OpenShift cluster version, Please check help `!oc help` " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc version..." +"```" + stdout + "```"

     robot.respond /oc get events (.*)/i, (msg) ->
       @exec = require('child_process').exec
       command = "bin/oc.sh get events "+msg.match[1] 

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! I am not able to fetch OpenShift events! " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc get events..." +"```" + stdout + "```"

     robot.hear /do we have the latest (.*) (tags|images)\?/i, (msg) ->
       image = msg.match[1]
       @exec = require('child_process').exec
       command = "./bin/"+image+".sh"

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! Not able to run "+ command +" ```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " +"```" + stdout + "```"

      robot.respond /promote (.*)/i, (msg) ->
       image = msg.match[1]
       @exec = require('child_process').exec
       command = "./bin/promote.sh "+image
       
       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! Not able to run "+ command +" ```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " +"```" + stdout + "```"

      robot.hear /list tags (.*) ([^ ]*)/i, (msg) ->
        app = msg.match[1]
        project = msg.match[2]
        @exec = require('child_process').exec
        command = "./bin/list-tags.sh "+app+" "+project

        @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
          if error
              msg.send "@#{msg.message.user.name} " + "Ops! Not able to run "+ command +" ```" + stderr + "```"
          else
              msg.send "@#{msg.message.user.name} " +"```" + stdout + "```"