#!/bin/bash
# March 11, 2021 - Frank Lamprea
# ThoughtSpot
# Keep a APICLUSTER Awake beyond 2 Hours
# This script pulls up a pinboard to keep a session alive

#Initialize
n=1
LOOPS=1
# __Main
# Loop 12 times
while (( $n <= $LOOPS ))
    
    do 
    
    #Define a few Things
    
    #Load the Creds & variables from a hidden environment file
    
    #Save a file called ".wake_api" in your home directory
    #with contents like below:
    
    #APIUSER="myuser"
    #APIPW="mypw"
    #APICLUSTER="172.10.1.20"
    #PINBOARDID="4145513c-c9bd-4e48-af44-8dc001b5f955"
    #SLEEPLOOPSECONDS=3600
    #LOOPS=12
    #EXITONERROR=yes

    #The .wake_api file can be changed while the script is running and the settings will be picked up on the next loop
    
    echo ""
    echo "*************************"
    echo "Reading settings from ~/.wake_api"
    echo "*************************"
    source ~/.wake_api

    #Make sure everything is defined
    [[ -z "$APIUSER" ]] && { echo "Error: APIUSER variable undefined, example: APIUSER=\"tsadmin\""; exit 1; }
    [[ -z "$APIPW" ]] && { echo "Error: APIPW variable undefined, example: APIPW=\"mypw\""; exit 1; }
    [[ -z "$APICLUSTER" ]] && { echo "Error: APICLUSTER variable undefined, example: APICLUSTER=\"172.10.15.30\""; exit 1; }
    [[ -z "$PINBOARDID" ]] && { echo "Error: PINBOARDID variable undefined, example: PINBOARDID=\"4145513c-c9bd-4e48-af44-8dc001b5f955\""; exit 1; }
    [[ -z "$SLEEPLOOPSECONDS" ]] && { echo "Error: SLEEPLOOPSECONDS variable undefined, example: SLEEPLOOPSECONDS=3600"; exit 1; }
    [[ -z "$LOOPS" ]] && { echo "Error: LOOPS variable undefined, example: LOOPS=12"; exit 1; }
    [[ -z "$EXITONERROR" ]] && { echo "Error: EXITONERROR variable undefined, example: EXITONERROR=\"yes\""; exit 1; }
    
    echo ""
    echo "*************************"
    echo "Keep Alive $i "; date
    echo "*************************"
    
    # Login to Cluster Function
    function login() {
        echo ""
        echo "*************************"    
        echo "Logging in... $APIUSER"
        echo "*************************"
        echo -n "HTTP Returnm Code: "
            
        curl --write-out '%{http_code}' --silent --show-error --fail -i -k -c cookies.txt -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'X-Requested-By: ThoughtSpot' -d 'username='${APIUSER}'&password='${APIPW}'&rememberme=true' 'https://'${APICLUSTER}'/callosum/v1/tspublic/v1/session/login'
    }
    
    #Fetch a Pinboard Function
    function pinboard() {
        echo ""
        echo "*************************"
        echo "Fetching Pinboard $PINBOARDID"
        echo "*************************"
        echo -n "HTTP Returnm Code: "
            
        curl --write-out '%{http_code}' --silent --show-error --fail -i -k -b cookies.txt -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'X-Requested-By: ThoughtSpot' 'https://'${APICLUSTER}'/callosum/v1/tspublic/v1/pinboarddata?id='${PINBOARDID}'&batchsize=-1&pagenumber=-1&offset=-1&formattype=COMPACT'
    }
    
    #Execute the function in order
    (
        set -e
        login
        pinboard
    )
    
    #Evaluate if the functions had an error and exit
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        echo ""
        echo "***** ERROR ***** "
        echo "Error Code: $errorCode"
        echo "***** ERROR ***** "
        
        # We exit the all script with the same error, if you don't want to
        # exit it and continue, set the variable to no
        
        EXITONERROR=$(echo "$EXITONERROR" | tr '[:upper:]' '[:lower:]')
        
        if [ "$EXITONERROR" == "yes" ] ; then
        exit $errorCode
        fi
        
    fi
    
    # Sleep for an Hour
    echo ""
    echo "*************************"
    echo "Done with Loop: $n"
    echo "*************************"
    echo "Sleeping for $SLEEPLOOPSECONDS seconds"
    echo "*************************"
    #Sleep the script
    sleep $SLEEPLOOPSECONDS
    
    
    #increment the loop counter
    n=$(( n+1 ))

    # End Loop
    done

echo ""
echo "*************************"    
echo "EXIT -- Done with all Keep Alive loops: $LOOPS"
echo "*************************"    
exit 0
