date_stamp=`date`
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 #nodes"
  exit 1
fi
echo "##### Deploying cluster with $1 nodes #####"
echo "$date_stamp : Re-installing cloudmesh client"
cm reset
sudo pip uninstall cloudmesh_client
sudo pip install cloudmesh_client
cm refresh on
cm default cloud=chameleon
cm default user=sakorrap
cm info
cm key add --ssh
cm key upload
cm secgroup add my_group_1 my_rule_1 1 65535 tcp 0.0.0.0/0
cm secgroup upload
cm cluster define --count $1 --image CC-Ubuntu14.04 --flavor m1.xlarge --secgroup my_group_1
cm hadoop define pig
cm cluster avail 
cm hadoop avail 
>~/.ssh/known_hosts
stack_xyz=`cm hadoop avail|grep '> stack-'|cut -d ' ' -f 2`
echo $stack_xyz
find $HOME/.cloudmesh/stacks/$stack_xyz -name '*.done' -exec rm '{}' \;
cm hadoop sync
echo "Time taken for deploying cluster of $1 nodes :" >>benchmarking_results
{ time cm hadoop deploy; } 2>>benchmarking_results
sh replace_nameNode.sh
date_stamp=`date`
echo "sakorrap:$date_stamp completed the deployment" >>deployment.log
( time ansible-playbook -i hosts move_data.yml ) 2>>benchmarking_results
