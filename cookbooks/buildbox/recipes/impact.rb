# Chef script for Impact development

$profile_d_file = <<EOF
#!/bin/bash
user=`/usr/bin/id -un`
case "$user" in
    zenoss)
        export IMPACT_HOME=/opt/zenoss_impact
        export PATH=$PATH:$IMPACT_HOME/bin
        ;;
    *)
        # Don't litter other users with Impact hooks
        ;;
esac
EOF

directory "/opt/zenoss_impact" do
  owner "zenoss"
  group "zenoss"
  mode 0755
end

file "/etc/profile.d/zenossimpact.sh" do
  content $profile_d_file
end


# Java
$zen_download="http://vagrant.zendev.org/deps"
$java_name="jdk-7u45-linux-x64.rpm"
remote_file "#{$tmp_dir}/#{$java_name}" do
  source  "#{$zen_download}/#{$java_name}"
  action  :create_if_missing
end
execute "Install JDK 7.0" do
    command "rpm -ivh --excludepath /etc/init.d/jexec #{$tmp_dir}/#{$java_name}"
    not_if {::File.exists?("/usr/java/jdk1.7.0_45")}
end
link "/usr/java/default" do
  to "/usr/java/jdk1.6.0_43"
end
link "/usr/java/zenoss_impact" do
  to "/usr/java/latest"
end
file "/etc/default/zenoss_impact" do
  content "JAVA_HOME=/usr/java/zenoss_impact"
end



