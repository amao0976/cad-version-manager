# Ruby on Rails 生产环境镜像
FROM ruby:3.3-slim

# 安装系统依赖
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libvips \
      nodejs \
      npm \
      git \
      tzdata \
      curl \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# 先复制 Gemfile 利用 Docker 缓存
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 复制项目文件
COPY . .

# 预编译资源
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# 创建存储目录
RUN mkdir -p /app/storage /app/tmp/sockets /app/tmp/pids && \
    chmod -R 755 /app/storage /app/tmp

# 暴露端口
EXPOSE 3000

# 启动脚本
COPY bin/docker-entrypoint /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
