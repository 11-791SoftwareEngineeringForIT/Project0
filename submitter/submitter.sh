#!/bin/bash

################################################################################
# Set up all of the global variables required for your submitter here
# `configuration` will be the first function called by the submitter
################################################################################
configuration() {

    # These fields do not need to be changed
    ags_dns="autograding.theproject.zone"
    signature="1K9SaGliHwthRgeOi12hUdCUwAPmN"

    # Default values can be changed as needed
    codeId="code"
    feedbackId="feedback"
    useContainer="true"
    taskLimit=0
    update="false"
    pending="false"
    duration=300
    language="java"

    # Module / task specific fields
    # Task Id and TPZ key from https://theproject.zone/f18-11791/pi0/tasks/hello-world
    semester="f18"                              # part of TPZ project URL  e.g. "f18-11791"
    courseId="11791"                            # part of TPZ project URL  e.g. "f18-11791"
    projectId="pi0"                             # created at "Create New Project" time in TPZ
                                                # "Create Project" pop-up: "Project identifier" field
    taskId="hello-world"                        # the same as "Slug" in the Edit Task pop-up
                                                # created at "Create New Task" pop-up "Module slug" field
    tpz_key="KMZL8VGavxwtkXp1DrsjLEKXfoOBuhGJ"  # "Secret key" in the Edit Task pop-up
}

################################################################################
# Useful variables if the submitter is running in an EC2 context
################################################################################
load_dns_info() {
    awsId="$(/usr/bin/curl -s http://169.254.169.254/latest/dynamic/instance-identity/document  | grep accountId | /usr/bin/cut -d'"' -f4)"
    amiId="$(/usr/bin/ec2metadata --ami-id)"
    instanceId="$(/usr/bin/ec2metadata --instance-id)"
    instanceType="$(/usr/bin/ec2metadata --instance-type)"
    publicHostname="$(/usr/bin/ec2metadata --public-hostname)"
    studentDNS="$publicHostname"
}

################################################################################
# `submit_to_tpz_ags` creates a .tar.gz of the current working directory
# and POSTs it to AGS for grading
################################################################################
submit_to_tpz_ags() {
    echo "Uploading answers, files larger than 5M will be ignored..."
    # exclude jars in lib folder
    find . -not -path "./lib/*" -size -5M -type f | tar -cvzf "$andrewId".tar.gz -T - &> /dev/null
    postUrl="https://$ags_dns/ags/submission/submit?signature=$signature&andrewId=$andrewId&password=$password&dns=$studentDNS&semester=$semester&courseId=$courseId&projectId=$projectId&taskId=$taskId&lan=$language&tpzKey=$tpz_key&feedbackId=$feedbackId&codeId=$codeId&useContainer=$useContainer&taskLimit=$taskLimit&update=$update&pending=$pending&duration=$duration&checkResult=$checkResult"
    submitFile="$andrewId.tar.gz"

    if ! curl -s -F file=@"$submitFile" "$postUrl"
        then
        echo "Submission failed, please check your password or try again later."
        exit
    else
        # the code can also reaches here with submission failure due to a existing pending submission
        echo "If your submission is uploaded successfully, log in to theproject.zone and open the submissions table at"
        echo "https://theproject.zone/"$semester"-"$courseId"/"$projectId"/submissions"
        echo " to see how you did!"
    fi

    rm -rf "$andrewId".tar.gz
}

################################################################################
# Fill in the `grade` function with the operations required for grading
################################################################################
grade() {
    echo "TODO!"

    # return ??? if ???
    return TRUE;
}

################################################################################
# BEGINNING OF SUBMITTER
################################################################################

# Sets up variables for this specific task
configuration

# Load various DNS / AWS properties
#
# load_dns_info

while getopts ":ha:" opt; do
  case $opt in
    h)
      echo "This program is used to submit and grade your solutions. Usage:" >&2
      echo "export HISTIGNORE=\"export*\" # so that the following export commands will not be tracked into bash history" >&2
      echo "export TPZ_USERNAME=\"your_gmail_address\"" >&2
      echo "export TPZ_PASSWORD=\"tpz_submission_pwd\"" >&2
      echo "./submitter" >&2
      exit
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
    ;;
  esac
done


# This submitter requires TPZ_USERNAME and TPZ_PASSWORD to be set in the environment
#    before students can run ./submitter.sh to make a submission
#
# is gmail required, or are andrew emails OK?
if [[ -z "${TPZ_USERNAME}" ]]; then
  echo "Please set TPZ_USERNAME as your gmail address first with the command:"
  echo "export TPZ_USERNAME=\"value\""
  exit 1
else
  andrewId="${TPZ_USERNAME}"
fi

if [[ -z "${TPZ_PASSWORD}" ]]; then
  echo "Please set TPZ_PASSWORD as your submission password from TheProject.zone with the command:"
  echo "export TPZ_PASSWORD=\"value\""
  exit 1
else
  password="${TPZ_PASSWORD}"
fi

echo "####################"
echo "# INTEGRITY PLEDGE #"
echo "####################"
echo "Have you cited all the reference sources (both people and websites) in the file named 'references'? (Type \"I AGREE\" to continue). By typing \"I AGREE\", you agree that you have not cheated in any way when completing this project. Cheating can lead to severe consequences."
read -r references

if [ "$(echo "$references" | awk '{print tolower($0)}')" == "i agree" ]
then
    grade 2>/dev/null

    submit_to_tpz_ags

else
    echo "Please cite all the detailed references in the file 'references' and submit again. Type \"I AGREE\" when you submit next time."
    exit
fi
