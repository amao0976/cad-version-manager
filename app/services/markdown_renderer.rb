require 'redcarpet'
require 'rouge'
require 'sanitize'

module MarkdownRenderer
  def self.render(markdown)
    return '' if markdown.blank?

    # 确保UTF-8编码
    markdown = markdown.dup.force_encoding('UTF-8')
    markdown = markdown.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')

    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: false,
      link_attributes: { class: 'text-primary' }
    )

    markdown_extensions = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true,
      tables: true,
      footnotes: true,
      heading_ids: true,
      highlight: true
    }

    redcarpet = Redcarpet::Markdown.new(renderer, markdown_extensions)
    html = redcarpet.render(markdown)

    # 使用 Rouge 高亮代码块
    html = highlight_code(html)

    # 清理不安全的 HTML
    sanitize(html)
  rescue => e
    Rails.logger.error("MarkdownRenderer error: #{e.message}")
    markdown.to_s
  end

  def self.highlight_code(html)
    # Rouge 代码高亮
    formatter = Rouge::Formatters::HTML.new

    html.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    html.gsub(/<pre><code[^>]*>(.*?)<\/code><\/pre>/m) do |match|
      code = $1.to_s.dup.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      # 检测语言
      lang = detect_language(code)
      begin
        lexer = Rouge::Lexer.find(lang) || Rouge::Lexers::PlainText.new
        highlighted = formatter.format(lexer.lex(code))
        "<pre><code class=\"language-#{lang}\">#{highlighted}</code></pre>"
      rescue
        match
      end
    end
  rescue => e
    Rails.logger.error("highlight_code error: #{e.message}")
    html
  end

  def self.detect_language(code)
    return 'ruby' if code.match?(/def |class |module |puts |end$/)
    return 'javascript' if code.match?(/function |const |let |var |=>/)
    return 'html' if code.match?(/<\/?[a-z]/)
    return 'css' if code.match?(/\{.*:\s*.*;|<\/style/)
    return 'sql' if code.match?(/SELECT|INSERT|UPDATE|CREATE|TABLE/)
    'plaintext'
  end

  def self.sanitize(html)
    html = html.to_s.dup.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')

    sanitizer = Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements: Sanitize::Config::RELAXED[:elements] + [
        'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
        'blockquote', 'pre', 'code', 'table', 'thead', 'tbody', 'tr', 'th', 'td',
        'dl', 'dt', 'dd', 'figure', 'figcaption', 'hr', 'br', 'div', 'span'
      ],
      attributes: {
        'a' => ['href', 'title', 'target', 'class'],
        'img' => ['src', 'alt', 'width', 'height', 'class'],
        'code' => ['class'],
        'pre' => ['class'],
        'table' => ['class'],
        'td' => ['align'],
        'th' => ['align'],
        'div' => ['class'],
        'span' => ['class']
      },
      protocols: {
        'a' => { 'href' => ['http', 'https', 'mailto', '#', 'relative'] },
        'img' => { 'src' => ['http', 'https', 'data'] }
      }
    )

    Sanitize.fragment(html, sanitizer)
  rescue => e
    Rails.logger.error("sanitize error: #{e.message}")
    html
  end
end
