remote_file "/tmp/RPM-GPG-KEY.dag.txt" do
    source  "http://apt.sw.be/RPM-GPG-KEY.dag.txt"
    action  :create_if_missing
end

execute "import RPM-GPG-KEY.dag.txt" do
    command "rpm --import /tmp/RPM-GPG-KEY.dag.txt"
    action  :run
end

remote_file "/tmp/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm" do
    source  "http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"
    action  :create_if_missing
end

rpm_package "/tmp/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"

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

remote_file "/tmp/MySQL-client-5.5.31-2.el6.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/MySQL-client-5.5.31-2.el6.x86_64.rpm"
    action  :create_if_missing
end

remote_file "/tmp/MySQL-devel-5.5.31-2.el6.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/MySQL-devel-5.5.31-2.el6.x86_64.rpm"
    action  :create_if_missing
end

remote_file "/tmp/rrdtool-1.4.7-1.el6.rfx.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/rrdtool-1.4.7-1.el6.rfx.x86_64.rpm"
    action  :create_if_missing
end

remote_file "/tmp/rrdtool-devel-1.4.7-1.el6.rfx.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/rrdtool-devel-1.4.7-1.el6.rfx.x86_64.rpm"
    action  :create_if_missing
end

remote_file "/tmp/perl-rrdtool-1.4.7-1.el6.rf.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/perl-rrdtool-1.4.7-1.el6.rfx.x86_64.rpm"
    action  :create_if_missing
end

remote_file "/tmp/perl-Time-HiRes-1.9724-1.el6.rfx.x86_64.rpm" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/perl-Time-HiRes-1.9724-1.el6.rfx.x86_64.rpm"
    action  :create_if_missing
end

rpm_package "/tmp/MySQL-client-5.5.31-2.el6.x86_64.rpm"
rpm_package "/tmp/MySQL-devel-5.5.31-2.el6.x86_64.rpm"

execute "Install rrdtool" do
    command "rpm -ivh perl-rrdtool-1.4.7-1.el6.rf.x86_64.rpm perl-Time-HiRes-1.9724-1.el6.rfx.x86_64.rpm rrdtool-1.4.7-1.el6.rfx.x86_64.rpm rrdtool-devel-1.4.7-1.el6.rfx.x86_64.rpm"
    cwd     "/tmp"
end

yum_package "lua"
yum_package "lua-devel"

%w{libmysqlclient.a libmysqlclient_r.a libmysqlservices.a}.each do |mysqllib|
    execute "create /usr/lib64 symlink for #{mysqllib}" do
        command "ln -s /usr/lib64/mysql/#{mysqllib} /usr/lib64/#{mysqllib}"
        not_if  { ::File.exists?("/usr/lib64/#{mysqllib}") }
    end
end

remote_file "/tmp/jdk-6u43-linux-x64-rpm.bin" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/jdk-6u43-linux-x64-rpm.bin"
    action  :create_if_missing
end

execute "Install JDK" do
    command "chmod a+x jdk-6u43-linux-x64-rpm.bin && ./jdk-6u43-linux-x64-rpm.bin"
    cwd     "/tmp"
    action  :run
end

remote_file "/tmp/apache-maven-3.0.5-bin.tar.gz" do
    source  "https://s3.amazonaws.com/wkh-zen-rpms/apache-maven-3.0.5-bin.tar.gz"
    action  :create_if_missing
end

execute "Install Maven" do
    command "tar zxf /tmp/apache-maven-3.0.5-bin.tar.gz"
    cwd     "/usr/local/share/"
    not_if  { ::File.exists?("/usr/local/share/apache-maven=3.0.5") }
end

execute "Install Maven" do
    command "ln -s /usr/local/share/apache-maven-3.0.5/bin/mvn /usr/local/bin/mvn"
    not_if  { ::File.exists?("/usr/local/bin/mvn") }
end
