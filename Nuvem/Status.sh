#!/bin/bash
az vm list -d --query '[].{Name:name,PowerState:powerState}' -o tsv
exit 0

