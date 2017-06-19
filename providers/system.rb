# Base Provider
include Cobbler::Parse

# Notifications are impacted here. If you do delayed notifications, they will be performed at the
# end of the resource run and not at the end of the chef run. You do want to use this as it also
# affects internal resource notifications.
use_inline_resources

#------------------------------------------------------------
# Create Action
#------------------------------------------------------------
action :create do
  # Only create if it does not exist.
  if @current_resource.exists
    Chef::Log.warn "A system named #{@current_resource.name} already exists. Not creating."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Creating Cobbler system #{@new_resource.base_name}") do
      resp = create
      # We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(resp)
    end
  end
end

#------------------------------------------------------------
# Delete Action
#------------------------------------------------------------
action :delete do
  # Only delete if it exists.
  if @current_resource.exists
    # Converge our node
    converge_by("Deleting Cobbler system #{@new_resource.base_name}") do
      resp = delete
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.warn "The system #{@new_resource.base_name} does not exist, nothing was deleted."
  end
end

#------------------------------------------------------------
# Support Simulated Runs
#------------------------------------------------------------
def whyrun_supported?
  true
end

#------------------------------------------------------------
# Override Load Current Resource
#------------------------------------------------------------
def load_current_resource
  if exists?(@new_resource.base_name)
    @current_resource = load_repo(@new_resource.base_name)
    @current_resource.exists = true
  else
    @current_resource = @new_resource.clone
    @current_resource.exists = false
  end
end
