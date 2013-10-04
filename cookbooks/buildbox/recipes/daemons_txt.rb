file "daemons.txt" do
  path "/opt/zenoss/etc/daemons.txt"
  owner "zenoss"
  group "zenoss"
  mode 0644
  content <<eof
zeneventserver
zopectl
zenhub
zenjobs
zeneventd
zenactiond
eof
end

file "DAEMONS_TXT_ONLY" do
  path "/opt/zenoss/etc/DAEMONS_TXT_ONLY"
end