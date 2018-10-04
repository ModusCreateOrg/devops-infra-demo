#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Enable for enhanced debugging
#set -vx

# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."

# shellcheck disable=SC1090
. "$DIR/common.sh"
#shellcheck disable=SC1090
. "$BASE_DIR/env.sh"

asg_name=${1:-}

if [[ -z "$asg_name" ]]; then
    echo "You must specify an Auto Scaling Group name. Existing ASGs are:"
    #shellcheck disable=SC2016
    aws autoscaling describe-auto-scaling-groups \
        --query 'AutoScalingGroups[].Instances[?contains(LifecycleState,`InService`)].InstanceId' \
        --query "AutoScalingGroups[].AutoScalingGroupName" \
        --output table
    exit 1
fi


# Count the number of instances in service
function num_in_service() {
    local inservice
    local count
    inservice=${1?You must specify a tab-separated list of instance ids for num_inservice}
    count="$(echo "$inservice" | sed -e 's/		*/ /g' | tr ' ' '\n' | wc -l)"
    echo "$count"
}

# Wait for new instances to become healthy
function num_in_service_less_than() {
    local inservice
    local target
    local count
    inservice=${1?You must specify a tab-separated list of instance ids for num_inservice}
    target=${2?You must specify a target for num_in_service_less_than}
    #shellcheck disable=SC2016
    count="$(num_in_service "$inservice")"
    if [[ "$count" -lt "$target" ]]; then
        return 0
    else
        return 1
    fi
}
function get_asg_instances() {
    local asg_name
    asg_name=${1?You must specify an asg_name}
    #shellcheck disable=SC2016
    aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-name "$asg_name" \
        --query 'AutoScalingGroups[].Instances[?contains(LifecycleState,`InService`)].InstanceId' \
        --output text
}

function finish() {
    aws autoscaling resume-processes \
        --auto-scaling-group-name "$asg_name" \
        --scaling-processes AlarmNotification ReplaceUnhealthy HealthCheck AZRebalance ScheduledActions
}

trap finish EXIT

original_asg_instances="$(get_asg_instances "$asg_name")"

count="$(num_in_service "$original_asg_instances")"
echo "$count instances running - $original_asg_instances"

asg_DesiredCapacity="$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name "$asg_name" \
    --query 'AutoScalingGroups[].DesiredCapacity' \
    --output text)"

asg_MaxSize=$(aws autoscaling describe-auto-scaling-groups \
    --query 'AutoScalingGroups[].MaxSize' \
    --output text)

asg_NewCapacity=$((asg_DesiredCapacity * 2))

echo "Current desired capacity: $asg_DesiredCapacity"
echo "Current max size: $asg_MaxSize"
echo "New capacity: $asg_NewCapacity"

aws autoscaling suspend-processes \
    --auto-scaling-group-name "$asg_name" \
    --scaling-processes AlarmNotification ReplaceUnhealthy HealthCheck AZRebalance ScheduledActions

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$asg_name" \
    --max-size "$asg_NewCapacity" \
    --desired-capacity "$asg_NewCapacity" \
    --output table

# Wait until new instances spin up
current_asg_instances="$(get_asg_instances "$asg_name")"
while num_in_service_less_than "$current_asg_instances" "$asg_NewCapacity"; do
    sleep 5
    current_asg_instances="$(get_asg_instances "$asg_name")"
done

# Terminate old instances explicitly
for instance in $original_asg_instances; do
    aws autoscaling terminate-instance-in-auto-scaling-group \
        --instance-id "$instance" \
        --should-decrement-desired-capacity \
        --output table
done

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$asg_name" \
    --max-size "$asg_MaxSize" \
    --output table


