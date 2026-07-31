# 帮助中心示例数据初始化脚本
# 运行方式: rails runner db/seeds_guides.rb

puts "开始初始化帮助中心数据..."

# 创建分类
categories_data = [
  { name: '快速开始', slug: 'getting-started', description: '新用户入门指南', sort_order: 0 },
  { name: '产品说明', slug: 'product-guide', description: '产品功能和使用说明', sort_order: 1 },
  { name: '验货管理', slug: 'inspection', description: '验货流程和规范', sort_order: 2 },
  { name: 'PLM 生命周期', slug: 'plm-lifecycle', description: '产品生命周期管理', sort_order: 3 },
  { name: '常见问题', slug: 'faq', description: '常见问题解答', sort_order: 4 }
]

categories = {}
categories_data.each do |data|
  category = GuideCategory.find_or_initialize_by(slug: data[:slug])
  category.assign_attributes(data)
  category.save!
  categories[data[:slug]] = category
  puts "创建分类: #{category.name}"
end

# 获取管理员用户
admin = User.find_by(email: 'admin@example.com') || User.first

# 创建示例文档
guides_data = [
  {
    title: '欢迎使用 PLM 管理系统',
    slug: 'welcome-to-plm',
    content_md: <<~MD,
# 欢迎使用 PLM 管理系统

## 系统概述

PLM（Product Lifecycle Management）管理系统是一个完整的产品生命周期管理平台，涵盖从设计、生产到销售的全过程。

## 主要功能

- 📐 **设计管理**：图纸版本控制、BOM 管理
- 🏭 **生产管理**：产品状态跟踪、批量管理
- ✅ **质量检验**：验货申请、验货报告
- 📦 **供应链**：供应商管理、物料管理

## 快速开始

1. 使用管理员账号登录系统
2. 在「产品」菜单中创建新产品
3. 上传设计图纸到产品
4. 创建 BOM 清单
5. 提交验货申请

## 技术支持

如有问题，请联系系统管理员。
    MD
    category: 'getting-started',
    status: 'published'
  },
  {
    title: '如何创建新产品',
    slug: 'how-to-create-product',
    content_md: <<~MD,
# 如何创建新产品

## 步骤说明

### 1. 进入产品管理页面

点击导航栏「产品」→「产品列表」

### 2. 点击「新建产品」按钮

### 3. 填写产品信息

- **产品编码**：唯一标识符（如 WATCH001）
- **产品名称**：产品的中文名称
- **分类**：选择产品所属分类
- **状态**：产品的当前状态

### 4. 设置产品生命周期

产品默认进入「设计」阶段，随着工作进展，可以通过 PLM 仪表盘转换阶段：

1. 设计 → 试产 → 量产 → 停产

### 5. 保存产品

点击「创建产品」按钮完成创建。

## 注意事项

- 产品编码必须唯一
- 创建后可添加变体、BOM、图纸等关联数据
- 只有量产阶段的产品才能创建验货申请
    MD
    category: 'product-guide',
    status: 'published'
  },
  {
    title: '验货流程说明',
    slug: 'inspection-process',
    content_md: <<~MD,
# 验货流程说明

## 概述

验货管理是产品质量管理的重要环节，确保出厂产品符合标准要求。

## 验货流程

### 1. 创建验货申请

- 进入「验货」→「验货申请」
- 点击「新建申请」
- 选择产品、供应商、工厂
- 填写订单号、数量等信息
- 系统自动计算 AQL 抽样方案

### 2. 审核验货申请

- 提交后等待审核
- 审核人查看申请详情
- 可以上传审核凭证
- 审核结果：PASS / FAIL / CONDITIONAL

### 3. 创建验货记录

- 根据申请创建验货记录
- 填写验货详情
- 记录主要/次要缺陷数
- 标记关键检查项

### 4. 生成验货报告

- 创建报告并填写尺码表
- 添加缺陷照片
- 填写总结和备注
- 导出 PDF / Excel

### 5. 完成验货

- 确认报告内容完整
- 标记为已完成

## AQL 抽样标准

系统内置 ISO 2859-1 / ANSI/ASQ Z1.4 标准，自动计算：

- **代码字母**：根据批量大小和验货等级
- **抽样数**：需要抽取的样本数量
- **接受数 (Ac)**：允许的最大缺陷数
- **拒收数 (Re)**：超过此数则拒收

## 状态流转

```
待审核 → 已安排 → 已完成 → 已取消
```
    MD
    category: 'inspection',
    status: 'published'
  },
  {
    title: '产品生命周期管理',
    slug: 'plm-lifecycle-management',
    content_md: <<~MD,
# 产品生命周期管理

## 生命周期阶段

### 1. 设计阶段 (design)
- 产品初始创建
- 上传设计图纸
- 创建 BOM 清单
- 状态：`draft`

### 2. 试产阶段 (prototype)
- 完成设计后进入
- 小批量生产验证
- 测试和改进
- 状态：`in_production`

### 3. 量产阶段 (production)
- 正式批量生产
- **可以创建验货申请**
- 产能提升
- 状态：`in_production`

### 4. 停产阶段 (discontinued)
- 停止生产
- 进入生命周期末期
- 状态：`offline`

## 状态转换

在产品详情页的「PLM」标签页，可以：

1. 查看当前阶段
2. 点击「推进」按钮转换到下一阶段
3. 记录转换原因和时间
4. 查看历史转换记录

## 仪表盘统计

PLM 仪表盘提供：

- 各阶段产品数量统计
- 最近状态变更记录
- 待处理任务提醒
    MD
    category: 'plm-lifecycle',
    status: 'published'
  },
  {
    title: '常见问题解答',
    slug: 'faq',
    content_md: <<~MD,
# 常见问题解答

## 账户相关

### Q: 如何重置密码？
A: 在登录页面点击「忘记密码」，按照邮件提示重置。

### Q: 如何修改个人信息？
A: 登录后点击右上角用户菜单，选择「个人资料」进行修改。

## 功能使用

### Q: 如何批量导入数据？
A: 支持 Excel/CSV 格式导入，在相应列表页面点击「导入」按钮。

### Q: 如何导出报表？
A: 在列表页面点击「导出」按钮，系统会生成 Excel 文件。

### Q: 为什么不能创建验货申请？
A: 验货申请只能在产品处于「量产」阶段时创建。请先检查产品状态。

## 技术问题

### Q: 页面显示异常怎么办？
A: 建议使用 Chrome 或 Edge 浏览器，并清理浏览器缓存后重试。

### Q: 支持哪些文件格式？
A: 支持 PDF、Excel (.xlsx)、Word (.docx)、图片 (jpg, png) 等常用格式。

## 联系我们

如果以上解答无法解决您的问题，请联系：

- 📧 邮箱：support@example.com
- ☎️ 电话：400-xxx-xxxx
    MD
    category: 'faq',
    status: 'published'
  },
  {
    title: '如何管理供应商',
    slug: 'how-to-manage-suppliers',
    content_md: <<~MD,
# 如何管理供应商

## 供应商管理

### 添加新供应商

1. 进入「供应商」菜单
2. 点击「新建供应商」
3. 填写基本信息：
   - 供应商编码（唯一）
   - 公司名称
   - 联系人信息
   - 地址
   - 供应商类型（原料/部件/成品）
   - 等级（A/B/C）
4. 保存

### 工厂管理

每个供应商可以有多个下属工厂：

1. 在供应商详情页点击「管理工厂」
2. 或直接访问「工厂管理」页面
3. 添加工厂信息：
   - 工厂名称
   - 所在国家/省/市
   - 详细地址

### 供应商分类

系统支持按分类管理供应商：

- **原料供应商**：提供原材料
- **部件供应商**：提供零部件
- **成品供应商**：提供成品装配

### 等级说明

| 等级 | 说明 |
|------|------|
| A 级 | 优秀供应商，优先合作 |
| B 级 | 合格供应商，正常合作 |
| C 级 | 待改进供应商，需重点关注 |
    MD
    category: 'product-guide',
    status: 'published'
  },
  {
    title: '代码示例 - AQL 计算',
    slug: 'aql-calculation-example',
    content_md: <<~MD,
# 代码示例 - AQL 计算

## Ruby 示例代码

以下示例展示如何使用 AQL 计算器：

```ruby
# 计算抽样方案
result = AqlCalculator.calculate(
  quantity: 500,          # 批量大小
  aql_level: "2.5",       # AQL 水平
  inspection_level: "II"  # 验货等级
)

# 返回结果
# {
#   code_letter: "H",      # 代码字母
#   sample_size: 50,       # 抽样数
#   accept_qty: 0,         # 接受数
#   reject_qty: 1          # 拒收数
# }
```

## 批量范围对应关系

| 批量范围 | I 级 | II 级 | III 级 |
|----------|------|-------|--------|
| 2-8      | A    | A     | B      |
| 9-15     | A    | B     | C      |
| 16-25    | B    | C     | D      |
| 26-50    | C    | D     | E      |
| 51-90    | C    | E     | F      |
| 91-150   | D    | F     | G      |
| 151-280  | E    | G     | H      |
| 281-500  | F    | H     | J      |

## 使用建议

1. 根据产品选择合适的 AQL 水平
2. 一般消费品使用 2.5 或 4.0
3. 严格要求可使用 1.0 或 0.65
4. 系统会自动计算，无需手动查表
    MD
    category: 'inspection',
    status: 'published'
  }
]

guides_data.each do |data|
  guide = Guide.find_or_initialize_by(slug: data[:slug])
  guide.assign_attributes(
    title: data[:title],
    content_md: data[:content_md],
    guide_category: categories[data[:category]],
    author: admin,
    status: data[:status],
    published_at: Time.current
  )
  guide.save!
  puts "创建文档: #{guide.title}"
end

puts "\n"
puts "=" * 50
puts "帮助中心数据初始化完成！"
puts "分类数量: #{GuideCategory.count}"
puts "文档数量: #{Guide.count}"
puts "=" * 50
