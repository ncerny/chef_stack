if defined?(ChefSpec)
  def create_chef_automate(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_automate, :create, name)
  end

  def create_backend_cluster(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_backend, :create, name)
  end

  def join_backend_cluster(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_backend, :join, name)
  end

  def create_chef_org(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_org, :create, name)
  end

  def delete_chef_org(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_org, :delete, name)
  end

  def create_chef_user(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_user, :create, name)
  end

  def delete_chef_user(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_user, :delete, name)
  end

  def install_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :install, name)
  end

  def register_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :register, name)
  end

  def run_chef_client(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_client, :run, name)
  end

  def create_chef_file(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_file, :create, name)
  end

  def create_chef_server(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server, :create, name)
  end

  def create_chef_supermarket(name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_supermarket, :create, name)
  end

  def create_build_node(name)
    ChefSpec::Matchers::ResourceMatcher.new(:workflow_builder, :create, name)
  end
end
