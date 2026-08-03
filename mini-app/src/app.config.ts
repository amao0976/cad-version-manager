export default defineAppConfig({
  pages: [
    'pages/requests/index',
    'pages/records/index',
    'pages/mine/index',
    'pages/login/index',
    'pages/request-detail/index',
    'pages/create-request/index',
    'pages/record-detail/index',
    'pages/create-record/index',
    'pages/report/index',
  ],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#2563eb',
    navigationBarTitleText: '验货管理',
    navigationBarTextStyle: 'white'
  },
  tabBar: {
    color: '#86909c',
    selectedColor: '#2563eb',
    backgroundColor: '#ffffff',
    borderStyle: 'black',
    list: [
      {
        pagePath: 'pages/requests/index',
        text: '验货申请',
        iconPath: 'assets/tabbar/requests.png',
        selectedIconPath: 'assets/tabbar/requests-selected.png'
      },
      {
        pagePath: 'pages/records/index',
        text: '验货记录',
        iconPath: 'assets/tabbar/records.png',
        selectedIconPath: 'assets/tabbar/records-selected.png'
      },
      {
        pagePath: 'pages/mine/index',
        text: '我的',
        iconPath: 'assets/tabbar/mine.png',
        selectedIconPath: 'assets/tabbar/mine-selected.png'
      }
    ]
  }
})
