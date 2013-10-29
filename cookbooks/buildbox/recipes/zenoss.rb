# Zenoss
$bashrc = <<EOF
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
export ZENHOME="/opt/zenoss"
export INSTANCE_HOME="/opt/zenoss"
export PATH="${ZENHOME}/bin:${PATH}"
export PYTHONPATH="/opt/zenoss/lib/python"

if [ "${USE_ZENDS}" = "1" ];then
  export LD_LIBRARY_PATH="${ZENDSHOME}/lib:${ZENHOME}/lib"
  export PATH="${ZENDSHOME}/bin:${PATH}"
else
  export LD_LIBRARY_PATH="${ZENHOME}/lib"
fi

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION="cpp"
EOF
$m2_settings = <<EOF
<settings>
    <mirrors>
        <mirror>
            <id>europa</id>
            <mirrorOf>*</mirrorOf>
            <url>http://nexus.zendev.org:8081/nexus/content/groups/public</url>
        </mirror>
    </mirrors>
</settings>
EOF
user "zenoss" do
  action :create
end
file "/home/zenoss/.bashrc" do
  owner "zenoss"
  group "zenoss"
  mode 0644
  content $bashrc
end
file "/etc/sudoers.d/zenoss" do
  content "zenoss ALL=(ALL) ALL"
end
directory "/opt/zenoss" do
  owner "zenoss"
  group "zenoss"
  mode 0755
end
directory "/home/zenoss/.m2" do
  owner "zenoss"
  group "zenoss"
end
file "/home/zenoss/.m2/settings.xml" do
  content $m2_settings
  owner "zenoss"
  group "zenoss"
end
