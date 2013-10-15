$zen_download="http://vagrant.zendev.org/deps/zen64bb" 
$tmp_dir="#{Chef::Config[:file_cache_path]}"


# RPMForge
$rpmforge_key="RPM-GPG-KEY.dag.txt"
remote_file "#{$tmp_dir}/#{$rpmforge_key}" do
    source  "http://apt.sw.be/#{$rpmforge_key}"
    action  :create_if_missing
end
execute "import #{$rpmforge_key}" do
    command "rpm --import #{$tmp_dir}/#{$rpmforge_key}"
end
$rpmforge_name="rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"
remote_file "#{$tmp_dir}/#{$rpmforge_name}" do
    source  "http://packages.sw.be/rpmforge-release/#{$rpmforge_name}"
    action  :create_if_missing
end
rpm_package "#{$tmp_dir}/#{$rpmforge_name}"


# EPEL (required for erlang)
$epel_name="epel-release-6-8.noarch.rpm"
remote_file "#{$tmp_dir}/#{$epel_name}" do
  source  "http://download.fedoraproject.org/pub/epel/6/i386/#{$epel_name}"
  action  :create_if_missing
end
rpm_package "#{$tmp_dir}/#{$epel_name}"


# Misc dependencies
yum_package "vim-enhanced"
yum_package "subversion"
yum_package "rpm-build"
yum_package "bc"
yum_package "gcc-c++"
yum_package "libxml2"
yum_package "libxslt-devel"
yum_package "cyrus-sasl-devel"
yum_package "openldap-devel"
yum_package "pango-devel"
yum_package "zlib-devel"
yum_package "autoconf.noarch"
yum_package "swig"
yum_package "readline-devel"
yum_package "openssl-devel"
yum_package "net-snmp-utils"
yum_package "pcre-devel"
yum_package "libdbi"
yum_package "gettext"
yum_package "xorg-x11-fonts-Type1.noarch"
yum_package "groff"
yum_package "lua"
yum_package "lua-devel"
yum_package "erlang"
execute "yum install git" do
    # Install a github compatible version of git 
    command "yum install git -y --disablerepo updates --disablerepo base --enablerepo rpmforge-extras"
    not_if {::File.exists?("/usr/bin/git")}
end

# Mysql
%w[MySQL-client-5.5.31-2.el6.x86_64.rpm
   MySQL-devel-5.5.31-2.el6.x86_64.rpm
   MySQL-shared-5.5.31-2.el6.x86_64.rpm
   MySQL-shared-compat-5.5.31-2.el6.x86_64.rpm
   MySQL-server-5.5.31-2.el6.x86_64.rpm].each do |rpm|
    remote_file rpm do
        action :create_if_missing
        source "http://vagrant.zendev.org/deps/#{rpm}"
        path "#{$tmp_dir}/#{rpm}"
    end
    rpm_package rpm do
        package_name "#{$tmp_dir}/#{rpm}"
    end
end
%w{libmysqlclient.a libmysqlclient_r.a libmysqlservices.a}.each do |mysqllib|
    link "/usr/lib64/#{mysqllib}" do
        to "/usr/lib64/mysql/#{mysqllib}"
    end
end
service "mysql" do
    action [:enable, :start]
end

# RRD
%w[ rrdtool-1.4.7-1.el6.rfx.x86_64.rpm
    perl-rrdtool-1.4.7-1.el6.rfx.x86_64.rpm
    rrdtool-devel-1.4.7-1.el6.rfx.x86_64.rpm
    perl-Time-HiRes-1.9724-1.el6.rfx.x86_64.rpm ].each do |rpm|
    remote_file rpm do
        action :create_if_missing
        source "#{$zen_download}/#{rpm}"
        path "#{$tmp_dir}/#{rpm}"
    end
    rpm_package rpm do
        package_name "#{$tmp_dir}/#{rpm}"
        # break a circular dependency between rrdtool and perl-rrdtool
        if rpm.match("rrdtool-[^d]")
            options "--nodeps"
        end
    end
end


# Java
$java_name="jdk-6u43-linux-x64-rpm.bin"
remote_file "#{$tmp_dir}/#{$java_name}" do
    source  "#{$zen_download}/#{$java_name}"
    action  :create_if_missing
end
execute "Install JDK" do
    command "chmod a+x #{$java_name} && ./#{$java_name}"
    cwd     "#{$tmp_dir}"
    not_if {::File.exists?("/usr/java/jdk1.6.0_43")}
end


# RabbitMQ
$rabbitmq_name = "rabbitmq-server-2.8.6-1.noarch.rpm"
remote_file "#{$tmp_dir}/#{$rabbitmq_name}" do
  source  "http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.6//#{$rabbitmq_name}"
  action  :create_if_missing
end
rpm_package $rabbitmq_name do
  package_name "#{$tmp_dir}/#{$rabbitmq_name}"
end
service "rabbitmq-server" do
  action [:enable, :start]
end
execute "rabbitmqctl add_user" do
    command "rabbitmqctl add_user zenoss zenoss"
    returns [0,2] # 2 => user already exists
end
execute "rabbitmqctl add_vhost" do
  command "rabbitmqctl add_vhost /zenoss"
  returns [0,2] # 2 => vhost already exists
end
execute "rabbitmqctl set_permissions" do
  command "rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'"
end


# Maven
$maven_name="apache-maven-3.0.5-bin.tar.gz"
remote_file "#{$tmp_dir}/#{$maven_name}" do
    source  "#{$zen_download}/#{$maven_name}"
    action  :create_if_missing
end
execute "Install Maven" do
    command "tar zxf #{$tmp_dir}/#{$maven_name}"
    cwd     "/usr/local/share/"
    not_if  { ::File.exists?("/usr/local/share/apache-maven-3.0.5") }
end
file "/etc/profile.d/maven.sh" do
    mode 0644
    content "export M2_HOME=/usr/local/share/apache-maven-3.0.5\n" +
            "export M2=$M2_HOME/bin\n" +
            "export PATH=$PATH:$M2\n"
end


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
service "iptables" do
    action [:disable, :stop]
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

# Timezone
file "/etc/localtime" do
  not_if {::File.ftype('/etc/localtime')=='link'}
  action :delete
end
link "/etc/localtime" do
  to "/usr/share/zoneinfo/US/Central"
end

