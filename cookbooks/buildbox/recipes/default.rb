$zen_download="https://s3.amazonaws.com/wkh-zen-rpms"
$tmp_dir="#{Chef::Config[:file_cache_path]}"


# RPMForge
remote_file "#{$tmp_dir}/RPM-GPG-KEY.dag.txt" do
    source  "http://apt.sw.be/RPM-GPG-KEY.dag.txt"
    action  :create_if_missing
end
execute "import RPM-GPG-KEY.dag.txt" do
    command "rpm --import #{$tmp_dir}/RPM-GPG-KEY.dag.txt"
end
remote_file "#{$tmp_dir}/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm" do
    source  "http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"
    action  :create_if_missing
end
rpm_package "#{$tmp_dir}/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"


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


# Mysql
%w[MySQL-client-5.5.31-2.el6.x86_64.rpm
   MySQL-devel-5.5.31-2.el6.x86_64.rpm].each do |rpm|
    remote_file rpm do
        action :create_if_missing
        source "#{$zen_download}/#{rpm}"
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


# RRD
$rrd_rpms = %w[ rrdtool-1.4.7-1.el6.rfx.x86_64.rpm
                perl-rrdtool-1.4.7-1.el6.rfx.x86_64.rpm
                rrdtool-devel-1.4.7-1.el6.rfx.x86_64.rpm
                perl-Time-HiRes-1.9724-1.el6.rfx.x86_64.rpm ]
$rrd_rpms.each do |rpm|
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
link "/usr/local/bin/mvn" do
    to "/usr/local/share/apache-maven-3.0.5/bin/mvn"
end


# Zenoss
user "zenoss" do
    action :create
end
directory "/opt/zenoss" do
    owner "zenoss"
    group "zenoss"
    mode 0755
end


