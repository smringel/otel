# Tilt: locally edit your app images AND/OR helm charts and live sync to your cluster
#
########################################
#  For help join #cmm-kubernetes-cove  #
########################################
#
# Usage
# Develop changes to your app:                    tilt up
#                                                 Run tilt, pulling the chart from cmmchartmuseum
#
# Develop changes to your app AND/OR helm chart:  tilt up -- --local-chart
#                                                         ^ notice the extra double dashes
#                                                 Run tilt, building the chart from your local filesystem
#                                                 Specify where you cloned devops/kubernetes to via the
#                                                 DEVOPS_KUBERNETES_BASE env var or --devops-kubernetes-base
#                                                 tilt arg.

# NOTE: The following configuration is intended to build your *development* image with *development* tools and environment

# Which Dockerfile and target stage to build your development image from (Dockerfile.dev is a common one)
#
dockerfile    = 'Dockerfile'
docker_target = '' # Use '' to indicate the base (only) stage

# Use your CI-built image as --cache-from when building
# NOTE: If building your image from scratch is faster than
#       pulling the cache image, disable this
#
cache_image = 'registry.cmmint.net/smringel/otel'

# Which database image tag to use (e.g. branch-foo or latest)
#
database_image_tag = 'latest'

# Which environment (e.g. RAILS_ENV) to pass to the helm chart
#
environment = 'dev'


image_build_paths = ['mix.exs', 'mix.lock', 'config']

# And some paths may require a total helm redeployment (don't add your chart dir here)
#
helm_deploy_paths = ['Dockerfile']

# Where tilt should push your development image after building it (tags are auto-generated)
#
image = 'katscratch.azurecr.io/smringel/otel'

# The name of the cmmchartmuseum helm chart used for this app
# NOTE: You can find the source for this chart here:
#       https://git.innova-partners.com/devops/kubernetes/tree/main/helm/app-charts/otel
#
chart = 'otel'

# Any additional helm values to set in the form of 'key=value'
#
helm_set = ['resources.limits.memory=2048M','resources.limits.cpu=2000m',]

# The namespace to deploy to
#
namespace = 'otel'

# List of file patterns that will not be synced by Tilt
# Note: this uses the .dockerignore pattern syntax for matching.
# e.g. ['client']
#
ignore = []

# End of configuration section. See the Tiltfile Cookbook for code snippets of additional things
# you can add here (buttons to bundle update, rspec, etc)
# Load more UI buttons from https://git.innova-partners.com/devops/tilt
# For additional Tilt UI buttons examples, see https://covermymeds.atlassian.net/wiki/spaces/Technologies/pages/549489045/Tiltfile+Cookbook

###############################################
# Add useful buttons/links/etc to the tilt UI #
###############################################

# opinionated_*_app_setup will validate that this is a kat cluster later
allow_k8s_contexts(k8s_context())
load('ext://git_resource', 'git_checkout')
git_checkout('git@git.innova-partners.com:devops/tilt.git#main', ".git-sources/tilt")

load('.git-sources/tilt/base/Tiltfile', 'opinionated_elixir_app_setup', 'cluster_domain')

# Load UI buttons
load('.git-sources/tilt/base/Tiltfile.ui',
  'ui_mix_test',
  'ui_mix_format',
  'ui_mix_update',
  'ui_resource_restart',
  'ui_ping',
)

# In the examples below, the default resource name is 'web'
# so it may be omitted if that is your app's resource name
# Comment out any button you don't want in UI
# See https://git.innova-partners.com/devops/tilt/tree/main/base for src

# Run tests on the cluster
ui_mix_test('web')

# Run mix format for elixir formatting
ui_mix_format('web')

# Run mix deps.update for provided packages
ui_mix_update(chart, 'web')

# Add a button to restart app resource via kubectl
ui_resource_restart(namespace, 'web')

# Ping
ui_ping(chart, 'web')

# Source: https://git.innova-partners.com/devops/tilt/blob/main/base/Tiltfile
# Feedback welcome! Join us in #cmm-kubernetes-cove
opinionated_elixir_app_setup(
  chart=chart,
  image=image,
  namespace=namespace,
  cache_image=cache_image,
  database_image_tag=database_image_tag,
  docker_target=docker_target,
  dockerfile=dockerfile,
  environment=environment,
  helm_set=helm_set,
  ignore=ignore,
  image_build_paths=image_build_paths,
)

k8s_resource(
  workload='web',
  labels=['api'],
  links=[
      link('https://otel.%s/' % cluster_domain(), 'otel-dev')
  ],
  # Starts dependencies first.
  resource_deps=['postgres']
)

k8s_resource(
  workload='otel-postgres', # change this to your app name
  new_name='postgres',
  labels=['database'],
  port_forwards=[
    port_forward(9001, 5432)
  ]
)