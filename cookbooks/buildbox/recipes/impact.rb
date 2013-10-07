# Chef script for Impact development

$profile_d_file = <<EOF
#!/bin/bash
user=`/usr/bin/id -un`
case "$user" in
    zenoss|zenossimpact)
        export IMPACT_HOME=/opt/zenoss_impact
        export PATH=$PATH:$IMPACT_HOME/bin
        ;;
    *)
        # Don't litter other users with Impact hooks
        ;;
esac
EOF

user "zenossimpact" do
  action :create
end
group "zenoss" do
  action :modify
  members ["zenossimpact"]
end
directory "/opt/zenoss_impact" do
  owner "zenoss"
  group "zenoss"
  mode 0755
end
file "/etc/profile.d/zenossimpact.sh" do
  content $profile_d_file
end
file "/etc/sudoers.d/zenossimpact" do
  content "zenossimpact ALL=(ALL) ALL"
end
