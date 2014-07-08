template "#{node['deploy-project']['path']}/app/Config/core.php" do
  source 'php-cake-core.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/app/Config/database.php" do
  source 'php-cake-database.php.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/.htaccess" do
  source 'php-cake-htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

template "#{node['deploy-project']['path']}/app/webroot/.htaccess" do
  source 'php-cake-webroot-htaccess.erb'
  owner node['apache']['user']
  group node['apache']['group']
end

['/etc/php5/apache2/conf.d/20-timezone.ini',
 '/etc/php5/cli/conf.d/20-timezone.ini'].each do |fn|
  directory ::File.dirname(fn) do
    recursive true
  end
  file fn do
    content "date.timezone = #{node['cake']['timezone']}"
    notifies :restart, 'service[apache2]', :delayed
    not_if { node['cake']['timezone'].nil? }
  end
end

["#{node['deploy-project']['path']}/app/tmp/cache/persistent",
 "#{node['deploy-project']['path']}/app/tmp/cache/models",
 "#{node['deploy-project']['path']}/app/tmp/cache/views"
].each do |path|
  directory path do
    action :delete
    recursive true
  end
  
  directory path do
    owner node['apache']['user']
    group node['apache']['group']
  end
end


execute 'echo "n\ny\n" | app/Console/cake schema create' do
  cwd node['deploy-project']['path']
  action :nothing
  subscribes :run, 'execute[end configure]'
end