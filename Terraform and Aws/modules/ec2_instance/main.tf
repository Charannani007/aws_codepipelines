provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-05fcfb9614772f051"
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_codepipeline_profile.name

  user_data = <<-EOF
    #!/bin/bash
    # Install required tools
    yum update -y
    yum install -y curl jq aws-cli

    # Create the trigger script
    cat << 'SCRIPT' > /home/ec2-user/check_project_and_trigger.sh
    #!/bin/bash
    # Hardcoded values
    SESSION_ID="unVWnc8CtAudF32u6K-XeOJ77jQTLaSYcsLaAUgSApVD3qoM82yvD98EmDTZO30okH5WgWJ7VOYBeraoVqS1"
    AWS_PIPELINE_NAME="Codepipeline-feature"

    # Odoo API request with retry
    for attempt in {1..3}; do
      response=$(curl -s --location "https://dataskate1.odoo.com/web/dataset/call_kw/project.project/search_read" \
        --header "Content-Type: application/json" \
        --header "Cookie: session_id=$SESSION_ID" \
        --data '{
          "jsonrpc": "2.0",
          "params": {
            "model": "project.project",
            "method": "search_read",
            "args": [[]],
            "kwargs": {
              "fields": ["id", "name", "stage_id"],
              "limit": 1000
            }
          }
        }')
      if [[ -n "$response" && "$response" != *"error"* ]]; then
        break
      fi
      echo "$(date): Odoo API request failed (attempt $attempt)" >> /home/ec2-user/trigger.log
      sleep 10
    done

    if [[ -z "$response" || "$response" == *"error"* ]]; then
      echo "$(date): Failed to get valid Odoo response after 3 attempts" >> /home/ec2-user/trigger.log
      exit 1
    fi

    project_stage=$(echo "$response" | jq -r --arg name "Task-Tracker" '
      .result[] | select(.name == $name) | .stage_id[1]')

    echo "$(date): Project 'Task-Tracker' stage: $project_stage" >> /home/ec2-user/trigger.log

    if [[ "$project_stage" == "Completed" ]]; then
      echo "$(date): Triggering AWS pipeline: $AWS_PIPELINE_NAME" >> /home/ec2-user/trigger.log
      aws codepipeline start-pipeline-execution --name "$AWS_PIPELINE_NAME" >> /home/ec2-user/trigger.log 2>&1
      if [[ $? -eq 0 ]]; then
        echo "$(date): Pipeline triggered successfully" >> /home/ec2-user/trigger.log
      else
        echo "$(date): Failed to trigger pipeline" >> /home/ec2-user/trigger.log
      fi
    else
      echo "$(date): No trigger. Stage is not Completed." >> /home/ec2-user/trigger.log
    fi
    SCRIPT

    # Set permissions
    chown ec2-user:ec2-user /home/ec2-user/check_project_and_trigger.sh
    chmod +x /home/ec2-user/check_project_and_trigger.sh

    sudo yum install -y cronie
    # # Set up cron job
    echo "*/2 * * * * /home/ec2-user/check_project_and_trigger.sh >> /home/ec2-user/trigger.log 2>&1" | crontab -u ec2-user -

    # Ensure cron is running
    systemctl enable crond
    systemctl start crond
EOF

  tags = {
    Name = "ci/cd project"
  }
}