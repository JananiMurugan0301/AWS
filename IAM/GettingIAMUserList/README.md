**Goal**
- To get the list of all IAM users, along with poicies, group and last access date in the csv file

**aws shell command used**
1. list-users -> to get list of all users
2. list-user-policies -> to get list of inline policies created for the users
3. list-attached-user-policies -> to get list of policies attached to the users
4. list-groups-for-user -> to get list of groups user has been part of
5. generate-service-last-accessed-details -> to generate the job id for the user with their arn
6. get-service-last-accessed-details -> to get the list of services user has been accessed so far with the job id created with previous command
7. --query -> to get the related fields from the above commands

**Steps followed**
- creating **IAM_User_list.csv** file with headers
- getting all the username using **list-users** command and storing into iam_user_list after removing all the extra characters like '['
- creating array with iam_user_list
- looping through each item in the iam_user_list
- removing '\n' from the item
- if the item is '' then continuing the loop
- getting the name of the inline policy created for the user using the command **list-user-policies** with item as the parameter for **--user-name**
- same for attached_policy and groups using the command **list-attached-user-policies** and **list-groups-for-user** respectively
- to get the last_accessed_date, creating the job id for the user using the command **generate-service-last-accessed-details** by passing user_arn as a paramter to **--arn**
- sleep command for 10 seconds to complete the job id creation
- by passing the generated job id as a input to the command **get-service-last-accessed-details** and the parameter **--job-id** getting the **LastAuthenticated** date field for all the services the user has been accessed
- after removing all the extra characters and by sorting in reverse order and using the command **head -1**, picking the **LastAuthenticated** date which is the last date the user has been accessed any of the aws services
- writing all the details into the file **IAM_User_list.csv**


