#!/bin/bash

azd env set AZURE_UPN $(az account show --query user.name -o tsv)

