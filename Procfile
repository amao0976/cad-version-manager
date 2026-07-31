# Railway Procfile - 进程配置
# 使用 Gemfile.railway（包含 pg gem）
web: BUNDLE_GEMFILE=Gemfile.railway bundle exec rails db:migrate 2>/dev/null; BUNDLE_GEMFILE=Gemfile.railway bundle exec puma -b tcp://0.0.0.0:$PORT -e production
