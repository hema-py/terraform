#!/bin/bash

aws cloudwatch put-metric-alarm\
       	--alarm-name "cpu-mon"\
       	--alarm-description "Alarm when CPU exceeds 70 percent"\
       	--metric-name CPUUtilization\
       	--namespace AWS/EC2\
       	--statistic Average\
       	--period 300\
       	--threshold 70\
       	--comparison-operator GreaterThanThreshold\
      	--dimensions "Name=InstanceId,Value=i-12345678"\
       	--evaluation-periods 2\
       	--alarm-actions "arn:aws:sns:us-east-1:242451082977:hema-topic"\ 
       	--unit "Percent"\

