if defined?(ChefSpec)
  # Creation of a new repository
  def create_cobblerd_distro(distro_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :create, distro_name)
  end

  def delete_cobblerd_distro(distro_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :delete, distro_name)
  end

  def import_cobblerd_image(image_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :create, image_name)
  end

  def delete_cobblerd_image(image_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :delete, image_name)
  end

  def import_cobblerd_profile(profile_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :create, profile_name)
  end

  def delete_cobblerd_profile(profile_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :delete, profile_name)
  end

  def import_cobblerd_profile(profile_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :create, profile_name)
  end

  def delete_cobblerd_profile(profile_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_distro, :delete, profile_name)
  end

  def create_cobblerd_repo(repo_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_repo, :create, repo_name)
  end

  # Deleting an existing repository
  def delete_cobblerd_repo(repo_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_repo, :delete, repo_name)
  end

  def create_cobblerd_system(system_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_repo, :create, system_name)
  end

  # Deleting an existing repository
  def delete_cobblerd_system(system_name)
    ChefSpec::Matchers::ResourceMatcher.new(:cobblerd_repo, :delete, system_name)
  end
end
