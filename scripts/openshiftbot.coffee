
module.exports = (robot) ->

     robot.respond /oc status -n (.*)/i, (msg) ->
       project = msg.match[1]
       @exec = require('child_process').exec
       command = "./oc status -n "+project

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! not able to fetch OpenShift cluster status, Please check help `!oc help` " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc status..." +"```" + stdout + "```"

     robot.respond /oc version/i, (msg) ->
       @exec = require('child_process').exec
       command = "./oc version"

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! not able to fetch OpenShift cluster version, Please check help `!oc help` " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc version..." +"```" + stdout + "```"

     robot.respond /oc get events/i, (msg) ->
       @exec = require('child_process').exec
       command = "./oc get events"

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! I am not able to fetch OpenShift events! " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! The oc get events..." +"```" + stdout + "```"

     robot.respond /do we have the latest nodejs-8-rhel7 tags\?/i, (msg) ->
       @exec = require('child_process').exec
       command = "./bin/nodejs-8-rhel7.sh"

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
