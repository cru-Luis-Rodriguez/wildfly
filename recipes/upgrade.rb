#upgrade wildfly

version = node'wildfly']['version']

execute 'remove_wildfly' do
          notifies :stop, "service[wildfly]", :immediately
          command 'mv /opt/wildfly /opt/old_version'
          command 'rm -rf /opt/wildfly-*.tar.gz'
          action :run
          not_if '/opt/wildfly/bin/standalone.sh \-\-version | grep WildFly #{version}'
        end
                
remote_file '/opt/wildfly-' + node['wildfly']['version'] + '.tar.gz' do
  source 'http://download.jboss.org/wildfly/' + node['wildfly']['version'] + '/wildfly-' + node['wildfly']['version'] + '.tar.gz'
  mode 0744
  owner node['wildfly']['user']
  group node['wildfly']['group']
  not_if { File.exists?('/opt/wildfly-' + node['wildfly']['version'] + '.tar.gz')}
end

execute 'unpack-wildfly' do
  cwd "/opt"
  command "tar -zxf wildfly-" + node['wildfly']['version'] + ".tar.gz"
  action :run
  not_if { File.exists?('/opt/wildfly') }
end

execute 'chown-wildfly' do
  cwd '/opt'
  command 'chown -R wildfly:wildfly /opt/wildfly-' + node['wildfly']['version']
  not_if { File.exists?('/opt/wildfly') }
end

execute 'rename-directory-remove-version' do
  command 'mv /opt/wildfly-' + node['wildfly']['version'] + ' /opt/wildfly'
  not_if { File.exists?('/opt/wildfly') }
end
