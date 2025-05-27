# Stage 1: Build the Next.js application
FROM node:22-alpine AS builder
WORKDIR /app

# Copy package.json and pnpm-lock.yaml to install dependencies
COPY package*.json pnpm-lock.yaml ./

# Install pnpm globally and then install project dependencies
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN pnpm run build


# Stage 2: Create the production-ready image
FROM node:22-alpine AS runner
WORKDIR /app

# Set environment to production
ENV NODE_ENV production

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

# Copy necessary files from the builder stage
COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Switch to the non-root user
USER nodejs

# Expose the port Next.js runs on
EXPOSE 3000

# Command to run the Next.js application
CMD ["pnpm", "run", "start"]
