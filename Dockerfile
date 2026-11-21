# ==============================================================================
# Stage 1: Builder
# Compiles and bundles the static web assets using Node.js and Parcel
# ==============================================================================

# Use an official, lightweight Node.js 22 Alpine image with a pinned version tag
FROM node:22-alpine AS builder

# Set the working directory inside the container for subsequent instructions
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker layer caching
# (avoids re-running npm ci if only source files change)
COPY package*.json ./

# Install exact dependency versions cleanly from package-lock.json
RUN npm ci

# Copy the application source code and stylesheets into the container
COPY src/ ./src/
COPY styles/ ./styles/

# Bundle the application into production-ready static files inside /app/dist
RUN npm run build


# ==============================================================================
# Stage 2: Runtime
# Serves only the compiled static assets using a minimal Nginx web server
# ==============================================================================

# Use an official, lightweight Nginx 1.27 Alpine image with a pinned version tag
FROM nginx:1.27-alpine

# Copy only the compiled static output from the builder stage into Nginx's web root
# Node.js, source files, and node_modules are left behind in Stage 1
COPY --from=builder /app/dist /usr/share/nginx/html

# Document that the container listens on port 80 for incoming HTTP traffic
EXPOSE 80

# Start Nginx in the foreground so the container stays running
CMD ["nginx", "-g", "daemon off;"]