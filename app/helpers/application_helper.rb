module ApplicationHelper
  # 截断文本到指定长度
  def truncate(text, length: 100, separator: ' ')
    return '' if text.blank?
    text = text.to_s.gsub(/\s+/, ' ').strip
    if text.length <= length
      text
    else
      text[0...length].rpartition(separator)[0] + '...'
    end
  end

  # 将 Markdown 转为纯文本
  def to_plain_text(markdown)
    return '' if markdown.blank?
    markdown.to_s
      .gsub(/```[\s\S]*?```/, '') # 移除代码块
      .gsub(/`([^`]+)`/, '\1')   # 移除行内代码
      .gsub(/[*_]{1,3}/, '')      # 移除粗体/斜体标记
      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1') # 链接文字
      .gsub(/!\[([^\]]*)\]\([^)]+\)/, '') # 移除图片
      .gsub(/^#{Regexp.escape('#')}{1,6}\s+/, '') # 移除标题标记
      .gsub(/^[-*]\s+/, '')       # 移除列表标记
      .gsub(/\n{2,}/, ' ')        # 合并空行
      .gsub(/\n/, ' ')            # 换行变空格
      .strip
  end

  # 生成文档目录 (从 HTML 内容中提取标题)
  def generate_toc(html_content)
    return [] if html_content.blank?

    require 'nokogiri' rescue nil

    # 使用简单的正则表达式提取标题
    toc = []
    html_content.scan(/<h([2-4])[^>]*id="([^"]*)"[^>]*>([^<]+)<\/h\1>/i) do |match|
      level = match[1].to_i
      id = match[2]
      text = match[3].strip
      toc << { level: level - 1, id: id, text: text }
    end

    toc
  end

  # 格式化时间
  def format_time(time, format = :short)
    return '' if time.blank?
    l(time, format: format)
  end

  # 状态标签
  def status_badge(status)
    case status
    when 'draft'
      content_tag(:span, '草稿', class: 'badge bg-secondary')
    when 'published'
      content_tag(:span, '已发布', class: 'badge bg-success')
    when 'archived'
      content_tag(:span, '已归档', class: 'badge bg-warning')
    else
      content_tag(:span, status, class: 'badge bg-primary')
    end
  end
end
