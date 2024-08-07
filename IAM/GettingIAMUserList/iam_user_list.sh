#!/usr/bin/env bash

#creating headers in the iam_user_list file
echo "user_name|Inline_Policy|Attached_Policy|Group_Name|last_accessed_date" > IAM_User_list.csv

#getting all iam usernames into the array
iam_user_list="$(aws iam list-users --query 'Users[*].UserName' | tr -d '[''"'','' '''']')" # deleting extra charcters
mapfile iam_user_arr <<< "$iam_user_list" #string to array

#looping through each user in the array
for item in "${iam_user_arr[@]}"; do
    user=${item::-1} #removing \n
    if [[ "$user" == '' ]] then continue; fi

    #getting all the inline policies created for the users
    list_user_policy="$(aws iam list-user-policies --user-name "$user" --query 'PolicyNames[*]' | tr -d '[''"'' ''\n'']')"

    #getting all the policies attached to the users
    list_attached_user_policy="$(aws iam list-attached-user-policies --user-name "$user" --query 'AttachedPolicies[*].PolicyName' | tr -d '[''"'' ''\n'']')"
    
    #getting the group name the user has been part of
    user_group="$(aws iam list-groups-for-user --user-name "$user" --query 'Groups[*].GroupName' | tr -d '[''"'' ''\n'']')"

    #setting default value for empty string
    if [[ "$list_user_policy" == '' ]] then list_user_policy="NA"; fi
    if [[ "$list_attached_user_policy" == '' ]] then list_attached_user_policy="NA"; fi
    if [[ "$user_group" == '' ]] then user_group="NA"; fi

    #getting last_accessed_date with any services for the user
    user_arn=arn:aws:iam::858610611550:user/"$user"
    user_job_id="$(aws iam generate-service-last-accessed-details --arn "$user_arn" | tr -d '"''{''}'':''\n'' ' |cut -c 6-)"
    sleep 10 #waiting for 10 sec for job_id creation
    last_accessed_date="$(aws iam get-service-last-accessed-details --job-id "$user_job_id" --query 'ServicesLastAccessed[*].LastAuthenticated'  | tr -d '[''"'','' '''']' | sort -rn | head -1)"

    if [[ "$last_accessed_date" == '' ]] then last_accessed_date="NA"; fi

    #writing into the file
    echo "$user|$list_user_policy|$list_attached_user_policy|$user_group|$last_accessed_date" >> IAM_User_list.csv
done
