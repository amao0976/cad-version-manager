import React from 'react';
import Taro, { useDidShow } from '@tarojs/taro';
import { isUserLoggedIn } from './store/auth';
import './app.scss';

function App(props) {
  useDidShow(() => {
    if (!isUserLoggedIn()) {
      const currentPages = Taro.getCurrentPages();
      const currentPage = currentPages[currentPages.length - 1];
      if (currentPage && currentPage.route !== 'pages/login/index') {
        Taro.reLaunch({ url: '/pages/login/index' });
      }
    }
  });

  return props.children;
}

export default App;
