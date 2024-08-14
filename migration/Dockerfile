# Use the official Ruby image from Docker Hub
FROM ruby:latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the Ruby script into the container
COPY app.rb .

# Install the webrick gem
RUN gem install webrick
RUN gem install mysql2
RUN gem install timeout

# Expose port 8080 to be accessible from outside the container
EXPOSE 8080

# Define the command to run the script
CMD ["ruby", "app.rb"]

