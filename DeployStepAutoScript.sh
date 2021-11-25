# Deploy Step Auto Script
echo "Deploy Step Auto Script (DSAS) starts now!"

echo "D.S.A.S. >> Step 1: VPN"
echo -e "\t >> Make sure you are connected to CSLab VPN"
read -t 2
echo " "

echo "D.S.A.S. >> Step 2: Git Operation"
echo -e "\t >> You need to do it yourself either by git command or other tools like fork"
echo -e "\t >> First, pull down the latest version of <deploy-branch>"
echo -e "\t >> Then, make sure your local files are in <deploy-branch>"
read -p "D.S.A.S. >> Press any key once you finished the above steps: " cont
echo " "

echo "D.S.A.S. >> Step 3: Change Directory"
echo -e "\t >> You need to switch to your project directory on your PC"
echo -e "\t >> Currently your are at $(pwd)"
echo -e "\t >> Enter [skip] if you already there, otherwise, input your directory:"
dirc="skip"
read -p "D.S.A.S. >> " dirc
if [ "$dirc"x == "skip"x ]; 
then
    echo -e "\t >> COOL!"
else
    cd $dirc
    echo -e "\t >> Your have switch to $(pwd)"
fi
echo " "

echo "D.S.A.S. >> Step 4: SSH key"
ssh-add
echo " "

echo "D.S.A.S. >> Step 5: CAP deploy"
cap production deploy
echo " "

echo "D.S.A.S. >> Step 6: Website restart"
bundle exec cap production puma:restart
echo " "

echo "D.S.A.S. >> Deploy Steps Finished Now!"
echo -e "\t >> If you didn't see any error occur, then go to our website and have a look!"
echo " "

echo "D.S.A.S. >> Thank you for using our Deploy Step Auto Script (D.S.A.S.)!"
