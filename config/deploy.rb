set :user, 'ah1337'  # Your dreamhost account's username
set :domain, 'castiglia.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, 'newstrex'  # Your application as its called in the repository
set :application, 'newstrex.dreamhosters.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/#{application}"  # The standard Dreamhost setup

default_run_options[:pty] = true
set :repository,  "git@github.com:gmalicki/newstrex.git" #GitHub clone URL
set :scm, "git"
#set :scm_passphrase, "" #This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true


# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :copy

# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false
