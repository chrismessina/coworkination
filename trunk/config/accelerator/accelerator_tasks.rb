Capistrano::Configuration.instance(:must_exist).load do
  namespace :accelerator do
    
    namespace :smf do
      desc "Adds a SMF for the application (mongrel)"
      task :create, :roles => :app do
        puts "set variables"
        service_name = application
        working_directory = current_path
      
        template = File.read("config/accelerator/smf_template.erb")
        buffer = ERB.new(template).result(binding)
      
        put buffer, "#{shared_path}/#{application}-smf.xml"
      
        sudo "svccfg import #{shared_path}/#{application}-smf.xml"
      end
      
      desc "Stops the application (mongrel)"
      task :stop, :roles => :app do
        sudo "svcadm disable /network/mongrel/#{application}-production"
      end

      desc "Stops the application (mongrel)"
      task :start, :roles => :app do
        sudo "svcadm enable -r /network/mongrel/#{application}-production"
      end

      desc "Restarts the application (mongrel)"
      task :restart do
        smf.stop
        smf.start
      end

      desc "Deletes the SMF configuration"
      task :delete, :roles => :app do
        sudo "svccfg delete /network/mongrel/#{application}-production"
      end
    end# of smf
    
    namespace :apache do
      desc "Creates an Apache 2.2 compatible virtual host configuration file"
      task :create_vhost, :roles => :web do
        public_ip = ""
        run "ifconfig -a | ggrep -A1 e1000g0 | grep inet | awk '{print $2}'" do |ch, st, data|
          public_ip = data.gsub(/[\r\n]/, "")
        end

        cluster_info = YAML.load(File.read('config/mongrel_cluster.yml'))

        start_port = cluster_info['port'].to_i
        end_port = start_port + cluster_info['servers'].to_i - 1
        public_path = "#{current_path}/public"
      
        template = File.read("config/accelerator/apache_vhost.erb")
        buffer = ERB.new(template).result(binding)
      
        put buffer, "#{shared_path}/#{application}-apache-vhost.conf"
        sudo "cp #{shared_path}/#{application}-apache-vhost.conf /opt/csw/apache2/etc/virtualhosts/#{application}.conf"
      
        apache.restart
      end
    
      desc "Restart apache"
      task :restart, :roles => :web do
        apache.stop
        apache.start
      end
      
      task :stop, :roles => :web do
        sudo "svcadm disable svc:/network/http:cswapache2"
      end
      
      task :start, :roles => :web do
        sudo "svcadm enable svc:/network/http:cswapache2"
      end
    end
    
    desc "Shows all Services"
    task :svcs, :roles => :app do
      run "svcs -a" do |ch, st, data|
        puts data
      end
    end
    
    desc "After setup, creates Solaris SMF config file and adds Apache vhost"
    task :setup_smf_and_vhost do
      smf.create
      apache.create_vhost
    end
    
  end
  
  after 'deploy:setup', 'accelerator:setup_smf_and_vhost'
  
  desc "Restarts mongrel using SMF"
  deploy.task :restart do
    accelerator.smf.restart
  end

  desc "Starts mongrel using SMF"
  deploy.task :start do
    accelerator.smf.start
  end

  desc "Stops mongrel using SMF"
  deploy.task :stop do
    accelerator.smf.stop
  end
  
end