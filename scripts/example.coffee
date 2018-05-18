
module.exports = (robot) ->

     robot.respond /oc status/i, (msg) ->
       @exec = require('child_process').exec
       command = "./oc status"

       @exec command, { shell: '/bin/bash' } , (error, stdout, stderr) ->
         if error
            msg.send "@#{msg.message.user.name} " + "Ops! not able to fetch OpenShift cluster status, Please check help `!oc help` " +"```" + stderr + "```"
         else
            msg.send "@#{msg.message.user.name} " + "Here you go! the status of OpenShift Cluster." +"```" + stdout + "```"