# Use the official OpenProject 16 image as the base
FROM openproject/openproject:16

# Set default environment variables in the image configuration
ENV secret_key_base=secret
ENV openproject_host__name=localhost:8080
ENV openproject_https=false

# The original image already exposes port 80 internally and defines the CMD/ENTRYPOINT.
# We just inherit those configurations.
EXPOSE 80
