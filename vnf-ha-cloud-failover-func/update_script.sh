ip_address="$1"
  
echo "Updating tgactive script ..."

if ! grep -q $ip_address "/config/failover/tgactive"; then
  echo curl http://$ip_address:3000/ >> /config/failover/tgactive
fi

echo "Updated tgactive with url http://$ip_address:3000/"
