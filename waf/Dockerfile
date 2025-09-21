FROM owasp/modsecurity-crs:nginx-alpine

# Copy our custom configurations
COPY modsecurity.conf /etc/modsecurity/modsecurity.conf
COPY crs-setup.conf /etc/modsecurity.d/crs-setup.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Set the paranoia level through build arg (defaults to 1)
ARG PARANOIA_LEVEL=1
RUN sed -i "s/tx.paranoia_level=1/tx.paranoia_level=${PARANOIA_LEVEL}/" /etc/modsecurity.d/crs-setup.conf

# Switch to root to handle directory creation and permissions
USER root

# Create necessary directories and set permissions
RUN mkdir -p /var/log/nginx /var/log/modsec \
    && chown -R nginx:nginx /var/log/nginx /var/log/modsec /etc/nginx/conf.d/ \
    && chmod -R 755 /var/log/nginx /var/log/modsec \
    && chmod -R 644 /etc/nginx/conf.d/

# Forward request and error logs to container stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.json \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/modsec_audit.log

# Switch back to nginx user
USER nginx

# Use non-root user
USER nginx

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -q --spider http://localhost/-/ready || exit 1